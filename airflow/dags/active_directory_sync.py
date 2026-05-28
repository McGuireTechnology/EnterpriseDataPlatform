from __future__ import annotations

import json
import secrets
import uuid
from datetime import datetime, timedelta, timezone
from typing import Callable

import psycopg2
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from ldap3 import ALL, Connection, Server, SUBTREE

AD_SCHEMA = "ad"
_ULID_ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"


def _first(value: object) -> object:
    if isinstance(value, (list, tuple)):
        return value[0] if value else None
    return value


def _encode_crockford(value: int, length: int) -> str:
    chars = ["0"] * length
    for idx in range(length - 1, -1, -1):
        chars[idx] = _ULID_ALPHABET[value & 31]
        value >>= 5
    return "".join(chars)


def _new_ulid() -> str:
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    time_part = _encode_crockford(now_ms, 10)
    rand_part = _encode_crockford(secrets.randbits(80), 16)
    return f"{time_part}{rand_part}"


def _guid_to_str(value: object) -> str:
    value = _first(value)
    if isinstance(value, (bytes, bytearray)):
        return str(uuid.UUID(bytes_le=bytes(value)))
    return str(value)


def _to_iso(value: object) -> datetime | None:
    value = _first(value)
    if not value:
        return None
    if isinstance(value, datetime):
        if value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value
    return None


def _load_sources_and_target() -> tuple[list[dict], str]:
    sources = json.loads(
        Variable.get(
            "ad_sources",
            default_var=Variable.get("active_directory_sources", default_var="[]"),
        )
    )
    if not sources:
        raise ValueError("Airflow Variable 'ad_sources' is empty. Configure AD sources first.")
    target_conn_id = Variable.get(
        "ad_target_conn_id",
        default_var=Variable.get(
            "active_directory_target_conn_id",
            default_var=Variable.get("adds_target_conn_id", default_var="postgres_raw"),
        ),
    )
    return sources, target_conn_id


def _is_truthy(value: object) -> bool:
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def _force_full_snapshot_for_entity(source: dict, entity: str) -> bool:
    source_overrides = source.get("force_full_snapshot_entities", [])
    if isinstance(source_overrides, list) and entity in source_overrides:
        return True

    global_override = Variable.get("ad_force_full_snapshot", default_var="false")
    if _is_truthy(global_override):
        return True

    scoped_override = Variable.get("ad_force_full_snapshot_entities", default_var="")
    if scoped_override:
        entities = {part.strip() for part in scoped_override.split(",") if part.strip()}
        return entity in entities

    return False


def _get_ldap_connection(ad_conn_id: str) -> Connection:
    ad_conn = BaseHook.get_connection(ad_conn_id)
    extra = ad_conn.extra_dejson or {}
    # Works with generic Airflow connection types; only host/login/password/port + extra.use_ssl are required.
    use_ssl_raw = extra.get("use_ssl", extra.get("extra__ldap__use_ssl", True))
    use_ssl = str(use_ssl_raw).lower() in {"1", "true", "yes", "on"}
    server = Server(
        host=ad_conn.host,
        port=ad_conn.port or 636,
        use_ssl=use_ssl,
        get_info=ALL,
    )
    if not ad_conn.login or not ad_conn.password:
        raise ValueError(f"Missing login/password in Airflow connection '{ad_conn_id}'")
    return Connection(server, user=ad_conn.login, password=ad_conn.password, auto_bind=True)


def _get_pg_connection(target_conn_id: str):
    target_conn = BaseHook.get_connection(target_conn_id)
    return psycopg2.connect(
        host=target_conn.host,
        port=target_conn.port or 5432,
        dbname=target_conn.schema,
        user=target_conn.login,
        password=target_conn.password,
    )


