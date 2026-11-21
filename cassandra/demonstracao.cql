-- =============================================================================
-- Cassandra — Script de Demonstração (Requisito R5: Eventos de Reprodução)
-- Execução: docker exec -i streaming-cassandra cqlsh -f /scripts/cassandra/demonstracao.cql
-- =============================================================================

USE streaming;

-- -----------------------------------------------------------------------------
-- OPERAÇÃO 1: Histórico completo de um usuário específico em um bucket mensal
-- Usa a Partition Key exata (usuario_id, ano_mes) -> acesso direto em O(1) à partição,
-- retornando os eventos já ordenados do mais recente ao mais antigo sem ALLOW FILTERING.
-- -----------------------------------------------------------------------------
SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
FROM eventos_por_usuario
WHERE usuario_id = 11111111-1111-4111-8111-000000000001
  AND ano_mes = '2026-11';

-- -----------------------------------------------------------------------------
-- OPERAÇÃO 2: Consulta por intervalo temporal usando a Clustering Key (evento_ts)
-- Recupera apenas os eventos de João Silva ocorridos em 18/11/2026.
-- -----------------------------------------------------------------------------
SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
FROM eventos_por_usuario
WHERE usuario_id = 11111111-1111-4111-8111-000000000001
  AND ano_mes = '2026-11'
  AND evento_ts >= '2026-11-18T00:00:00Z'
  AND evento_ts <= '2026-11-18T23:59:59Z';

-- -----------------------------------------------------------------------------
-- OPERAÇÃO 3: Auditoria na tabela denormalizada eventos_por_conteudo
-- Todos os eventos de 'Interestelar' em 18/11/2026 (play, pause, abandono, conclusao).
-- -----------------------------------------------------------------------------
SELECT evento_ts, usuario_id, tipo_evento, posicao_segundos, dispositivo
FROM eventos_por_conteudo
WHERE conteudo_id = 22222222-2222-4222-8222-000000000001
  AND data_dia = '2026-11-18';

-- -----------------------------------------------------------------------------
-- OPERAÇÃO 4: Escrita de novo evento em tempo real (append-only em LSM-Tree)
-- + leitura imediata dos 5 eventos mais recentes do usuário.
-- -----------------------------------------------------------------------------
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-21T15:00:00Z', now(), 22222222-2222-4222-8222-000000000008, 'Dark', 'play', 0, 'Smart TV');

SELECT evento_ts, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo
FROM eventos_por_usuario
WHERE usuario_id = 11111111-1111-4111-8111-000000000001
  AND ano_mes = '2026-11'
LIMIT 5;
