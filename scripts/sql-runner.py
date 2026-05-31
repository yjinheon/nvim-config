#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "clickhouse-connect>=0.8.0",
#   "duckdb>=1.0.0",
#   "psycopg[binary]>=3.1.0",
#   "pymysql>=1.1.0",
#   "tabulate>=0.9.0",
# ]
# ///

from __future__ import annotations

import argparse
import json
import os
import sqlite3
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib.parse import urlparse, unquote

from tabulate import tabulate


CONFIG_PATH = Path(os.environ.get("NVIM_SQL_RUNNER_CONFIG", "~/.config/nvim/sql-runner.json")).expanduser()


@dataclass(frozen=True)
class ConnectionConfig:
    name: str
    driver: str
    values: dict[str, Any]


def load_config(path: Path, selected: str | None) -> ConnectionConfig:
    if not path.exists():
        raise SystemExit(
            f"config not found: {path}\n"
            "copy scripts/sql-runner.example.json to ~/.config/nvim/sql-runner.json and edit it"
        )

    with path.open("r", encoding="utf-8") as f:
        config = json.load(f)

    connections = config.get("connections", {})
    name = selected or config.get("current")
    if not name:
        raise SystemExit("no connection selected: set `current` in config or pass --connection")
    if name not in connections:
        raise SystemExit(f"connection not found: {name}")

    values = connections[name]
    driver = values.get("driver")
    if not driver:
        raise SystemExit(f"connection `{name}` is missing `driver`")

    return ConnectionConfig(name=name, driver=driver, values=values)


def read_sql(path: str | None) -> str:
    if path:
        return Path(path).read_text(encoding="utf-8")
    return sys.stdin.read()


def connect(conn: ConnectionConfig):
    driver = conn.driver.lower()

    if driver == "sqlite":
        database = conn.values.get("database")
        if not database:
            raise SystemExit(f"connection `{conn.name}` is missing `database`")
        return sqlite3.connect(str(Path(database).expanduser()))

    if driver == "duckdb":
        import duckdb

        database = conn.values.get("database", ":memory:")
        return duckdb.connect(str(Path(database).expanduser()) if database != ":memory:" else database)

    if driver in {"postgres", "postgresql"}:
        import psycopg

        dsn = conn.values.get("dsn")
        if not dsn:
            raise SystemExit(f"connection `{conn.name}` is missing `dsn`")
        return psycopg.connect(dsn)

    if driver in {"mysql", "mariadb"}:
        import pymysql

        if conn.values.get("dsn"):
            parsed = urlparse(conn.values["dsn"])
            return pymysql.connect(
                host=parsed.hostname or "localhost",
                port=parsed.port or 3306,
                user=unquote(parsed.username or ""),
                password=unquote(parsed.password or ""),
                database=parsed.path.lstrip("/") or None,
                charset=conn.values.get("charset", "utf8mb4"),
            )
        return pymysql.connect(
            host=conn.values.get("host", "localhost"),
            port=int(conn.values.get("port", 3306)),
            user=conn.values.get("user"),
            password=conn.values.get("password"),
            database=conn.values.get("database"),
            charset=conn.values.get("charset", "utf8mb4"),
        )

    if driver == "clickhouse":
        import clickhouse_connect

        dsn = conn.values.get("dsn")
        if dsn:
            parsed = urlparse(dsn)
            return clickhouse_connect.get_client(
                host=parsed.hostname or "localhost",
                port=parsed.port or (8443 if parsed.scheme == "https" else 8123),
                username=unquote(parsed.username or "default"),
                password=unquote(parsed.password or ""),
                database=parsed.path.lstrip("/") or conn.values.get("database", "default"),
                secure=parsed.scheme == "https",
            )

        return clickhouse_connect.get_client(
            host=conn.values.get("host", "localhost"),
            port=int(conn.values.get("port", 8123)),
            username=conn.values.get("username", conn.values.get("user", "default")),
            password=conn.values.get("password", ""),
            database=conn.values.get("database", "default"),
            secure=bool(conn.values.get("secure", False)),
        )

    raise SystemExit(f"unsupported driver: {conn.driver}")


def is_result_query(sql: str) -> bool:
    first = sql.lstrip().split(None, 1)[0].lower()
    return first in {"select", "with", "show", "describe", "desc", "explain"}


def run_clickhouse(db: Any, sql: str, limit: int) -> None:
    settings = {
        "max_result_rows": limit + 1,
        "result_overflow_mode": "break",
    }

    if is_result_query(sql):
        result = db.query(sql, settings=settings)
        rows = result.result_rows[: limit + 1]
        shown = rows[:limit]
        print(tabulate(shown, headers=result.column_names, tablefmt="psql"))
        if len(rows) > limit:
            print(f"\n... truncated after {limit} rows")
        return

    result = db.command(sql)
    print(result if result not in (None, "") else "OK")


def run_sql(conn: ConnectionConfig, sql: str, limit: int) -> int:
    started = time.perf_counter()
    db = connect(conn)

    try:
        if conn.driver.lower() == "clickhouse":
            run_clickhouse(db, sql, limit)
            elapsed_ms = int((time.perf_counter() - started) * 1000)
            print(f"\n[{conn.name}] done in {elapsed_ms} ms")
            return 0

        cursor = db.cursor()
        cursor.execute(sql)

        if cursor.description:
            headers = [col[0] for col in cursor.description]
            rows = cursor.fetchmany(limit + 1)
            shown = rows[:limit]
            print(tabulate(shown, headers=headers, tablefmt="psql"))
            if len(rows) > limit:
                print(f"\n... truncated after {limit} rows")
        else:
            db.commit()
            rowcount = cursor.rowcount
            if rowcount == -1:
                print("OK")
            else:
                print(f"OK, {rowcount} rows affected")
    finally:
        close = getattr(db, "close", None)
        if close:
            close()

    elapsed_ms = int((time.perf_counter() - started) * 1000)
    print(f"\n[{conn.name}] done in {elapsed_ms} ms")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Run SQL with a configured connection")
    parser.add_argument("file", nargs="?", help="SQL file. Reads stdin when omitted.")
    parser.add_argument("-c", "--connection", help="Connection name from config")
    parser.add_argument("--config", default=str(CONFIG_PATH), help="Path to config JSON")
    parser.add_argument("--limit", type=int, default=200, help="Maximum rows to print")
    args = parser.parse_args()

    sql = read_sql(args.file).strip()
    if not sql:
        raise SystemExit("empty SQL")

    conn = load_config(Path(args.config).expanduser(), args.connection)
    return run_sql(conn, sql, args.limit)


if __name__ == "__main__":
    raise SystemExit(main())
