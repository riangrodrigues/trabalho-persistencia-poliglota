"""Demonstração Python do Requisito R5 no Cassandra (Eventos de Reprodução em Alto Volume)."""

from __future__ import annotations

import os
import sys
import uuid
from datetime import datetime, timezone
from typing import Any

from cassandra.cluster import Cluster
from cassandra.util import uuid_from_time


def configure_utf8_stdio() -> None:
    """Garante saída UTF-8 no terminal Windows sem erros de encoding."""
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")


def print_header(title: str) -> None:
    """Imprime cabeçalho padronizado para uma seção."""
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def print_table(headers: list[str], rows: list[tuple[Any, ...]]) -> None:
    """Formata resultados CQL como tabela alinhada em texto simples."""
    str_rows = [[str(col) for col in row] for row in rows]
    widths = [
        max([len(headers[i])] + [len(r[i]) for r in str_rows])
        for i in range(len(headers))
    ]
    fmt = " | ".join(f"{{:<{w}}}" for w in widths)
    print(fmt.format(*headers))
    print("-+-".join("-" * w for w in widths))
    for row in str_rows:
        print(fmt.format(*row))
    print(f"({len(str_rows)} linhas)")


def op1_historico_usuario_bucket(session: Any, usuario_id: uuid.UUID) -> None:
    """OP 1: Histórico mensal completo de um usuário usando a Partition Key exata."""
    print("\n--- [OP 1] Histórico completo de João Silva em 2026-11 (eventos_por_usuario) ---")
    query = """
        SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
        FROM eventos_por_usuario
        WHERE usuario_id = %s AND ano_mes = %s
    """
    rows = list(session.execute(query, (usuario_id, "2026-11")))
    if not rows:
        raise RuntimeError("Nenhum evento encontrado para o usuário em 2026-11. Rode carga.cql antes.")

    print_table(
        ["evento_ts", "titulo_conteudo", "tipo_evento", "posicao_segundos", "dispositivo"],
        [(r.evento_ts.isoformat(), r.titulo_conteudo, r.tipo_evento, r.posicao_segundos, r.dispositivo) for r in rows],
    )


def op2_recorte_temporal_clustering(session: Any, usuario_id: uuid.UUID) -> None:
    """OP 2: Filtra intervalo de tempo dentro da partição usando a Clustering Key (evento_ts)."""
    print("\n--- [OP 2] Eventos de João Silva no dia 2026-11-18 (range na clustering key) ---")
    query = """
        SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
        FROM eventos_por_usuario
        WHERE usuario_id = %s
          AND ano_mes = %s
          AND evento_ts >= %s
          AND evento_ts <= %s
    """
    inicio = datetime(2026, 11, 18, 0, 0, 0, tzinfo=timezone.utc)
    fim = datetime(2026, 11, 18, 23, 59, 59, tzinfo=timezone.utc)
    rows = list(session.execute(query, (usuario_id, "2026-11", inicio, fim)))

    print_table(
        ["evento_ts", "titulo_conteudo", "tipo_evento", "posicao_segundos", "dispositivo"],
        [(r.evento_ts.isoformat(), r.titulo_conteudo, r.tipo_evento, r.posicao_segundos, r.dispositivo) for r in rows],
    )


def op3_auditoria_por_conteudo(session: Any, conteudo_id: uuid.UUID) -> None:
    """OP 3: Consulta tabela denormalizada eventos_por_conteudo para análise de abandono."""
    print("\n--- [OP 3] Auditoria de eventos de 'Interestelar' em 2026-11-18 (eventos_por_conteudo) ---")
    query = """
        SELECT evento_ts, usuario_id, tipo_evento, posicao_segundos, dispositivo
        FROM eventos_por_conteudo
        WHERE conteudo_id = %s AND data_dia = %s
    """
    rows = list(session.execute(query, (conteudo_id, "2026-11-18")))
    print_table(
        ["evento_ts", "usuario_id", "tipo_evento", "posicao_segundos", "dispositivo"],
        [(r.evento_ts.isoformat(), r.usuario_id, r.tipo_evento, r.posicao_segundos, r.dispositivo) for r in rows],
    )


def op4_escrita_tempo_real(session: Any, usuario_id: uuid.UUID, conteudo_id: uuid.UUID) -> None:
    """OP 4: Escrita append-only em LSM-Tree e leitura imediata dos 5 eventos mais recentes."""
    print("\n--- [OP 4] Escrita append-only em tempo real + leitura dos 5 eventos mais recentes ---")
    ts_evento = datetime(2026, 11, 21, 15, 0, 0, tzinfo=timezone.utc)
    evento_id = uuid_from_time(ts_evento)

    insert_cql = """
        INSERT INTO eventos_por_usuario (
            usuario_id, ano_mes, evento_ts, evento_id,
            conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    session.execute(
        insert_cql,
        (usuario_id, "2026-11", ts_evento, evento_id, conteudo_id, "Dark", "play", 0, "Smart TV"),
    )

    select_cql = """
        SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
        FROM eventos_por_usuario
        WHERE usuario_id = %s AND ano_mes = %s
        LIMIT 5
    """
    rows = list(session.execute(select_cql, (usuario_id, "2026-11")))
    print_table(
        ["evento_ts", "titulo_conteudo", "tipo_evento", "posicao_segundos", "dispositivo"],
        [(r.evento_ts.isoformat(), r.titulo_conteudo, r.tipo_evento, r.posicao_segundos, r.dispositivo) for r in rows],
    )


def main() -> int:
    configure_utf8_stdio()
    host = os.getenv("CASSANDRA_HOST", "127.0.0.1")
    port = int(os.getenv("CASSANDRA_PORT", "9042"))
    keyspace = os.getenv("CASSANDRA_KEYSPACE", "streaming")

    joao_id = uuid.UUID("11111111-1111-4111-8111-000000000001")
    interestelar_id = uuid.UUID("22222222-2222-4222-8222-000000000001")
    dark_id = uuid.UUID("22222222-2222-4222-8222-000000000008")

    print_header("DEMONSTRAÇÃO CASSANDRA — REQUISITO R5 (EVENTOS EM ALTO VOLUME)")
    print(f"Conectando em: {host}:{port} (keyspace: {keyspace})")

    cluster = Cluster([host], port=port)
    try:
        session = cluster.connect(keyspace)
        op1_historico_usuario_bucket(session, joao_id)
        op2_recorte_temporal_clustering(session, joao_id)
        op3_auditoria_por_conteudo(session, interestelar_id)
        op4_escrita_tempo_real(session, joao_id, dark_id)
    finally:
        cluster.shutdown()

    print("\n=== [Cassandra] Demonstração R5 concluída com sucesso! ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
