"""Demonstração Python do Requisito R6 no Neo4j (Recomendações por Grafo)."""

from __future__ import annotations

import os
import sys
from typing import Any

from neo4j import GraphDatabase


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


def print_records(records: list[dict[str, Any]]) -> None:
    """Exibe lista de registros retornados pelo Cypher de forma tabular."""
    if not records:
        print("(0 resultados)")
        return

    headers = list(records[0].keys())
    str_rows = [[str(rec[h]) for h in headers] for rec in records]
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


def run_cypher(driver: Any, query: str, params: dict[str, Any] | None = None) -> list[dict[str, Any]]:
    """Executa uma consulta Cypher somente leitura e retorna lista de dicionários."""
    with driver.session() as session:
        result = session.run(query, params or {})
        return [record.data() for record in result]


def op1_quem_assistiu_tambem_assistiu(driver: Any) -> None:
    """OP 1 (R6 Parte 1): 'Quem assistiu Interestelar também assistiu...' (2 saltos)."""
    print("\n--- [OP 1] R6 Parte 1: 'Quem assistiu Interestelar também assistiu...' ---")
    query = """
        MATCH (alvo:Conteudo {id: $conteudo_id})<-[:ASSISTIU]-(u:Usuario)-[r:ASSISTIU]->(outro:Conteudo)
        WHERE outro <> alvo
        RETURN outro.titulo AS tambem_assistiram,
               outro.tipo AS tipo,
               count(DISTINCT u) AS usuarios_em_comum,
               round(avg(r.nota), 2) AS nota_media
        ORDER BY usuarios_em_comum DESC, nota_media DESC
        LIMIT 6
    """
    records = run_cypher(driver, query, {"conteudo_id": "22222222-2222-4222-8222-000000000001"})
    if not records:
        raise RuntimeError("Grafo vazio ou sem recomendações. Rode carga.cypher antes.")
    print_records(records)


def op2_usuarios_gosto_parecido(driver: Any) -> None:
    """OP 2 (R6 Parte 2): Filtragem colaborativa de 3 saltos para João Silva."""
    print("\n--- [OP 2] R6 Parte 2: 'Usuários com gosto parecido com o de João Silva assistiram isto' ---")
    query = """
        MATCH (alvo:Usuario {id: $usuario_id})-[:ASSISTIU]->(comum:Conteudo)<-[:ASSISTIU]-(similar:Usuario)
        WHERE similar <> alvo
        WITH alvo, similar, count(DISTINCT comum) AS titulos_em_comum
        WHERE titulos_em_comum >= 2
        MATCH (similar)-[r:ASSISTIU]->(rec:Conteudo)
        WHERE NOT (alvo)-[:ASSISTIU]->(rec)
        RETURN rec.titulo AS recomendacao,
               rec.tipo AS tipo,
               count(DISTINCT similar) AS recomendado_por_qtd,
               collect(DISTINCT similar.nome) AS usuarios_similares,
               round(avg(r.nota), 2) AS nota_media
        ORDER BY recomendado_por_qtd DESC, nota_media DESC
        LIMIT 6
    """
    records = run_cypher(driver, query, {"usuario_id": "11111111-1111-4111-8111-000000000001"})
    print_records(records)


def op3_ranking_afinidade(driver: Any) -> None:
    """OP 3: Ranking de afinidade entre usuários com base nos títulos em comum."""
    print("\n--- [OP 3] Ranking de afinidade: usuários com gosto mais parecido com João Silva ---")
    query = """
        MATCH (alvo:Usuario {id: $usuario_id})-[:ASSISTIU]->(c:Conteudo)<-[:ASSISTIU]-(outro:Usuario)
        WHERE outro <> alvo
        RETURN outro.nome AS usuario_similar,
               count(DISTINCT c) AS titulos_em_comum,
               collect(DISTINCT c.titulo) AS conteudos_compartilhados
        ORDER BY titulos_em_comum DESC
    """
    records = run_cypher(driver, query, {"usuario_id": "11111111-1111-4111-8111-000000000001"})
    print_records(records)


def op4_recomendacao_hibrida_generos(driver: Any) -> None:
    """OP 4: Recomendação híbrida combinando afinidade de gênero e notas (Ana Costa)."""
    print("\n--- [OP 4] Recomendação híbrida por gênero + nota média para Ana Costa ---")
    query = """
        MATCH (alvo:Usuario {id: $usuario_id})-[:ASSISTIU]->(:Conteudo)-[:PERTENCE_A]->(g:Genero)<-[:PERTENCE_A]-(rec:Conteudo)
        WHERE NOT (alvo)-[:ASSISTIU]->(rec)
        OPTIONAL MATCH (:Usuario)-[r:ASSISTIU]->(rec)
        RETURN rec.titulo AS recomendacao_para_ana,
               rec.tipo AS tipo,
               collect(DISTINCT g.nome) AS generos_em_comum,
               round(avg(r.nota), 2) AS nota_media
        ORDER BY size(generos_em_comum) DESC, nota_media DESC
        LIMIT 5
    """
    records = run_cypher(driver, query, {"usuario_id": "11111111-1111-4111-8111-000000000004"})
    print_records(records)


def main() -> int:
    configure_utf8_stdio()
    uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
    user = os.getenv("NEO4J_USER", "neo4j")
    password = os.getenv("NEO4J_PASSWORD", "senha123")

    print_header("DEMONSTRAÇÃO NEO4J — REQUISITO R6 (RECOMENDAÇÕES POR GRAFO)")
    print(f"Conectando em: {uri} (usuário: {user})")

    driver = GraphDatabase.driver(uri, auth=(user, password))
    try:
        driver.verify_connectivity()
        contagem = run_cypher(
            driver,
            "MATCH (u:Usuario) WITH count(u) AS usuarios "
            "MATCH (c:Conteudo) WITH usuarios, count(c) AS conteudos "
            "MATCH ()-[r:ASSISTIU]->() "
            "RETURN usuarios, conteudos, count(r) AS visualizacoes",
        )
        print("Resumo do grafo:", contagem[0])

        op1_quem_assistiu_tambem_assistiu(driver)
        op2_usuarios_gosto_parecido(driver)
        op3_ranking_afinidade(driver)
        op4_recomendacao_hibrida_generos(driver)
    finally:
        driver.close()

    print("\n=== [Neo4j] Demonstração R6 concluída com sucesso! ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
