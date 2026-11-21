-- =============================================================================
-- Cassandra — Script de Carga (Requisito R5: Eventos de Reprodução)
-- Todos os UUIDs seguem estritamente CONTRATO_IDS.md
-- Execução: docker exec -i streaming-cassandra cqlsh -f /scripts/cassandra/carga.cql
-- =============================================================================

USE streaming;

TRUNCATE eventos_por_usuario;
TRUNCATE eventos_por_conteudo;

-- =============================================================================
-- SESSÕES DE REPRODUÇÃO — JOÃO SILVA (11111111-1111-4111-8111-000000000001)
-- =============================================================================

-- Sessão 1 (Outubro/2026): João assistiu Interestelar até o fim na Smart TV
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-10', '2026-10-25T20:00:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-10', '2026-10-25T21:15:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'pause', 4500, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-10', '2026-10-25T21:20:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'play', 4500, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-10', '2026-10-25T22:54:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'conclusao', 10140, 'Smart TV');

-- Sessão 2 (Novembro/2026): João assistiu A Origem na Web (play, avanco, pause, conclusao)
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-12T19:00:00Z', now(), 22222222-2222-4222-8222-000000000002, 'A Origem', 'play', 0, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-12T19:35:00Z', now(), 22222222-2222-4222-8222-000000000002, 'A Origem', 'avanco', 2400, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-12T20:10:00Z', now(), 22222222-2222-4222-8222-000000000002, 'A Origem', 'pause', 4500, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-12T21:25:00Z', now(), 22222222-2222-4222-8222-000000000002, 'A Origem', 'conclusao', 8880, 'Web');

-- Sessão 3 (Novembro/2026): João iniciou Stranger Things no Mobile e abandonou no meio, retomando na Smart TV
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-18T12:10:00Z', now(), 22222222-2222-4222-8222-000000000007, 'Stranger Things', 'play', 0, 'Mobile Android');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-18T12:28:00Z', now(), 22222222-2222-4222-8222-000000000007, 'Stranger Things', 'abandono', 1080, 'Mobile Android');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-18T21:00:00Z', now(), 22222222-2222-4222-8222-000000000007, 'Stranger Things', 'play', 1080, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-18T21:32:00Z', now(), 22222222-2222-4222-8222-000000000007, 'Stranger Things', 'conclusao', 2940, 'Smart TV');

-- Sessão 4 (Novembro/2026): João assistiu O Dilema das Redes
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-19T22:00:00Z', now(), 22222222-2222-4222-8222-000000000013, 'O Dilema das Redes', 'play', 0, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-19T22:45:00Z', now(), 22222222-2222-4222-8222-000000000013, 'O Dilema das Redes', 'avanco', 3000, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000001, '2026-11', '2026-11-19T23:30:00Z', now(), 22222222-2222-4222-8222-000000000013, 'O Dilema das Redes', 'conclusao', 5640, 'Web');

-- =============================================================================
-- SESSÕES DE REPRODUÇÃO — MARIA OLIVEIRA (11111111-1111-4111-8111-000000000002)
-- =============================================================================
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-18T19:00:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-18T20:30:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'pause', 5400, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-18T21:55:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'conclusao', 10140, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-19T20:10:00Z', now(), 22222222-2222-4222-8222-000000000008, 'Dark', 'play', 0, 'iOS');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-19T21:02:00Z', now(), 22222222-2222-4222-8222-000000000008, 'Dark', 'conclusao', 3060, 'iOS');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-20T18:00:00Z', now(), 22222222-2222-4222-8222-000000000003, 'Blade Runner 2049', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000002, '2026-11', '2026-11-20T20:45:00Z', now(), 22222222-2222-4222-8222-000000000003, 'Blade Runner 2049', 'conclusao', 9840, 'Smart TV');

-- =============================================================================
-- SESSÕES DE REPRODUÇÃO — OUTROS USUÁRIOS (Pedro, Ana, Lucas, Carla, Gabriel)
-- =============================================================================
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000003, '2026-11', '2026-11-18T20:05:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'play', 0, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000003, '2026-11', '2026-11-18T20:40:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'abandono', 2100, 'Web');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000003, '2026-11', '2026-11-19T19:00:00Z', now(), 22222222-2222-4222-8222-000000000004, 'Matrix', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000003, '2026-11', '2026-11-19T21:16:00Z', now(), 22222222-2222-4222-8222-000000000004, 'Matrix', 'conclusao', 8160, 'Smart TV');

INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000004, '2026-11', '2026-11-18T15:00:00Z', now(), 22222222-2222-4222-8222-000000000012, 'Nosso Planeta', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000004, '2026-11', '2026-11-18T15:50:00Z', now(), 22222222-2222-4222-8222-000000000012, 'Nosso Planeta', 'conclusao', 3000, 'Smart TV');

INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000005, '2026-11', '2026-11-19T22:00:00Z', now(), 22222222-2222-4222-8222-000000000009, 'Breaking Bad', 'play', 0, 'Mobile Android');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000005, '2026-11', '2026-11-19T22:25:00Z', now(), 22222222-2222-4222-8222-000000000009, 'Breaking Bad', 'avanco', 1800, 'Mobile Android');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000005, '2026-11', '2026-11-19T22:55:00Z', now(), 22222222-2222-4222-8222-000000000009, 'Breaking Bad', 'conclusao', 3480, 'Mobile Android');

INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000009, '2026-11', '2026-11-18T21:10:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'play', 0, 'iOS');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000009, '2026-11', '2026-11-18T22:00:00Z', now(), 22222222-2222-4222-8222-000000000001, 'Interestelar', 'pause', 3000, 'iOS');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000009, '2026-11', '2026-11-20T21:00:00Z', now(), 22222222-2222-4222-8222-000000000010, 'Severance', 'play', 0, 'Smart TV');
INSERT INTO eventos_por_usuario (usuario_id, ano_mes, evento_ts, evento_id, conteudo_id, titulo_conteudo, tipo_evento, posicao_segundos, dispositivo)
VALUES (11111111-1111-4111-8111-000000000009, '2026-11', '2026-11-20T21:57:00Z', now(), 22222222-2222-4222-8222-000000000010, 'Severance', 'conclusao', 3420, 'Smart TV');

-- =============================================================================
-- TABELA DENORMALIZADA: eventos_por_conteudo (auditoria do dia 2026-11-18 em Interestelar)
-- =============================================================================
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T19:00:00Z', now(), 11111111-1111-4111-8111-000000000002, 'play', 0, 'Smart TV');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T20:05:00Z', now(), 11111111-1111-4111-8111-000000000003, 'play', 0, 'Web');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T20:30:00Z', now(), 11111111-1111-4111-8111-000000000002, 'pause', 5400, 'Smart TV');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T20:40:00Z', now(), 11111111-1111-4111-8111-000000000003, 'abandono', 2100, 'Web');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T21:10:00Z', now(), 11111111-1111-4111-8111-000000000009, 'play', 0, 'iOS');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T21:55:00Z', now(), 11111111-1111-4111-8111-000000000002, 'conclusao', 10140, 'Smart TV');
INSERT INTO eventos_por_conteudo (conteudo_id, data_dia, evento_ts, evento_id, usuario_id, tipo_evento, posicao_segundos, dispositivo)
VALUES (22222222-2222-4222-8222-000000000001, '2026-11-18', '2026-11-18T22:00:00Z', now(), 11111111-1111-4111-8111-000000000009, 'pause', 3000, 'iOS');
