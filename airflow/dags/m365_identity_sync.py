from __future__ import annotations

import json
import secrets
import time
from datetime import datetime, timedelta, timezone

import psycopg2
import requests
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.models import Variable
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

SCHEMA = "m365"
_ULID_ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"


def _encode_crockford(value: int, length: int) -> str:
    chars = ["0"] * length
    for idx in range(length - 1, -1, -1):
        chars[idx] = _ULID_ALPHABET[value & 31]
        value >>= 5
    return "".join(chars)


def _new_ulid() -> str:
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    return f"{_encode_crockford(now_ms, 10)}{_encode_crockford(secrets.randbits(80), 16)}"


def _load_config() -> tuple[dict, str, str]:
    source = json.loads(Variable.get("m365_identity_source", default_var='{"airflow_conn_id":"m365_graph"}'))
    target_conn_id = Variable.get("m365_identity_target_conn_id", default_var="postgres_raw")
    ods_conn_id = Variable.get("m365_identity_ods_conn_id", default_var="postgres_ods")
    return source, target_conn_id, ods_conn_id


def _pg_conn(target_conn_id: str):
    conn = BaseHook.get_connection(target_conn_id)
    return psycopg2.connect(
        host=conn.host,
        port=conn.port or 5432,
        dbname=conn.schema,
        user=conn.login,
        password=conn.password,
    )


def _assert_tables(cur) -> None:
    required = [
        "sync_runs",
        "users",
        "groups",
        "group_memberships",
        "teams",
        "channels",
        "team_memberships",
        "channel_memberships",
    ]
    missing: list[str] = []
    for table in required:
        cur.execute("select to_regclass(%s)", (f"{SCHEMA}.{table}",))
        if cur.fetchone()[0] is None:
            missing.append(f"{SCHEMA}.{table}")
    if missing:
        raise RuntimeError("Missing tables. Run Alembic first: " + ", ".join(missing))


def _table_has_column(cur, table: str, column: str) -> bool:
    cur.execute(
        """
        select 1
        from information_schema.columns
        where table_schema = %s and table_name = %s and column_name = %s
        """,
        (SCHEMA, table, column),
    )
    return cur.fetchone() is not None


def _raw_run_column(cur, table: str) -> str:
    if _table_has_column(cur, table, "sync_run_id"):
        return "sync_run_id"
    if _table_has_column(cur, table, "run_id"):
        return "run_id"
    raise RuntimeError(f'Missing run id column on {SCHEMA}.{table}; expected "sync_run_id" or "run_id"')


def _raw_timestamp_column(cur, table: str) -> str:
    if _table_has_column(cur, table, "snapshot_ts"):
        return "snapshot_ts"
    if _table_has_column(cur, table, "source_snapshot_ts"):
        return "source_snapshot_ts"
    raise RuntimeError(f'Missing snapshot timestamp column on {SCHEMA}.{table}')


def _start_sync_run(cur, source_key: str, phase: str) -> str:
    run_id = _new_ulid()
    cur.execute(
        f"""
        insert into "{SCHEMA}"."sync_runs" (id, source_key, status)
        values (%s, %s, %s)
        """,
        (run_id, f"{source_key}:{phase}", "running"),
    )
    return run_id


def _finish_sync_run(cur, sync_run_id: str, status: str, rows_read: int, rows_written: int, error_message: str | None = None):
    cur.execute(
        f"""
        update "{SCHEMA}"."sync_runs"
        set status = %s, ended_at = now(), rows_read = %s, rows_written = %s, error_message = %s
        where id = %s
        """,
        (status, rows_read, rows_written, error_message, sync_run_id),
    )


def _graph_session(source: dict) -> tuple[requests.Session, str, str]:
    conn = BaseHook.get_connection(source["airflow_conn_id"])
    extra = conn.extra_dejson or {}
    tenant_id = extra.get("tenant_id")
    if not tenant_id or not conn.login or not conn.password:
        raise ValueError("Graph connection must include login=client_id, password=client_secret, extra.tenant_id")
    token_url = f"https://login.microsoftonline.com/{tenant_id}/oauth2/v2.0/token"
    resp = requests.post(
        token_url,
        data={
            "client_id": conn.login,
            "client_secret": conn.password,
            "scope": "https://graph.microsoft.com/.default",
            "grant_type": "client_credentials",
        },
        timeout=30,
    )
    resp.raise_for_status()
    token = resp.json()["access_token"]
    sess = requests.Session()
    sess.headers.update({"Authorization": f"Bearer {token}"})
    return sess, extra.get("graph_base", "https://graph.microsoft.com/v1.0"), source.get("source_key", "microsoft-entra")


