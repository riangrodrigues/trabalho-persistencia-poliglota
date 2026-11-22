BEGIN;

CREATE TABLE IF NOT EXISTS usuarios (
    usuario_id UUID PRIMARY KEY,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    plano_sugerido TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS planos (
    plano_id UUID PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE,
    preco_mensal NUMERIC(10,2) NOT NULL CHECK (preco_mensal > 0),
    telas_simultaneas SMALLINT NOT NULL CHECK (telas_simultaneas > 0),
    qualidade TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS assinaturas (
    assinatura_id UUID PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES usuarios(usuario_id),
    plano_id UUID NOT NULL REFERENCES planos(plano_id),
    status TEXT NOT NULL CHECK (status IN ('ativa', 'cancelada')),
    inicio_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    acesso_liberado BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS cobrancas (
    cobranca_id UUID PRIMARY KEY,
    assinatura_id UUID NOT NULL REFERENCES assinaturas(assinatura_id),
    valor NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    status TEXT NOT NULL CHECK (status IN ('aprovada', 'recusada')),
    criada_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMIT;
