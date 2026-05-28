from __future__ import annotations

import json
import os

from airflow.models import Connection, Variable
from airflow.settings import Session


def upsert_connection(session: Session, conn_id: str, uri: str) -> None:
    if not conn_id or not uri:
        return
    existing = session.query(Connection).filter(Connection.conn_id == conn_id).one_or_none()
    parsed = Connection(conn_id=conn_id, uri=uri)
    if existing:
        existing.conn_type = parsed.conn_type
        existing.host = parsed.host
        existing.login = parsed.login
        existing.password = parsed.password
        existing.schema = parsed.schema
        existing.port = parsed.port
        existing.extra = parsed.extra
        return
    session.add(parsed)


def main() -> None:
    target_conn_id = os.environ.get("ADDS_TARGET_CONN_ID", "postgres_raw")
    target_uri = os.environ.get("ADDS_TARGET_DB_URI", "")
    sources_json = os.environ.get("ADDS_SOURCES_JSON", "[]")
    connections_json = os.environ.get("ADDS_CONNECTIONS_JSON", "[]")

    sources = json.loads(sources_json)
    conn_specs = json.loads(connections_json)

    session = Session()
    upsert_connection(session, target_conn_id, target_uri)
    for spec in conn_specs:
        upsert_connection(session, spec.get("conn_id", ""), spec.get("uri", ""))

    Variable.set("ad_sources", json.dumps(sources), serialize_json=False)
    Variable.set("adds_target_conn_id", target_conn_id)
    session.commit()
    session.close()
    print(
        f"Bootstrapped ADDS target connection '{target_conn_id}', "
        f"{len(conn_specs)} AD connection(s), and {len(sources)} source mapping(s)."
    )


if __name__ == "__main__":
    main()