def _paged_get(session: requests.Session, url: str) -> list[dict]:
    rows: list[dict] = []
    next_url = url
    while next_url:
        last_exc: Exception | None = None
        r = None
        for attempt in range(5):
            try:
                r = session.get(next_url, timeout=60)
                if r.status_code in (429, 500, 502, 503, 504):
                    retry_after = r.headers.get("Retry-After")
                    sleep_s = int(retry_after) if retry_after and retry_after.isdigit() else min(2**attempt, 30)
                    time.sleep(sleep_s)
                    continue
                r.raise_for_status()
                break
            except requests.RequestException as exc:
                last_exc = exc
                if attempt == 4:
                    raise
                time.sleep(min(2**attempt, 30))
        if r is None:
            if last_exc:
                raise last_exc
            raise RuntimeError(f"Failed to GET {next_url}")
        payload = r.json()
        rows.extend(payload.get("value", []))
        next_url = payload.get("@odata.nextLink")
    return rows


def sync_users(snapshot_mode: str = "full") -> None:
    source, target_conn_id, _ = _load_config()
    pg = _pg_conn(target_conn_id)
    pg.autocommit = False
    cur = pg.cursor()
    _assert_tables(cur)
    session, graph_base, source_key = _graph_session(source)
    run_id = _start_sync_run(cur, source_key, "users")
    pg.commit()
    rows_read = rows_written = 0
    snapshot_ts = datetime.now(timezone.utc)
    try:
        users = _paged_get(
            session,
            f"{graph_base}/users?$select=id,userPrincipalName,displayName,mail,accountEnabled,createdDateTime",
        )
        for user in users:
            cur.execute(
                f"""
                insert into "{SCHEMA}"."users"
                (id, source_key, snapshot_mode, snapshot_ts, source_object_id, user_principal_name, display_name, email, enabled, created_at, sync_run_id, ingested_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now())
                """,
                (
                    _new_ulid(),
                    source_key,
                    snapshot_mode,
                    snapshot_ts,
                    user.get("id"),
                    user.get("userPrincipalName"),
                    user.get("displayName"),
                    user.get("mail"),
                    str(user.get("accountEnabled")).lower() if user.get("accountEnabled") is not None else None,
                    user.get("createdDateTime"),
                    run_id,
                ),
            )
            rows_read += 1
            rows_written += 1
        _finish_sync_run(cur, run_id, "success", rows_read, rows_written)
        pg.commit()
    except Exception as exc:
        pg.rollback()
        _finish_sync_run(cur, run_id, "failed", rows_read, rows_written, str(exc))
        pg.commit()
        raise
    finally:
        cur.close()
        pg.close()


def sync_groups_and_memberships(snapshot_mode: str = "full") -> None:
    source, target_conn_id, _ = _load_config()
    pg = _pg_conn(target_conn_id)
    pg.autocommit = False
    cur = pg.cursor()
    _assert_tables(cur)
    session, graph_base, source_key = _graph_session(source)
    run_id = _start_sync_run(cur, source_key, "groups_memberships")
    pg.commit()
    rows_read = rows_written = 0
    snapshot_ts = datetime.now(timezone.utc)
    try:
        groups = _paged_get(
            session,
            f"{graph_base}/groups?$select=id,displayName,mailEnabled,securityEnabled,createdDateTime",
        )
        for group in groups:
            group_id = group.get("id")
            cur.execute(
                f"""
                insert into "{SCHEMA}"."groups"
                (id, source_key, snapshot_mode, snapshot_ts, source_object_id, display_name, mail_enabled, security_enabled, created_at, sync_run_id, ingested_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, now())
                """,
                (
                    _new_ulid(),
                    source_key,
                    snapshot_mode,
                    snapshot_ts,
                    group_id,
                    group.get("displayName"),
                    str(group.get("mailEnabled")).lower() if group.get("mailEnabled") is not None else None,
                    str(group.get("securityEnabled")).lower() if group.get("securityEnabled") is not None else None,
                    group.get("createdDateTime"),
                    run_id,
                ),
            )
            rows_read += 1
            rows_written += 1

            if not group_id:
                continue
            members = _paged_get(session, f"{graph_base}/groups/{group_id}/members?$select=id")
            for member in members:
                cur.execute(
                    f"""
                    insert into "{SCHEMA}"."group_memberships"
                    (id, source_key, snapshot_mode, snapshot_ts, group_object_id, member_object_id, sync_run_id, ingested_at)
                    values (%s, %s, %s, %s, %s, %s, %s, now())
                    """,
                    (_new_ulid(), source_key, snapshot_mode, snapshot_ts, group_id, member.get("id"), run_id),
                )
                rows_written += 1

        _finish_sync_run(cur, run_id, "success", rows_read, rows_written)
        pg.commit()
    except Exception as exc:
        pg.rollback()
        _finish_sync_run(cur, run_id, "failed", rows_read, rows_written, str(exc))
        pg.commit()
        raise
    finally:
        cur.close()
        pg.close()