def _assert_required_tables(cur) -> None:
    required = [
        "sync_runs",
        "sync_state",
        "users",
        "groups",
        "group_memberships",
        "computers",
    ]
    missing: list[str] = []
    for table in required:
        cur.execute("SELECT to_regclass(%s)", (f'{AD_SCHEMA}.{table}',))
        if cur.fetchone()[0] is None:
            missing.append(f'{AD_SCHEMA}.{table}')
    if missing:
        raise RuntimeError(
            "Missing required AD tables. Run Alembic migrations first. Missing: "
            + ", ".join(missing)
        )


def _prepare_storage() -> None:
    _, target_conn_id = _load_sources_and_target()
    reset_sync_state = _is_truthy(Variable.get("ad_reset_sync_state", default_var="false"))

    pg = _get_pg_connection(target_conn_id)
    pg.autocommit = False
    cur = pg.cursor()
    try:
        _assert_required_tables(cur)
        if reset_sync_state:
            cur.execute(f"""TRUNCATE TABLE "{AD_SCHEMA}"."sync_state";""")
        pg.commit()
    finally:
        cur.close()
        pg.close()


def _start_sync_run(cur, source_key: str, phase: str) -> str:
    run_id = _new_ulid()
    cur.execute(
        f"""
        INSERT INTO "{AD_SCHEMA}"."sync_runs" (id, source_key, status)
        VALUES (%s, %s, %s)
        RETURNING id
        """,
        (run_id, f"{source_key}:{phase}", "running"),
    )
    return cur.fetchone()[0]


def _get_last_cursor(cur, source_key: str, entity: str) -> datetime | None:
    cur.execute(
        f"""
        SELECT last_cursor
        FROM "{AD_SCHEMA}"."sync_state"
        WHERE source_key = %s AND entity = %s
        """,
        (source_key, entity),
    )
    row = cur.fetchone()
    return row[0] if row else None


def _set_last_cursor(cur, source_key: str, entity: str, last_cursor: datetime | None) -> None:
    cur.execute(
        f"""
        INSERT INTO "{AD_SCHEMA}"."sync_state" (source_key, entity, last_cursor, updated_at)
        VALUES (%s, %s, %s, now())
        ON CONFLICT (source_key, entity)
        DO UPDATE SET last_cursor = EXCLUDED.last_cursor, updated_at = now()
        """,
        (source_key, entity, last_cursor),
    )


def _format_ad_timestamp(ts: datetime) -> str:
    ts_utc = ts.astimezone(timezone.utc)
    return ts_utc.strftime("%Y%m%d%H%M%S.0Z")


def _finish_sync_run(cur, sync_run_id: str, status: str, rows_read: int, rows_written: int, error_message: str | None = None):
    cur.execute(
        f"""
        UPDATE "{AD_SCHEMA}"."sync_runs"
        SET status = %s,
            ended_at = now(),
            rows_read = %s,
            rows_written = %s,
            error_message = %s
        WHERE id = %s
        """,
        (status, rows_read, rows_written, error_message, sync_run_id),
    )


