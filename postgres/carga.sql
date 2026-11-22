INSERT INTO usuarios (usuario_id, nome, email, plano_sugerido) VALUES
('11111111-1111-4111-8111-000000000001', 'João Silva', 'joao.silva@unistream.com', 'Premium'),
('11111111-1111-4111-8111-000000000002', 'Maria Oliveira', 'maria.oliveira@unistream.com', 'Premium'),
('11111111-1111-4111-8111-000000000003', 'Pedro Santos', 'pedro.santos@unistream.com', 'Padrão'),
('11111111-1111-4111-8111-000000000004', 'Ana Costa', 'ana.costa@unistream.com', 'Padrão'),
('11111111-1111-4111-8111-000000000005', 'Lucas Pereira', 'lucas.pereira@unistream.com', 'Básico'),
('11111111-1111-4111-8111-000000000006', 'Carla Mendes', 'carla.mendes@unistream.com', 'Premium'),
('11111111-1111-4111-8111-000000000007', 'Rafael Souza', 'rafael.souza@unistream.com', 'Padrão'),
('11111111-1111-4111-8111-000000000008', 'Beatriz Lima', 'beatriz.lima@unistream.com', 'Básico'),
('11111111-1111-4111-8111-000000000009', 'Gabriel Rocha', 'gabriel.rocha@unistream.com', 'Premium'),
('11111111-1111-4111-8111-000000000010', 'Juliana Alves', 'juliana.alves@unistream.com', 'Padrão')
ON CONFLICT (usuario_id) DO NOTHING;

INSERT INTO planos (plano_id, nome, preco_mensal, telas_simultaneas, qualidade) VALUES
('44444444-4444-4444-8444-000000000001', 'Básico', 24.90, 1, 'HD (720p)'),
('44444444-4444-4444-8444-000000000002', 'Padrão', 39.90, 2, 'Full HD (1080p)'),
('44444444-4444-4444-8444-000000000003', 'Premium', 55.90, 4, 'Ultra HD (4K)')
ON CONFLICT (plano_id) DO NOTHING;