def _member_object_id(member: dict) -> str | None:
    return member.get("userId") or member.get("id")


def sync_teams_channels_memberships(snapshot_mode: str = "full") -> None:
    source, target_conn_id, _ = _load_config()
    pg = _pg_conn(target_conn_id)
    pg.autocommit = False
    cur = pg.cursor()
    _assert_tables(cur)
    session, graph_base, source_key = _graph_session(source)
    run_id = _start_sync_run(cur, source_key, "teams_channels_memberships")
    pg.commit()
    rows_read = rows_written = 0
    snapshot_ts = datetime.now(timezone.utc)
    teams_has_snapshot_mode = _table_has_column(cur, "teams", "snapshot_mode")
    channels_has_snapshot_mode = _table_has_column(cur, "channels", "snapshot_mode")
    team_memberships_has_snapshot_mode = _table_has_column(cur, "team_memberships", "snapshot_mode")
    channel_memberships_has_snapshot_mode = _table_has_column(cur, "channel_memberships", "snapshot_mode")
    teams_has_ingested_at = _table_has_column(cur, "teams", "ingested_at")
    channels_has_ingested_at = _table_has_column(cur, "channels", "ingested_at")
    team_memberships_has_ingested_at = _table_has_column(cur, "team_memberships", "ingested_at")
    channel_memberships_has_ingested_at = _table_has_column(cur, "channel_memberships", "ingested_at")
    teams_run_col = _raw_run_column(cur, "teams")
    channels_run_col = _raw_run_column(cur, "channels")
    team_memberships_run_col = _raw_run_column(cur, "team_memberships")
    channel_memberships_run_col = _raw_run_column(cur, "channel_memberships")
    try:
        teams = _paged_get(
            session,
            f"{graph_base}/groups?$filter=resourceProvisioningOptions/Any(x:x eq 'Team')&$select=id,displayName,description,visibility,createdDateTime",
        )
        for team in teams:
            team_id = team.get("id")
            if not team_id:
                continue
            cur.execute(
                (
                    f"""
                    insert into "{SCHEMA}"."teams"
                    (id, source_key, snapshot_mode, snapshot_ts, team_id, display_name, description, visibility, created_at, {teams_run_col}{', ingested_at' if teams_has_ingested_at else ''})
                    values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if teams_has_ingested_at else ''})
                    """
                    if teams_has_snapshot_mode
                    else f"""
                    insert into "{SCHEMA}"."teams"
                    (id, source_key, snapshot_ts, team_id, display_name, description, visibility, created_at, {teams_run_col}{', ingested_at' if teams_has_ingested_at else ''})
                    values (%s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if teams_has_ingested_at else ''})
                    """
                ),
                (
                    (_new_ulid(), source_key, snapshot_mode, snapshot_ts, team_id, team.get("displayName"), team.get("description"), team.get("visibility"), team.get("createdDateTime"), run_id)
                    if teams_has_snapshot_mode
                    else (_new_ulid(), source_key, snapshot_ts, team_id, team.get("displayName"), team.get("description"), team.get("visibility"), team.get("createdDateTime"), run_id)
                ),
            )
            rows_read += 1
            rows_written += 1

            team_members = _paged_get(session, f"{graph_base}/teams/{team_id}/members")
            team_member_ids: set[str] = set()
            for member in team_members:
                member_id = _member_object_id(member)
                if not member_id:
                    continue
                team_member_ids.add(member_id)
                cur.execute(
                    (
                        f"""
                        insert into "{SCHEMA}"."team_memberships"
                        (id, source_key, snapshot_mode, snapshot_ts, team_id, member_object_id, member_ref_id, roles, {team_memberships_run_col}{', ingested_at' if team_memberships_has_ingested_at else ''})
                        values (%s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if team_memberships_has_ingested_at else ''})
                        """
                        if team_memberships_has_snapshot_mode
                        else f"""
                        insert into "{SCHEMA}"."team_memberships"
                        (id, source_key, snapshot_ts, team_id, member_object_id, member_ref_id, roles, {team_memberships_run_col}{', ingested_at' if team_memberships_has_ingested_at else ''})
                        values (%s, %s, %s, %s, %s, %s, %s, %s{', now()' if team_memberships_has_ingested_at else ''})
                        """
                    ),
                    (
                        (_new_ulid(), source_key, snapshot_mode, snapshot_ts, team_id, member_id, member.get("id"), ",".join(member.get("roles", []) or []), run_id)
                        if team_memberships_has_snapshot_mode
                        else (_new_ulid(), source_key, snapshot_ts, team_id, member_id, member.get("id"), ",".join(member.get("roles", []) or []), run_id)
                    ),
                )
                rows_written += 1

            channels = _paged_get(
                session,
                f"{graph_base}/teams/{team_id}/channels?$select=id,displayName,membershipType,createdDateTime",
            )
            for channel in channels:
                channel_id = channel.get("id")
                if not channel_id:
                    continue
                membership_type = channel.get("membershipType") or "standard"
                cur.execute(
                    (
                        f"""
                        insert into "{SCHEMA}"."channels"
                        (id, source_key, snapshot_mode, snapshot_ts, team_id, channel_id, display_name, membership_type, created_at, {channels_run_col}{', ingested_at' if channels_has_ingested_at else ''})
                        values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channels_has_ingested_at else ''})
                        """
                        if channels_has_snapshot_mode
                        else f"""
                        insert into "{SCHEMA}"."channels"
                        (id, source_key, snapshot_ts, team_id, channel_id, display_name, membership_type, created_at, {channels_run_col}{', ingested_at' if channels_has_ingested_at else ''})
                        values (%s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channels_has_ingested_at else ''})
                        """
                    ),
                    (
                        (_new_ulid(), source_key, snapshot_mode, snapshot_ts, team_id, channel_id, channel.get("displayName"), membership_type, channel.get("createdDateTime"), run_id)
                        if channels_has_snapshot_mode
                        else (_new_ulid(), source_key, snapshot_ts, team_id, channel_id, channel.get("displayName"), membership_type, channel.get("createdDateTime"), run_id)
                    ),
                )
                rows_written += 1

                if membership_type.lower() == "standard":
                    for team_member_id in team_member_ids:
                        cur.execute(
                            (
                                f"""
                                insert into "{SCHEMA}"."channel_memberships"
                                (id, source_key, snapshot_mode, snapshot_ts, team_id, channel_id, member_object_id, member_ref_id, roles, {channel_memberships_run_col}{', ingested_at' if channel_memberships_has_ingested_at else ''})
                                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channel_memberships_has_ingested_at else ''})
                                """
                                if channel_memberships_has_snapshot_mode
                                else f"""
                                insert into "{SCHEMA}"."channel_memberships"
                                (id, source_key, snapshot_ts, team_id, channel_id, member_object_id, member_ref_id, roles, {channel_memberships_run_col}{', ingested_at' if channel_memberships_has_ingested_at else ''})
                                values (%s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channel_memberships_has_ingested_at else ''})
                                """
                            ),
                            (
                                (_new_ulid(), source_key, snapshot_mode, snapshot_ts, team_id, channel_id, team_member_id, None, None, run_id)
                                if channel_memberships_has_snapshot_mode
                                else (_new_ulid(), source_key, snapshot_ts, team_id, channel_id, team_member_id, None, None, run_id)
                            ),
                        )
                        rows_written += 1
                    continue

                try:
                    channel_members = _paged_get(session, f"{graph_base}/teams/{team_id}/channels/{channel_id}/members")
                except requests.RequestException:
                    # Graph can intermittently fail per-channel member lookups; keep ingest moving.
                    channel_members = []
                for member in channel_members:
                    member_id = _member_object_id(member)
                    if not member_id:
                        continue
                    cur.execute(
                        (
                            f"""
                            insert into "{SCHEMA}"."channel_memberships"
                            (id, source_key, snapshot_mode, snapshot_ts, team_id, channel_id, member_object_id, member_ref_id, roles, {channel_memberships_run_col}{', ingested_at' if channel_memberships_has_ingested_at else ''})
                            values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channel_memberships_has_ingested_at else ''})
                            """
                            if channel_memberships_has_snapshot_mode
                            else f"""
                            insert into "{SCHEMA}"."channel_memberships"
                            (id, source_key, snapshot_ts, team_id, channel_id, member_object_id, member_ref_id, roles, {channel_memberships_run_col}{', ingested_at' if channel_memberships_has_ingested_at else ''})
                            values (%s, %s, %s, %s, %s, %s, %s, %s, %s{', now()' if channel_memberships_has_ingested_at else ''})
                            """
                        ),
                        (
                            (_new_ulid(), source_key, snapshot_mode, snapshot_ts, team_id, channel_id, member_id, member.get("id"), ",".join(member.get("roles", []) or []), run_id)
                            if channel_memberships_has_snapshot_mode
                            else (_new_ulid(), source_key, snapshot_ts, team_id, channel_id, member_id, member.get("id"), ",".join(member.get("roles", []) or []), run_id)
                        ),
                    )
                    rows_written += 1

        _finish_sync_run(cur, run_id, "success", rows_read, rows_written)
        pg.commit()
    except Exception as exc:
        pg.rollback()
        _finish_sync_run(cur, run_id, "failed", rows_read, rows_written, str(exc))
        pg.commit()
        raise
    finally:
        cur.close()
        pg.close()