def _sync_users_for_source(source: dict, target_conn_id: str, force_full_override: bool = False) -> None:
    source_key = source["connection_key"]
    ad_conn_id = source["airflow_conn_id"]
    search_base = source["search_base"]

    with _get_ldap_connection(ad_conn_id) as ldap:
        pg = _get_pg_connection(target_conn_id)
        pg.autocommit = False
        cur = pg.cursor()

        force_full = force_full_override or _force_full_snapshot_for_entity(source, "users")
        last_cursor = None if force_full else _get_last_cursor(cur, source_key, "users")
        snapshot_mode = "full" if force_full or not last_cursor else "incremental"
        search_filter = "(&(objectClass=user)(objectCategory=person))"
        if last_cursor:
            search_filter = (
                "(&(objectClass=user)(objectCategory=person)"
                f"(whenChanged>={_format_ad_timestamp(last_cursor)}))"
            )

        sync_run_id = _start_sync_run(cur, source_key, "users")
        pg.commit()
        rows_read = 0
        rows_written = 0
        max_when_changed: datetime | None = last_cursor
        snapshot_ts = datetime.now(timezone.utc)
        try:
            ldap.search(
                search_base=search_base,
                search_filter=search_filter,
                search_scope=SUBTREE,
                attributes=[
                    "objectGUID",
                    "distinguishedName",
                    "sAMAccountName",
                    "userPrincipalName",
                    "displayName",
                    "mail",
                    "userAccountControl",
                    "whenChanged",
                ],
            )
            for entry in ldap.entries:
                d = entry.entry_attributes_as_dict
                object_guid = _guid_to_str(d.get("objectGUID"))
                uac = int(_first(d.get("userAccountControl", 0)) or 0)
                enabled = "true" if (uac & 2) == 0 else "false"
                when_changed = _to_iso(d.get("whenChanged"))
                if when_changed and (max_when_changed is None or when_changed > max_when_changed):
                    max_when_changed = when_changed
                cur.execute(
                    f"""
                    INSERT INTO "{AD_SCHEMA}"."users"
                        (id, source_key, snapshot_mode, snapshot_ts, object_guid, distinguished_name, sam_account_name,
                         user_principal_name, display_name, email, enabled, when_changed, sync_run_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        _new_ulid(),
                        source_key,
                        snapshot_mode,
                        snapshot_ts,
                        object_guid,
                        _first(d.get("distinguishedName", "")),
                        _first(d.get("sAMAccountName")),
                        _first(d.get("userPrincipalName")),
                        _first(d.get("displayName")),
                        _first(d.get("mail")),
                        enabled,
                        when_changed,
                        sync_run_id,
                    ),
                )
                rows_read += 1
                rows_written += 1

            _set_last_cursor(cur, source_key, "users", max_when_changed)
            _finish_sync_run(cur, sync_run_id, "success", rows_read, rows_written)
            pg.commit()
        except Exception as exc:
            pg.rollback()
            _finish_sync_run(cur, sync_run_id, "failed", rows_read, rows_written, str(exc))
            pg.commit()
            raise
        finally:
            cur.close()
            pg.close()


def _sync_groups_for_source(source: dict, target_conn_id: str, force_full_override: bool = False) -> None:
    source_key = source["connection_key"]
    ad_conn_id = source["airflow_conn_id"]
    search_base = source["search_base"]
    group_base = source.get("group_search_base", search_base)

    with _get_ldap_connection(ad_conn_id) as ldap:
        pg = _get_pg_connection(target_conn_id)
        pg.autocommit = False
        cur = pg.cursor()

        force_full = force_full_override or _force_full_snapshot_for_entity(source, "groups_memberships")
        last_cursor = None if force_full else _get_last_cursor(cur, source_key, "groups_memberships")
        snapshot_mode = "full" if force_full or not last_cursor else "incremental"
        search_filter = "(objectClass=group)"
        if last_cursor:
            search_filter = f"(&(objectClass=group)(whenChanged>={_format_ad_timestamp(last_cursor)}))"

        sync_run_id = _start_sync_run(cur, source_key, "groups_memberships")
        pg.commit()
        rows_read = 0
        rows_written = 0
        max_when_changed: datetime | None = last_cursor
        snapshot_ts = datetime.now(timezone.utc)
        try:
            ldap.search(
                search_base=group_base,
                search_filter=search_filter,
                search_scope=SUBTREE,
                attributes=[
                    "objectGUID",
                    "distinguishedName",
                    "sAMAccountName",
                    "name",
                    "description",
                    "whenChanged",
                    "member",
                ],
            )
            for entry in ldap.entries:
                d = entry.entry_attributes_as_dict
                group_guid = _guid_to_str(d.get("objectGUID"))
                when_changed = _to_iso(d.get("whenChanged"))
                if when_changed and (max_when_changed is None or when_changed > max_when_changed):
                    max_when_changed = when_changed
                cur.execute(
                    f"""
                    INSERT INTO "{AD_SCHEMA}"."groups"
                        (id, source_key, snapshot_mode, snapshot_ts, object_guid, distinguished_name, sam_account_name,
                         name, description, when_changed, sync_run_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        _new_ulid(),
                        source_key,
                        snapshot_mode,
                        snapshot_ts,
                        group_guid,
                        _first(d.get("distinguishedName", "")),
                        _first(d.get("sAMAccountName")),
                        _first(d.get("name")),
                        _first(d.get("description")),
                        when_changed,
                        sync_run_id,
                    ),
                )
                rows_read += 1
                rows_written += 1

                members = d.get("member", []) or []
                for member_dn in members:
                    ldap.search(
                        search_base=str(member_dn),
                        search_filter="(objectClass=*)",
                        search_scope=SUBTREE,
                        attributes=["objectGUID", "objectClass"],
                        size_limit=1,
                    )
                    if not ldap.entries:
                        continue
                    member_data = ldap.entries[0].entry_attributes_as_dict
                    member_guid = _guid_to_str(member_data.get("objectGUID"))
                    classes = {c.lower() for c in member_data.get("objectClass", [])}
                    member_type = "group" if "group" in classes else ("computer" if "computer" in classes else "user")
                    cur.execute(
                        f"""
                        INSERT INTO "{AD_SCHEMA}"."group_memberships"
                            (id, source_key, snapshot_mode, snapshot_ts, group_guid, member_guid, member_type, sync_run_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                        """,
                        (_new_ulid(), source_key, snapshot_mode, snapshot_ts, group_guid, member_guid, member_type, sync_run_id),
                    )
                    rows_written += 1

            _set_last_cursor(cur, source_key, "groups_memberships", max_when_changed)
            _finish_sync_run(cur, sync_run_id, "success", rows_read, rows_written)
            pg.commit()
        except Exception as exc:
            pg.rollback()
            _finish_sync_run(cur, sync_run_id, "failed", rows_read, rows_written, str(exc))
            pg.commit()
            raise
        finally:
            cur.close()
            pg.close()


