// =============================================================================
// MongoDB — Script de Demonstração (Requisito R2: Catálogo Polimórfico)
// Execução: docker exec -i streaming-mongodb mongosh streaming /scripts/mongodb/demonstracao.js
// =============================================================================

const dbRef = db.getSiblingDB("streaming");

print("\n======================================================================");
print("DEMONSTRAÇÃO MONGODB — REQUISITO R2 (CATÁLOGO FLEXÍVEL)");
print("======================================================================");

// OPERAÇÃO 1: Leitura polimórfica — 1 documento de cada tipo na MESMA coleção
// Mostra que filme, serie e documentario coexistem sem colunas nulas (NULLs).
print("\n--- [OP 1] Documentos polimórficos na coleção 'conteudos' (1 por tipo) ---");
["filme", "serie", "documentario"].forEach((tipo) => {
  const doc = dbRef.conteudos.findOne({ tipo: tipo });
  print("\n>> Exemplo de " + tipo.toUpperCase() + ":");
  printjson(doc);
});

// OPERAÇÃO 2: Consulta direta em subdocumentos EMBUTIDOS (séries -> temporadas -> episódios)
// Sem nenhum JOIN: recupera todas as séries com episódios acima de 60 minutos.
print("\n--- [OP 2] Séries com episódios embutidos com duração >= 60 min ---");
const seriesLongas = dbRef.conteudos
  .find(
    { tipo: "serie", "temporadas.episodios.duracao_minutos": { $gte: 60 } },
    { titulo: 1, criador: 1, total_temporadas: 1, "temporadas.numero": 1, "temporadas.episodios": 1 }
  )
  .toArray();
printjson(seriesLongas);

// OPERAÇÃO 3: Agregação combinando REFERÊNCIAS ($lookup em 'estudios' e 'avaliacoes')
// Mostra o catálogo enriquecido com nome do estúdio e média das notas dos usuários.
print("\n--- [OP 3] Top conteúdos com estúdio (referência) e média de avaliações ---");
const rankingAvaliacoes = dbRef.conteudos
  .aggregate([
    {
      $lookup: {
        from: "estudios",
        localField: "estudio_id",
        foreignField: "_id",
        as: "estudio"
      }
    },
    { $unwind: "$estudio" },
    {
      $lookup: {
        from: "avaliacoes",
        localField: "_id",
        foreignField: "conteudo_id",
        as: "lista_avaliacoes"
      }
    },
    {
      $match: { "lista_avaliacoes.0": { $exists: true } }
    },
    {
      $project: {
        _id: 0,
        titulo: 1,
        tipo: 1,
        estudio: "$estudio.nome",
        total_avaliacoes: { $size: "$lista_avaliacoes" },
        nota_media: { $round: [{ $avg: "$lista_avaliacoes.nota" }, 2] }
      }
    },
    { $sort: { nota_media: -1, total_avaliacoes: -1 } }
  ])
  .toArray();
printjson(rankingAvaliacoes);

// OPERAÇÃO 4: Evolução de schema sem ALTER TABLE
// Adiciona atributos novos ('resolucao_imax' e 'audio_dolby_atmos') apenas a um filme
// sem impactar séries, documentários ou exigir migração de tabela.
print("\n--- [OP 4] Evolução dinâmica de schema (novo atributo apenas em Interestelar) ---");
dbRef.conteudos.updateOne(
  { _id: "22222222-2222-4222-8222-000000000001" },
  { $set: { resolucao_imax: true, audio_dolby_atmos: true } }
);
const atualizado = dbRef.conteudos.findOne(
  { _id: "22222222-2222-4222-8222-000000000001" },
  { titulo: 1, tipo: 1, diretor: 1, duracao_minutos: 1, resolucao_imax: 1, audio_dolby_atmos: 1 }
);
printjson(atualizado);

// OPERAÇÃO 5: Consulta por gênero usando índice multikey (base para popular o cache do Redis R8)
print("\n--- [OP 5] Conteúdos do gênero 'ficcao-cientifica' (dados que alimentam o cache R8 no Redis) ---");
const ficcao = dbRef.conteudos
  .find(
    { genero_slugs: "ficcao-cientifica" },
    { _id: 1, titulo: 1, tipo: 1, generos: 1 }
  )
  .sort({ titulo: 1 })
  .toArray();
printjson(ficcao);

print("\n=== [MongoDB] Demonstração finalizada com sucesso! ===\n");
