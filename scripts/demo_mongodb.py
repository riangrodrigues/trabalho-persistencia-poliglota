"""Demonstração Python do Requisito R2 no MongoDB (Catálogo Polimórfico UniStream)."""

from __future__ import annotations

import json
import os
import sys
from typing import Any

from pymongo import MongoClient


def configure_utf8_stdio() -> None:
    """Garante saída UTF-8 no terminal Windows sem erros de encoding."""
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8", errors="replace")


def print_header(title: str) -> None:
    """Imprime cabeçalho padronizado para uma seção ou operação."""
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def print_json(data: Any) -> None:
    """Serializa documentos BSON/JSON de forma legível."""
    print(json.dumps(data, ensure_ascii=False, indent=2, default=str))


def op1_leitura_polimorfica(db: Any) -> None:
    """OP 1: Lê um documento de cada tipo (filme, serie, documentario) na mesma coleção."""
    print("\n--- [OP 1] Documentos polimórficos na coleção 'conteudos' (1 por tipo) ---")
    campos_especificos = {
        "filme": ("duracao_minutos", "diretor", "ano_lancamento", "elenco"),
        "serie": ("criador", "em_andamento", "total_temporadas", "temporadas"),
        "documentario": ("tema", "ano_producao", "narrador", "formato"),
    }

    for tipo, chaves in campos_especificos.items():
        doc = db.conteudos.find_one({"tipo": tipo})
        if not doc:
            raise RuntimeError(f"Nenhum documento encontrado para tipo='{tipo}'. Rode carga.js antes.")
        resumo = {
            "_id": doc["_id"],
            "titulo": doc["titulo"],
            "tipo": doc["tipo"],
            "generos": doc["generos"],
            "estudio_id": doc["estudio_id"],
            "atributos_exclusivos": {k: doc.get(k) for k in chaves if k in doc},
        }
        print(f"\n>> Tipo: {tipo.upper()}")
        print_json(resumo)


def op2_subdocumentos_embutidos(db: Any) -> None:
    """OP 2: Consulta direta em subdocumentos embutidos (temporadas -> episodios >= 60 min)."""
    print("\n--- [OP 2] Séries com episódios embutidos de duração >= 60 min (sem JOIN) ---")
    cursor = db.conteudos.find(
        {"tipo": "serie", "temporadas.episodios.duracao_minutos": {"$gte": 60}},
        {"_id": 0, "titulo": 1, "criador": 1, "total_temporadas": 1, "temporadas": 1},
    )
    resultados = []
    for serie in cursor:
        eps_longos = [
            {
                "temporada": temp["numero"],
                "episodio": ep["numero"],
                "titulo": ep["titulo"],
                "duracao_minutos": ep["duracao_minutos"],
            }
            for temp in serie.get("temporadas", [])
            for ep in temp.get("episodios", [])
            if ep.get("duracao_minutos", 0) >= 60
        ]
        resultados.append(
            {
                "titulo": serie["titulo"],
                "criador": serie["criador"],
                "total_temporadas": serie["total_temporadas"],
                "episodios_60_min_ou_mais": eps_longos,
            }
        )
    print_json(resultados)


def op3_agregacao_referencias(db: Any) -> None:
    """OP 3: Agrega dados referenciados via $lookup em 'estudios' e 'avaliacoes'."""
    print("\n--- [OP 3] Agregação com referências ($lookup em estudios e avaliacoes) ---")
    pipeline = [
        {
            "$lookup": {
                "from": "estudios",
                "localField": "estudio_id",
                "foreignField": "_id",
                "as": "estudio",
            }
        },
        {"$unwind": "$estudio"},
        {
            "$lookup": {
                "from": "avaliacoes",
                "localField": "_id",
                "foreignField": "conteudo_id",
                "as": "lista_avaliacoes",
            }
        },
        {"$match": {"lista_avaliacoes.0": {"$exists": True}}},
        {
            "$project": {
                "_id": 0,
                "titulo": 1,
                "tipo": 1,
                "estudio": "$estudio.nome",
                "total_avaliacoes": {"$size": "$lista_avaliacoes"},
                "nota_media": {"$round": [{"$avg": "$lista_avaliacoes.nota"}, 2]},
            }
        },
        {"$sort": {"nota_media": -1, "total_avaliacoes": -1, "titulo": 1}},
    ]
    resultados = list(db.conteudos.aggregate(pipeline))
    print_json(resultados)


def op4_evolucao_schema(db: Any) -> None:
    """OP 4: Adiciona atributos novos a um único documento sem ALTER TABLE."""
    print("\n--- [OP 4] Evolução dinâmica de schema (novos atributos apenas em Interestelar) ---")
    interestelar_id = "22222222-2222-4222-8222-000000000001"
    res = db.conteudos.update_one(
        {"_id": interestelar_id},
        {"$set": {"resolucao_imax": True, "audio_dolby_atmos": True}},
    )
    if res.matched_count != 1:
        raise RuntimeError("Documento Interestelar não encontrado para atualização.")

    atualizado = db.conteudos.find_one(
        {"_id": interestelar_id},
        {"titulo": 1, "tipo": 1, "diretor": 1, "duracao_minutos": 1, "resolucao_imax": 1, "audio_dolby_atmos": 1},
    )
    print_json(atualizado)


def op5_consulta_multikey_para_cache(db: Any) -> None:
    """OP 5: Filtra conteúdos por gênero usando índice multikey (base do cache R8 no Redis)."""
    print("\n--- [OP 5] Conteúdos do gênero 'ficcao-cientifica' (dados para cache R8 no Redis) ---")
    docs = list(
        db.conteudos.find(
            {"genero_slugs": "ficcao-cientifica"},
            {"_id": 1, "titulo": 1, "tipo": 1, "generos": 1},
        ).sort("titulo", 1)
    )
    print(f"Total encontrado no gênero 'ficcao-cientifica': {len(docs)}")
    print_json(docs)


def main() -> int:
    configure_utf8_stdio()
    mongo_uri = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
    db_name = os.getenv("MONGO_DB", "streaming")

    print_header("DEMONSTRAÇÃO MONGODB — REQUISITO R2 (CATÁLOGO FLEXÍVEL)")
    print(f"Conectando em: {mongo_uri} (banco: {db_name})")

    client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
    try:
        client.admin.command("ping")
        db = client[db_name]

        print(
            f"Contagem atual -> estudios: {db.estudios.count_documents({})}, "
            f"conteudos: {db.conteudos.count_documents({})}, "
            f"avaliacoes: {db.avaliacoes.count_documents({})}"
        )

        op1_leitura_polimorfica(db)
        op2_subdocumentos_embutidos(db)
        op3_agregacao_referencias(db)
        op4_evolucao_schema(db)
        op5_consulta_multikey_para_cache(db)
    finally:
        client.close()

    print("\n=== [MongoDB] Demonstração R2 concluída com sucesso! ===")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
