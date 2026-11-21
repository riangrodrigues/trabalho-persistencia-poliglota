// =============================================================================
// Neo4j — Script de Demonstração (Requisito R6: Recomendações por Grafo)
// Execução: docker exec streaming-neo4j cypher-shell -u neo4j -p senha123 -f /scripts/neo4j/demonstracao.cypher
// =============================================================================

// -----------------------------------------------------------------------------
// OPERAÇÃO 1 (R6 - Parte 1): "Quem assistiu Interestelar também assistiu..."
// Travessia de 2 saltos com Index-Free Adjacency, ordenada por frequência e nota média.
// -----------------------------------------------------------------------------
MATCH (alvo:Conteudo {id: '22222222-2222-4222-8222-000000000001'})<-[:ASSISTIU]-(u:Usuario)-[r:ASSISTIU]->(outro:Conteudo)
WHERE outro <> alvo
RETURN outro.titulo AS tambem_assistiram,
       outro.tipo AS tipo,
       count(DISTINCT u) AS usuarios_em_comum,
       round(avg(r.nota), 2) AS nota_media
ORDER BY usuarios_em_comum DESC, nota_media DESC
LIMIT 6;

// -----------------------------------------------------------------------------
// OPERAÇÃO 2 (R6 - Parte 2): "Usuários com gosto parecido com o de João Silva assistiram isto"
// Filtragem colaborativa de 3 saltos: encontra usuários com >= 2 conteúdos em comum
// com João Silva e recomenda títulos ainda não assistidos por ele.
// -----------------------------------------------------------------------------
MATCH (alvo:Usuario {id: '11111111-1111-4111-8111-000000000001'})-[:ASSISTIU]->(comum:Conteudo)<-[:ASSISTIU]-(similar:Usuario)
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
LIMIT 6;

// -----------------------------------------------------------------------------
// OPERAÇÃO 3: Ranking de afinidade — quais usuários têm o gosto mais parecido com João Silva
// Exibe a quantidade e os títulos exatos assistidos em comum.
// -----------------------------------------------------------------------------
MATCH (alvo:Usuario {id: '11111111-1111-4111-8111-000000000001'})-[:ASSISTIU]->(c:Conteudo)<-[:ASSISTIU]-(outro:Usuario)
WHERE outro <> alvo
RETURN outro.nome AS usuario_similar,
       count(DISTINCT c) AS titulos_em_comum,
       collect(DISTINCT c.titulo) AS conteudos_compartilhados
ORDER BY titulos_em_comum DESC;

// -----------------------------------------------------------------------------
// OPERAÇÃO 4: Recomendação híbrida (gosto colaborativo + afinidade de gênero)
// Para Ana Costa (fã de documentários), recomenda títulos que compartilham gêneros
// com o histórico dela e foram bem avaliados por usuários próximos.
// -----------------------------------------------------------------------------
MATCH (alvo:Usuario {id: '11111111-1111-4111-8111-000000000004'})-[:ASSISTIU]->(:Conteudo)-[:PERTENCE_A]->(g:Genero)<-[:PERTENCE_A]-(rec:Conteudo)
WHERE NOT (alvo)-[:ASSISTIU]->(rec)
OPTIONAL MATCH (:Usuario)-[r:ASSISTIU]->(rec)
RETURN rec.titulo AS recomendacao_para_ana,
       rec.tipo AS tipo,
       collect(DISTINCT g.nome) AS generos_em_comum,
       round(avg(r.nota), 2) AS nota_media
ORDER BY size(generos_em_comum) DESC, nota_media DESC
LIMIT 5;
