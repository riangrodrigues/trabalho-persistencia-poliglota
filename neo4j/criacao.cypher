// =============================================================================
// Neo4j — Script de Criação (Requisito R6: Recomendações por Grafo)
// Execução: docker exec streaming-neo4j cypher-shell -u neo4j -p senha123 -f /scripts/neo4j/criacao.cypher
// =============================================================================

// Restrições de unicidade garantem integridade dos UUIDs compartilhados e criam índices automaticamente
CREATE CONSTRAINT usuario_id_unique IF NOT EXISTS
FOR (u:Usuario) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT conteudo_id_unique IF NOT EXISTS
FOR (c:Conteudo) REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT genero_nome_unique IF NOT EXISTS
FOR (g:Genero) REQUIRE g.nome IS UNIQUE;

// Índice auxiliar para filtragem rápida por tipo de conteúdo
CREATE INDEX conteudo_tipo_idx IF NOT EXISTS
FOR (c:Conteudo) ON (c.tipo);

SHOW CONSTRAINTS;