def _sync_computers_for_source(source: dict, target_conn_id: str, force_full_override: bool = False) -> None:
    source_key = source["connection_key"]
    ad_conn_id = source["airflow_conn_id"]
    search_base = source["search_base"]
    computer_base = source.get("computer_search_base", search_base)

    with _get_ldap_connection(ad_conn_id) as ldap:
        pg = _get_pg_connection(target_conn_id)
        pg.autocommit = False
        cur = pg.cursor()

        force_full = force_full_override or _force_full_snapshot_for_entity(source, "computers")
        last_cursor = None if force_full else _get_last_cursor(cur, source_key, "computers")
        snapshot_mode = "full" if force_full or not last_cursor else "incremental"
        search_filter = "(objectClass=computer)"
        if last_cursor:
            search_filter = f"(&(objectClass=computer)(whenChanged>={_format_ad_timestamp(last_cursor)}))"

        sync_run_id = _start_sync_run(cur, source_key, "computers")
        pg.commit()
        rows_read = 0
        rows_written = 0
        max_when_changed: datetime | None = last_cursor
        snapshot_ts = datetime.now(timezone.utc)
        try:
            ldap.search(
                search_base=computer_base,
                search_filter=search_filter,
                search_scope=SUBTREE,
                attributes=["objectGUID", "distinguishedName", "sAMAccountName", "dNSHostName", "operatingSystem", "whenChanged"],
            )
            for entry in ldap.entries:
                d = entry.entry_attributes_as_dict
                object_guid = _guid_to_str(d.get("objectGUID"))
                when_changed = _to_iso(d.get("whenChanged"))
                if when_changed and (max_when_changed is None or when_changed > max_when_changed):
                    max_when_changed = when_changed
                cur.execute(
                    f"""
                    INSERT INTO "{AD_SCHEMA}"."computers"
                        (id, source_key, snapshot_mode, snapshot_ts, object_guid, distinguished_name, sam_account_name,
                         dns_host_name, operating_system, when_changed, sync_run_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        _new_ulid(),
                        source_key,
                        snapshot_mode,
                        snapshot_ts,
                        object_guid,
                        _first(d.get("distinguishedName", "")),
                        _first(d.get("sAMAccountName")),
                        _first(d.get("dNSHostName")),
                        _first(d.get("operatingSystem")),
                        when_changed,
                        sync_run_id,
                    ),
                )
                rows_read += 1
                rows_written += 1

            _set_last_cursor(cur, source_key, "computers", max_when_changed)
            _finish_sync_run(cur, sync_run_id, "success", rows_read, rows_written)
            pg.commit()
        except Exception as exc:
            pg.rollback()
            _finish_sync_run(cur, sync_run_id, "failed", rows_read, rows_written, str(exc))
            pg.commit()
            raise
        finally:
            cur.close()
            pg.close()


def _run_phase(phase_fn: Callable[[dict, str, bool], None], force_full_override: bool = False) -> None:
    sources, target_conn_id = _load_sources_and_target()
    for source in sources:
        phase_fn(source, target_conn_id, force_full_override)


def run_prepare_storage() -> None:
    _prepare_storage()


def run_sync_users() -> None:
    _run_phase(_sync_users_for_source)


def run_sync_groups_memberships() -> None:
    _run_phase(_sync_groups_for_source)


def run_sync_computers() -> None:
    _run_phase(_sync_computers_for_source)


def run_sync_users_full() -> None:
    _run_phase(_sync_users_for_source, force_full_override=True)


def run_sync_groups_memberships_full() -> None:
    _run_phase(_sync_groups_for_source, force_full_override=True)


def run_sync_computers_full() -> None:
    _run_phase(_sync_computers_for_source, force_full_override=True)


with DAG(
    dag_id="ad_full_snapshot",
    description="AD full snapshot to raw.",
    schedule="0 2 * * 0",
    start_date=datetime(2026, 5, 18, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["ad", "identity", "raw", "full_snapshot"],
) as ad_full_snapshot:
    prepare_storage = PythonOperator(
        task_id="prepare_storage",
        python_callable=run_prepare_storage,
    )

    sync_users = PythonOperator(
        task_id="sync_users",
        python_callable=run_sync_users_full,
    )

    sync_groups_memberships = PythonOperator(
        task_id="sync_groups_memberships",
        python_callable=run_sync_groups_memberships_full,
    )

    sync_computers = PythonOperator(
        task_id="sync_computers",
        python_callable=run_sync_computers_full,
    )

    trigger_process = TriggerDagRunOperator(
        task_id="trigger_process_snapshots",
        trigger_dag_id="ad_process_snapshots",
        wait_for_completion=False,
    )
    prepare_storage >> sync_users >> sync_groups_memberships >> sync_computers >> trigger_process


with DAG(
    dag_id="ad_incremental_snapshot",
    description="AD incremental snapshot to raw.",
    schedule="0 * * * *",
    start_date=datetime(2026, 5, 18, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["ad", "identity", "raw", "incremental_snapshot"],
) as ad_incremental_snapshot:
    prepare_storage = PythonOperator(task_id="prepare_storage", python_callable=run_prepare_storage)
    sync_users = PythonOperator(task_id="sync_users", python_callable=run_sync_users)
    sync_groups_memberships = PythonOperator(task_id="sync_groups_memberships", python_callable=run_sync_groups_memberships)
    sync_computers = PythonOperator(task_id="sync_computers", python_callable=run_sync_computers)
    trigger_process = TriggerDagRunOperator(
        task_id="trigger_process_snapshots",
        trigger_dag_id="ad_process_snapshots",
        wait_for_completion=False,
    )
    prepare_storage >> sync_users >> sync_groups_memberships >> sync_computers >> trigger_process


with DAG(
    dag_id="ad_process_snapshots",
    description="Process AD raw snapshots into ODS merged state.",
    schedule=None,
    start_date=datetime(2026, 5, 18, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["ad", "identity", "ods", "process_snapshots"],
) as ad_process_snapshots:
    # ODS merge pipeline is intentionally separated; placeholder DAG keeps naming pattern consistent.
    done = EmptyOperator(task_id="done")
