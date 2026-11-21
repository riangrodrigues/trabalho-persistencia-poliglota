"""Orquestrador principal do ambiente UniStream (Docker + carga + demonstrações)."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
SCRIPTS_DIR = ROOT_DIR / "scripts"
OUTPUTS_DIR = ROOT_DIR / "outputs"

ALL_CONTAINERS = (
    "streaming-postgres",
    "streaming-redis",
    "streaming-mongodb",
    "streaming-cassandra",
    "streaming-neo4j",
)


def configure_utf8_stdio() -> None:
    """Garante saída UTF-8 no terminal Windows sem erros de encoding."""
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")


def run_cmd(cmd: list[str], capture_to: Path | None = None) -> tuple[int, str]:
    """Executa um comando externo em UTF-8 e opcionalmente salva a saída em arquivo."""
    env = {**os.environ, "PYTHONIOENCODING": "utf-8"}
    proc = subprocess.run(
        cmd,
        cwd=str(ROOT_DIR),
        env=env,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    combined = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    if combined.strip():
        print(combined.rstrip())
    if capture_to is not None:
        capture_to.parent.mkdir(parents=True, exist_ok=True)
        capture_to.write_text(combined, encoding="utf-8")
    return proc.returncode, combined


def get_container_health(container_name: str) -> str:
    """Consulta o status de saúde/execução de um container Docker."""
    proc = subprocess.run(
        [
            "docker",
            "inspect",
            "--format",
            "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}",
            container_name,
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if proc.returncode != 0:
        return "not_found"
    return proc.stdout.strip()


def wait_for_containers(timeout_seconds: int = 150) -> dict[str, str]:
    """Aguarda todos os cinco containers atingirem estado saudável."""
    print(f"=== Verificando saúde dos 5 containers (timeout: {timeout_seconds}s) ===")
    deadline = time.monotonic() + timeout_seconds
    statuses: dict[str, str] = {}

    while True:
        statuses = {c: get_container_health(c) for c in ALL_CONTAINERS}
        if all(st == "healthy" for st in statuses.values()):
            break
        if any(st in ("not_found", "exited", "dead") for st in statuses.values()):
            break
        if time.monotonic() >= deadline:
            break
        pendentes = [f"{k}={v}" for k, v in statuses.items() if v != "healthy"]
        print(f"Aguardando containers: {', '.join(pendentes)}...")
        time.sleep(5)

    for name, st in statuses.items():
        print(f"  - {name}: {st}")
    return statuses


def run_seed_step(label: str, cmd: list[str]) -> bool:
    """Executa um script nativo de criação ou carga via docker exec."""
    print(f"\n>>> [{label}] Executando: {' '.join(cmd)}")
    rc, _ = run_cmd(cmd)
    if rc != 0:
        print(f"[ERRO] Falha em {label} (exit={rc})")
        return False
    return True


def run_optional_postgres() -> str:
    """Detecta e executa scripts de PostgreSQL do colega se já existirem."""
    pg_dir = ROOT_DIR / "postgres"
    expected = ["criacao.sql", "carga.sql", "demonstracao.sql"]
    present = [f for f in expected if (pg_dir / f).is_file()]
    if not present:
        print("\n[AGUARDANDO PARTE DO COLEGA] Nenhum script .sql encontrado em postgres/.")
        return "PENDENTE (colega)"

    for filename in present:
        cmd = [
            "docker",
            "exec",
            "streaming-postgres",
            "psql",
            "-U",
            os.getenv("POSTGRES_USER", "admin"),
            "-d",
            os.getenv("POSTGRES_DB", "streaming"),
            "-v",
            "ON_ERROR_STOP=1",
            "-f",
            f"/scripts/postgres/{filename}",
        ]
        capture = OUTPUTS_DIR / "demonstracao_postgres.txt" if filename == "demonstracao.sql" else None
        print(f"\n>>> [PostgreSQL] Executando {filename}")
        rc, _ = run_cmd(cmd, capture_to=capture)
        if rc != 0:
            return "FAIL"
    return "PASS"


def run_optional_redis() -> str:
    """Detecta e executa scripts de Redis do colega se já existirem."""
    rd_dir = ROOT_DIR / "redis"
    candidates = [
        ("criacao", ["criacao.txt", "criacao.redis"]),
        ("carga", ["carga.txt", "carga.redis"]),
        ("demonstracao", ["demonstracao.txt", "demonstracao.redis"]),
    ]
    found_files: list[tuple[str, str]] = []
    for stage, names in candidates:
        for name in names:
            if (rd_dir / name).is_file():
                found_files.append((stage, name))
                break

    if not found_files:
        print("\n[AGUARDANDO PARTE DO COLEGA] Nenhum script .txt/.redis encontrado em redis/.")
        return "PENDENTE (colega)"

    for stage, filename in found_files:
        cmd = [
            "docker",
            "exec",
            "streaming-redis",
            "sh",
            "-c",
            f"redis-cli < /scripts/redis/{filename}",
        ]
        capture = OUTPUTS_DIR / "demonstracao_redis.txt" if stage == "demonstracao" else None
        print(f"\n>>> [Redis] Executando {filename}")
        rc, _ = run_cmd(cmd, capture_to=capture)
        if rc != 0:
            return "FAIL"
    return "PASS"


def main() -> int:
    configure_utf8_stdio()
    parser = argparse.ArgumentParser(description="Orquestrador UniStream (Persistência Poliglota).")
    parser.add_argument(
        "--skip-seed",
        action="store_true",
        help="Pula criação/carga nativa e executa apenas os scripts de demonstração.",
    )
    args = parser.parse_args()

    statuses = wait_for_containers()
    if not all(st == "healthy" for st in statuses.values()):
        print("\n[ERRO] Nem todos os containers estão saudáveis. Rode: docker compose up -d")
        return 1

    results: dict[str, str] = {}

    if not args.skip_seed:
        print("\n=== Executando scripts nativos de criação e carga ===")
        seed_jobs = [
            (
                "MongoDB",
                [
                    ["docker", "exec", "streaming-mongodb", "mongosh", "--quiet", "streaming", "/scripts/mongodb/criacao.js"],
                    ["docker", "exec", "streaming-mongodb", "mongosh", "--quiet", "streaming", "/scripts/mongodb/carga.js"],
                ],
            ),
            (
                "Cassandra",
                [
                    ["docker", "exec", "streaming-cassandra", "cqlsh", "--request-timeout=60", "-f", "/scripts/cassandra/criacao.cql"],
                    ["docker", "exec", "streaming-cassandra", "cqlsh", "--request-timeout=60", "-f", "/scripts/cassandra/carga.cql"],
                ],
            ),
            (
                "Neo4j",
                [
                    ["docker", "exec", "streaming-neo4j", "cypher-shell", "-u", "neo4j", "-p", "senha123", "-f", "/scripts/neo4j/criacao.cypher"],
                    ["docker", "exec", "streaming-neo4j", "cypher-shell", "-u", "neo4j", "-p", "senha123", "-f", "/scripts/neo4j/carga.cypher"],
                ],
            ),
        ]
        for db_label, commands in seed_jobs:
            ok = all(run_seed_step(db_label, c) for c in commands)
            if not ok:
                results[db_label] = "FAIL (seed)"

    print("\n=== Executando demonstrações Python (MongoDB, Cassandra, Neo4j) ===")
    demo_jobs = [
        ("MongoDB", SCRIPTS_DIR / "demo_mongodb.py", OUTPUTS_DIR / "demonstracao_mongodb.txt"),
        ("Cassandra", SCRIPTS_DIR / "demo_cassandra.py", OUTPUTS_DIR / "demonstracao_cassandra.txt"),
        ("Neo4j", SCRIPTS_DIR / "demo_neo4j.py", OUTPUTS_DIR / "demonstracao_neo4j.txt"),
    ]
    for db_label, script_path, output_path in demo_jobs:
        if db_label in results:
            continue
        rc, _ = run_cmd([sys.executable, str(script_path)], capture_to=output_path)
        results[db_label] = "PASS" if rc == 0 else "FAIL (demo)"

    results["PostgreSQL"] = run_optional_postgres()
    results["Redis"] = run_optional_redis()

    print("\n" + "=" * 72)
    print("RESUMO DA EXECUÇÃO — UNISTREAM (PERSISTÊNCIA POLIGLOTA)")
    print("=" * 72)
    for db_label in ("PostgreSQL", "Redis", "MongoDB", "Cassandra", "Neo4j"):
        print(f"  {db_label:<12}: {results.get(db_label, 'N/A')}")
    print(f"Saídas salvas em: {OUTPUTS_DIR}")

    failed = any(status.startswith("FAIL") for status in results.values())
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