def merge_to_ods() -> None:
    source, raw_conn_id, ods_conn_id = _load_config()
    source_key = source.get("source_key", "microsoft-entra")

    raw_pg = _pg_conn(raw_conn_id)
    raw_pg.autocommit = False
    raw_cur = raw_pg.cursor()
    ods_pg = _pg_conn(ods_conn_id)
    ods_pg.autocommit = False
    ods_cur = ods_pg.cursor()
    try:
        users_run_col = _raw_run_column(raw_cur, "users")
        groups_run_col = _raw_run_column(raw_cur, "groups")
        group_memberships_run_col = _raw_run_column(raw_cur, "group_memberships")
        teams_run_col = _raw_run_column(raw_cur, "teams")
        channels_run_col = _raw_run_column(raw_cur, "channels")
        team_memberships_run_col = _raw_run_column(raw_cur, "team_memberships")
        channel_memberships_run_col = _raw_run_column(raw_cur, "channel_memberships")

        users_ts_col = _raw_timestamp_column(raw_cur, "users")
        groups_ts_col = _raw_timestamp_column(raw_cur, "groups")
        group_memberships_ts_col = _raw_timestamp_column(raw_cur, "group_memberships")
        teams_ts_col = _raw_timestamp_column(raw_cur, "teams")
        channels_ts_col = _raw_timestamp_column(raw_cur, "channels")
        team_memberships_ts_col = _raw_timestamp_column(raw_cur, "team_memberships")
        channel_memberships_ts_col = _raw_timestamp_column(raw_cur, "channel_memberships")

        ods_cur.execute(
            """
            select to_regclass('m365.users'),
                   to_regclass('m365.groups'),
                   to_regclass('m365.group_memberships'),
                   to_regclass('m365.teams'),
                   to_regclass('m365.channels'),
                   to_regclass('m365.team_memberships'),
                   to_regclass('m365.channel_memberships')
            """
        )
        row = ods_cur.fetchone()
        if not row or any(x is None for x in row):
            raise RuntimeError("Missing ODS m365 tables. Run Alembic on ods DB.")

        raw_cur.execute(
            f"""
            select id from "{SCHEMA}"."sync_runs"
            where source_key = %s and status = 'success'
            order by started_at desc
            limit 1
            """,
            (f"{source_key}:users",),
        )
        user_run = raw_cur.fetchone()
        raw_cur.execute(
            f"""
            select id from "{SCHEMA}"."sync_runs"
            where source_key = %s and status = 'success'
            order by started_at desc
            limit 1
            """,
            (f"{source_key}:groups_memberships",),
        )
        group_run = raw_cur.fetchone()
        if not user_run or not group_run:
            raise RuntimeError("No successful raw sync runs found to merge into ODS.")

        user_run_id = user_run[0]
        group_run_id = group_run[0]
        raw_cur.execute(
            f"""
            select id from "{SCHEMA}"."sync_runs"
            where source_key = %s and status = 'success'
            order by started_at desc
            limit 1
            """,
            (f"{source_key}:teams_channels_memberships",),
        )
        teams_run = raw_cur.fetchone()
        if not teams_run:
            raise RuntimeError("No successful teams/channels raw sync run found to merge into ODS.")
        teams_run_id = teams_run[0]

        raw_cur.execute(
            f"""
            select id, source_key, source_object_id, user_principal_name, display_name, email, enabled, created_at, {users_ts_col}
            from "{SCHEMA}"."users"
            where {users_run_col} = %s
            """,
            (user_run_id,),
        )
        user_rows = raw_cur.fetchall()
        for row in user_rows:
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."users"
                (id, source_key, source_object_id, user_principal_name, display_name, email, enabled, created_at, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, source_object_id) do update
                set user_principal_name = excluded.user_principal_name,
                    display_name = excluded.display_name,
                    email = excluded.email,
                    enabled = excluded.enabled,
                    created_at = excluded.created_at,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                row,
            )

        raw_cur.execute(
            f"""
            select id, source_key, source_object_id, display_name, mail_enabled, security_enabled, created_at, {groups_ts_col}
            from "{SCHEMA}"."groups"
            where {groups_run_col} = %s
            """,
            (group_run_id,),
        )
        group_rows = raw_cur.fetchall()
        for row in group_rows:
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."groups"
                (id, source_key, source_object_id, display_name, mail_enabled, security_enabled, created_at, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, source_object_id) do update
                set display_name = excluded.display_name,
                    mail_enabled = excluded.mail_enabled,
                    security_enabled = excluded.security_enabled,
                    created_at = excluded.created_at,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                row,
            )

        ods_cur.execute(f"""delete from "{SCHEMA}"."group_memberships" where source_key = %s""", (source_key,))
        raw_cur.execute(
            f"""
            select id, source_key, group_object_id, member_object_id, {group_memberships_ts_col}
            from "{SCHEMA}"."group_memberships"
            where {group_memberships_run_col} = %s
            """,
            (group_run_id,),
        )
        membership_rows = raw_cur.fetchall()
        for row in membership_rows:
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."group_memberships"
                (id, source_key, group_object_id, member_object_id, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, now())
                """,
                row,
            )

        raw_cur.execute(
            f"""
            select id, source_key, team_id, display_name, description, visibility, created_at, {teams_ts_col}
            from "{SCHEMA}"."teams"
            where {teams_run_col} = %s
            """,
            (teams_run_id,),
        )
        for row in raw_cur.fetchall():
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."teams"
                (id, source_key, team_id, display_name, description, visibility, created_at, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, team_id) do update
                set display_name = excluded.display_name,
                    description = excluded.description,
                    visibility = excluded.visibility,
                    created_at = excluded.created_at,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                row,
            )

        raw_cur.execute(
            f"""
            select id, source_key, team_id, channel_id, display_name, membership_type, created_at, {channels_ts_col}
            from "{SCHEMA}"."channels"
            where {channels_run_col} = %s
            """,
            (teams_run_id,),
        )
        for row in raw_cur.fetchall():
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."channels"
                (id, source_key, team_id, channel_id, display_name, membership_type, created_at, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, team_id, channel_id) do update
                set display_name = excluded.display_name,
                    membership_type = excluded.membership_type,
                    created_at = excluded.created_at,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                row,
            )

        ods_cur.execute(f"""delete from "{SCHEMA}"."team_memberships" where source_key = %s""", (source_key,))
        raw_cur.execute(
            f"""
            select id, source_key, team_id, member_object_id, member_ref_id, roles, {team_memberships_ts_col}
            from "{SCHEMA}"."team_memberships"
            where {team_memberships_run_col} = %s
            """,
            (teams_run_id,),
        )
        for row in raw_cur.fetchall():
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."team_memberships"
                (id, source_key, team_id, member_object_id, member_ref_id, roles, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, team_id, member_object_id) do update
                set member_ref_id = excluded.member_ref_id,
                    roles = excluded.roles,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                row,
            )

        ods_cur.execute(f"""delete from "{SCHEMA}"."channel_memberships" where source_key = %s""", (source_key,))
        raw_cur.execute(
            f"""
            select id, source_key, team_id, channel_id, member_object_id, member_ref_id, roles, {channel_memberships_ts_col}
            from "{SCHEMA}"."channel_memberships"
            where {channel_memberships_run_col} = %s
            """,
            (teams_run_id,),
        )
        for row in raw_cur.fetchall():
            _, _, team_id, channel_id, member_object_id, _, _, _ = row
            ods_cur.execute(
                f"""
                select membership_type from "{SCHEMA}"."channels"
                where source_key = %s and team_id = %s and channel_id = %s
                """,
                (source_key, team_id, channel_id),
            )
            channel_row = ods_cur.fetchone()
            is_inherited = bool(channel_row and (channel_row[0] or "").lower() == "standard")
            ods_cur.execute(
                f"""
                insert into "{SCHEMA}"."channel_memberships"
                (id, source_key, team_id, channel_id, member_object_id, member_ref_id, roles, is_inherited, source_snapshot_ts, updated_at)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, now())
                on conflict (source_key, team_id, channel_id, member_object_id) do update
                set member_ref_id = excluded.member_ref_id,
                    roles = excluded.roles,
                    is_inherited = excluded.is_inherited,
                    source_snapshot_ts = excluded.source_snapshot_ts,
                    updated_at = now()
                """,
                (
                    row[0],
                    row[1],
                    row[2],
                    row[3],
                    row[4],
                    row[5],
                    row[6],
                    is_inherited,
                    row[7],
                ),
            )
        ods_pg.commit()
    finally:
        raw_cur.close()
        raw_pg.close()
        ods_cur.close()
        ods_pg.close()


with DAG(
    dag_id="m365_full_snapshot",
    description="M365 full snapshot to raw.",
    schedule="0 3 * * 0",
    start_date=datetime(2026, 5, 19, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["m365", "identity", "raw", "full_snapshot"],
) as m365_full_snapshot:
    sync_users_task = PythonOperator(task_id="sync_users", python_callable=sync_users, op_kwargs={"snapshot_mode": "full"})
    sync_groups_task = PythonOperator(
        task_id="sync_groups_memberships",
        python_callable=sync_groups_and_memberships,
        op_kwargs={"snapshot_mode": "full"},
    )
    sync_collab_task = PythonOperator(
        task_id="sync_teams_channels_memberships",
        python_callable=sync_teams_channels_memberships,
        op_kwargs={"snapshot_mode": "full"},
    )
    trigger_process = TriggerDagRunOperator(
        task_id="trigger_process_snapshots",
        trigger_dag_id="m365_process_snapshots",
        wait_for_completion=False,
    )
    sync_users_task >> sync_groups_task >> sync_collab_task >> trigger_process


with DAG(
    dag_id="m365_incremental_snapshot",
    description="M365 incremental snapshot to raw.",
    schedule="0 * * * *",
    start_date=datetime(2026, 5, 19, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["m365", "identity", "raw", "incremental_snapshot"],
) as m365_incremental_snapshot:
    sync_users_incremental_task = PythonOperator(
        task_id="sync_users",
        python_callable=sync_users,
        op_kwargs={"snapshot_mode": "incremental"},
    )
    sync_groups_incremental_task = PythonOperator(
        task_id="sync_groups_memberships",
        python_callable=sync_groups_and_memberships,
        op_kwargs={"snapshot_mode": "incremental"},
    )
    sync_collab_incremental_task = PythonOperator(
        task_id="sync_teams_channels_memberships",
        python_callable=sync_teams_channels_memberships,
        op_kwargs={"snapshot_mode": "incremental"},
    )
    trigger_process = TriggerDagRunOperator(
        task_id="trigger_process_snapshots",
        trigger_dag_id="m365_process_snapshots",
        wait_for_completion=False,
    )
    sync_users_incremental_task >> sync_groups_incremental_task >> sync_collab_incremental_task >> trigger_process


with DAG(
    dag_id="m365_process_snapshots",
    description="Process M365 raw snapshots into ODS merged state.",
    schedule=None,
    start_date=datetime(2026, 5, 19, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    default_args={"owner": "platform", "retries": 1, "retry_delay": timedelta(minutes=5)},
    tags=["m365", "identity", "ods", "process_snapshots"],
) as m365_process_snapshots:
    merge_to_ods_task = PythonOperator(task_id="merge_to_ods", python_callable=merge_to_ods)
    done = EmptyOperator(task_id="done")
    merge_to_ods_task >> done
