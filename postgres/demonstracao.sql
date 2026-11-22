-- Caso aprovado: assinatura, cobrança e liberação de acesso confirmadas juntas.
BEGIN;
INSERT INTO assinaturas (assinatura_id, usuario_id, plano_id, status, acesso_liberado)
VALUES ('55555555-5555-4555-8555-000000000001', '11111111-1111-4111-8111-000000000001', '44444444-4444-4444-8444-000000000003', 'ativa', TRUE)
ON CONFLICT (assinatura_id) DO NOTHING;
INSERT INTO cobrancas (cobranca_id, assinatura_id, valor, status)
VALUES ('66666666-6666-4666-8666-000000000001', '55555555-5555-4555-8555-000000000001', 55.90, 'aprovada')
ON CONFLICT (cobranca_id) DO NOTHING;
COMMIT;

SELECT 'R1 - caso aprovado' AS demonstracao, a.status, a.acesso_liberado, c.valor, c.status AS cobranca
FROM assinaturas a JOIN cobrancas c USING (assinatura_id)
WHERE a.assinatura_id = '55555555-5555-4555-8555-000000000001';

-- Falha simulada: CHECK rejeita valor negativo; o bloco DO desfaz suas inserções.
DO $$
BEGIN
    INSERT INTO assinaturas (assinatura_id, usuario_id, plano_id, status, acesso_liberado)
    VALUES ('55555555-5555-4555-8555-000000000002', '11111111-1111-4111-8111-000000000002', '44444444-4444-4444-8444-000000000003', 'ativa', TRUE);
    INSERT INTO cobrancas (cobranca_id, assinatura_id, valor, status)
    VALUES ('66666666-6666-4666-8666-000000000002', '55555555-5555-4555-8555-000000000002', -55.90, 'recusada');
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Cobrança inválida; alterações do bloco foram revertidas.';
END $$;

SELECT 'R1 - rollback simulado' AS demonstracao,
       EXISTS (SELECT 1 FROM assinaturas WHERE assinatura_id = '55555555-5555-4555-8555-000000000002') AS assinatura_persistiu;
