-- =============================================================================
-- Cassandra — Script de Criação (Requisito R5: Eventos de Reprodução em Alto Volume)
-- Keyspace: streaming
-- Execução: docker exec -i streaming-cassandra cqlsh --request-timeout=60 -f /scripts/cassandra/criacao.cql
-- =============================================================================

CREATE KEYSPACE IF NOT EXISTS streaming
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
};
-- Nota de produção: em ambiente multi-datacenter, usa-se NetworkTopologyStrategy com RF=3.

USE streaming;

DROP TABLE IF EXISTS eventos_por_usuario;
DROP TABLE IF EXISTS eventos_por_conteudo;

-- -----------------------------------------------------------------------------
-- TABELA 1: eventos_por_usuario (Consulta principal do Requisito R5)
-- Atende: "consultar o histórico completo de eventos de um usuário específico"
--
-- Partition Key composta: (usuario_id, ano_mes)
--   -> Distribui a escrita igualmente pelos nós do cluster e impede "wide partitions"
--      (crescimento infinito de uma única partição ao longo dos anos).
-- Clustering Key: (evento_ts DESC, evento_id DESC)
--   -> Armazena os eventos já ordenados cronologicamente (mais recentes primeiro)
--      em disco, permitindo leitura sequencial sem ORDER BY em memória.
-- -----------------------------------------------------------------------------
CREATE TABLE eventos_por_usuario (
    usuario_id UUID,
    ano_mes TEXT,
    evento_ts TIMESTAMP,
    evento_id TIMEUUID,
    conteudo_id UUID,
    titulo_conteudo TEXT,
    tipo_evento TEXT,        -- 'play', 'pause', 'avanco', 'abandono', 'conclusao'
    posicao_segundos INT,
    dispositivo TEXT,        -- 'Smart TV', 'Web', 'Mobile Android', 'iOS'
    PRIMARY KEY ((usuario_id, ano_mes), evento_ts, evento_id)
) WITH CLUSTERING ORDER BY (evento_ts DESC, evento_id DESC)
  AND default_time_to_live = 31536000
  AND comment = 'Histórico cronológico de eventos de reprodução por usuário com bucketing mensal';

-- -----------------------------------------------------------------------------
-- TABELA 2: eventos_por_conteudo (Modelagem orientada a consultas / denormalização)
-- Atende: auditoria e análise de engajamento/abandono de um conteúdo por dia.
--
-- Partition Key composta: (conteudo_id, data_dia)
--   -> Bucket diário evita "hot partitions" quando um lançamento recebe milhões
--      de eventos por hora.
-- Clustering Key: (evento_ts DESC, evento_id DESC)
-- -----------------------------------------------------------------------------
CREATE TABLE eventos_por_conteudo (
    conteudo_id UUID,
    data_dia DATE,
    evento_ts TIMESTAMP,
    evento_id TIMEUUID,
    usuario_id UUID,
    tipo_evento TEXT,
    posicao_segundos INT,
    dispositivo TEXT,
    PRIMARY KEY ((conteudo_id, data_dia), evento_ts, evento_id)
) WITH CLUSTERING ORDER BY (evento_ts DESC, evento_id DESC)
  AND default_time_to_live = 31536000
  AND comment = 'Eventos de reprodução por conteúdo com bucketing diário para análise de abandono';
