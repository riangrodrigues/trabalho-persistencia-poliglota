// =============================================================================
// Neo4j — Script de Carga (Requisito R6: Recomendações e Filtragem Colaborativa)
// Todos os UUIDs seguem estritamente CONTRATO_IDS.md
// Execução: docker exec streaming-neo4j cypher-shell -u neo4j -p senha123 -f /scripts/neo4j/carga.cypher
// =============================================================================

// Limpeza para execução idempotente
MATCH (n) DETACH DELETE n;

// 1. Nós :Usuario (10 usuários)
UNWIND [
  {id: '11111111-1111-4111-8111-000000000001', nome: 'João Silva',      plano: 'Premium'},
  {id: '11111111-1111-4111-8111-000000000002', nome: 'Maria Oliveira',  plano: 'Premium'},
  {id: '11111111-1111-4111-8111-000000000003', nome: 'Pedro Santos',    plano: 'Padrão'},
  {id: '11111111-1111-4111-8111-000000000004', nome: 'Ana Costa',       plano: 'Padrão'},
  {id: '11111111-1111-4111-8111-000000000005', nome: 'Lucas Pereira',   plano: 'Básico'},
  {id: '11111111-1111-4111-8111-000000000006', nome: 'Carla Mendes',    plano: 'Premium'},
  {id: '11111111-1111-4111-8111-000000000007', nome: 'Rafael Souza',    plano: 'Padrão'},
  {id: '11111111-1111-4111-8111-000000000008', nome: 'Beatriz Lima',    plano: 'Básico'},
  {id: '11111111-1111-4111-8111-000000000009', nome: 'Gabriel Rocha',   plano: 'Premium'},
  {id: '11111111-1111-4111-8111-000000000010', nome: 'Juliana Alves',   plano: 'Padrão'}
] AS usr
CREATE (:Usuario {id: usr.id, nome: usr.nome, plano: usr.plano});

// 2. Nós :Conteudo (15 conteúdos) + Nós :Genero + Arestas [:PERTENCE_A]
UNWIND [
  {id: '22222222-2222-4222-8222-000000000001', titulo: 'Interestelar',               tipo: 'filme',        ano: 2014, generos: ['Ficção Científica', 'Drama']},
  {id: '22222222-2222-4222-8222-000000000002', titulo: 'A Origem',                   tipo: 'filme',        ano: 2010, generos: ['Ficção Científica', 'Ação']},
  {id: '22222222-2222-4222-8222-000000000003', titulo: 'Blade Runner 2049',          tipo: 'filme',        ano: 2017, generos: ['Ficção Científica', 'Suspense']},
  {id: '22222222-2222-4222-8222-000000000004', titulo: 'Matrix',                     tipo: 'filme',        ano: 1999, generos: ['Ficção Científica', 'Ação']},
  {id: '22222222-2222-4222-8222-000000000005', titulo: 'Parasita',                   tipo: 'filme',        ano: 2019, generos: ['Suspense', 'Drama']},
  {id: '22222222-2222-4222-8222-000000000006', titulo: 'Mad Max: Estrada da Fúria',  tipo: 'filme',        ano: 2015, generos: ['Ação', 'Ficção Científica']},
  {id: '22222222-2222-4222-8222-000000000007', titulo: 'Stranger Things',            tipo: 'serie',        ano: 2016, generos: ['Suspense', 'Ficção Científica']},
  {id: '22222222-2222-4222-8222-000000000008', titulo: 'Dark',                       tipo: 'serie',        ano: 2017, generos: ['Suspense', 'Ficção Científica']},
  {id: '22222222-2222-4222-8222-000000000009', titulo: 'Breaking Bad',               tipo: 'serie',        ano: 2008, generos: ['Drama', 'Crime']},
  {id: '22222222-2222-4222-8222-000000000010', titulo: 'Severance',                  tipo: 'serie',        ano: 2022, generos: ['Suspense', 'Ficção Científica']},
  {id: '22222222-2222-4222-8222-000000000011', titulo: 'The Last of Us',             tipo: 'serie',        ano: 2023, generos: ['Drama', 'Ação']},
  {id: '22222222-2222-4222-8222-000000000012', titulo: 'Nosso Planeta',              tipo: 'documentario', ano: 2019, generos: ['Documentário', 'Natureza']},
  {id: '22222222-2222-4222-8222-000000000013', titulo: 'O Dilema das Redes',         tipo: 'documentario', ano: 2020, generos: ['Documentário', 'Tecnologia']},
  {id: '22222222-2222-4222-8222-000000000014', titulo: 'Cosmos: Mundos Possíveis',   tipo: 'documentario', ano: 2020, generos: ['Documentário', 'Ciência']},
  {id: '22222222-2222-4222-8222-000000000015', titulo: 'Free Solo',                  tipo: 'documentario', ano: 2018, generos: ['Documentário', 'Esporte']}
] AS cnt
CREATE (c:Conteudo {id: cnt.id, titulo: cnt.titulo, tipo: cnt.tipo, ano: cnt.ano})
WITH c, cnt.generos AS generos
UNWIND generos AS gen
MERGE (g:Genero {nome: gen})
CREATE (c)-[:PERTENCE_A]->(g);

// 3. Relacionamentos (:Usuario)-[:ASSISTIU {nota, concluido, data_ultimo_acesso}]->(:Conteudo)
UNWIND [
  // João Silva (usr-01): Ficção Científica, Suspense e Documentário Tech
  {u: '11111111-1111-4111-8111-000000000001', c: '22222222-2222-4222-8222-000000000001', nota: 5, concluido: true,  dt: '2026-10-25T22:54:00Z'},
  {u: '11111111-1111-4111-8111-000000000001', c: '22222222-2222-4222-8222-000000000002', nota: 5, concluido: true,  dt: '2026-11-12T21:25:00Z'},
  {u: '11111111-1111-4111-8111-000000000001', c: '22222222-2222-4222-8222-000000000007', nota: 4, concluido: true,  dt: '2026-11-18T21:32:00Z'},
  {u: '11111111-1111-4111-8111-000000000001', c: '22222222-2222-4222-8222-000000000013', nota: 4, concluido: true,  dt: '2026-11-19T23:30:00Z'},

  // Maria Oliveira (usr-02): 3 títulos em comum com João -> recomenda Blade Runner, Dark, Severance
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000001', nota: 5, concluido: true,  dt: '2026-11-18T21:55:00Z'},
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000002', nota: 5, concluido: true,  dt: '2026-11-14T22:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000007', nota: 5, concluido: true,  dt: '2026-11-15T20:10:00Z'},
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000003', nota: 5, concluido: true,  dt: '2026-11-20T20:45:00Z'},
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000008', nota: 5, concluido: true,  dt: '2026-11-19T21:02:00Z'},
  {u: '11111111-1111-4111-8111-000000000002', c: '22222222-2222-4222-8222-000000000010', nota: 5, concluido: true,  dt: '2026-11-20T22:15:00Z'},

  // Gabriel Rocha (usr-09): 3 títulos em comum com João -> reforça Dark, Severance, Cosmos
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000001', nota: 5, concluido: true,  dt: '2026-11-18T22:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000002', nota: 4, concluido: true,  dt: '2026-11-15T19:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000013', nota: 5, concluido: true,  dt: '2026-11-17T18:40:00Z'},
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000008', nota: 5, concluido: true,  dt: '2026-11-19T23:10:00Z'},
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000010', nota: 5, concluido: true,  dt: '2026-11-20T21:57:00Z'},
  {u: '11111111-1111-4111-8111-000000000009', c: '22222222-2222-4222-8222-000000000014', nota: 5, concluido: true,  dt: '2026-11-20T16:30:00Z'},

  // Pedro Santos (usr-03): 2 títulos em comum com João -> reforça Blade Runner, Matrix, Mad Max
  {u: '11111111-1111-4111-8111-000000000003', c: '22222222-2222-4222-8222-000000000001', nota: 4, concluido: false, dt: '2026-11-18T20:40:00Z'},
  {u: '11111111-1111-4111-8111-000000000003', c: '22222222-2222-4222-8222-000000000002', nota: 5, concluido: true,  dt: '2026-11-16T22:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000003', c: '22222222-2222-4222-8222-000000000003', nota: 4, concluido: true,  dt: '2026-11-17T21:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000003', c: '22222222-2222-4222-8222-000000000004', nota: 5, concluido: true,  dt: '2026-11-19T21:16:00Z'},
  {u: '11111111-1111-4111-8111-000000000003', c: '22222222-2222-4222-8222-000000000006', nota: 5, concluido: true,  dt: '2026-11-20T19:45:00Z'},

  // Rafael Souza (usr-07): Ação & Ficção Científica
  {u: '11111111-1111-4111-8111-000000000007', c: '22222222-2222-4222-8222-000000000001', nota: 4, concluido: true,  dt: '2026-11-11T21:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000007', c: '22222222-2222-4222-8222-000000000004', nota: 5, concluido: true,  dt: '2026-11-13T22:15:00Z'},
  {u: '11111111-1111-4111-8111-000000000007', c: '22222222-2222-4222-8222-000000000006', nota: 5, concluido: true,  dt: '2026-11-15T23:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000007', c: '22222222-2222-4222-8222-000000000011', nota: 4, concluido: true,  dt: '2026-11-18T20:30:00Z'},

  // Ana Costa (usr-04): Documentários & Drama
  {u: '11111111-1111-4111-8111-000000000004', c: '22222222-2222-4222-8222-000000000012', nota: 5, concluido: true,  dt: '2026-11-18T15:50:00Z'},
  {u: '11111111-1111-4111-8111-000000000004', c: '22222222-2222-4222-8222-000000000013', nota: 5, concluido: true,  dt: '2026-11-16T18:20:00Z'},
  {u: '11111111-1111-4111-8111-000000000004', c: '22222222-2222-4222-8222-000000000014', nota: 5, concluido: true,  dt: '2026-11-17T17:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000004', c: '22222222-2222-4222-8222-000000000005', nota: 5, concluido: true,  dt: '2026-11-19T20:00:00Z'},

  // Carla Mendes (usr-06): Documentários & Drama (gosto parecido com Ana)
  {u: '11111111-1111-4111-8111-000000000006', c: '22222222-2222-4222-8222-000000000012', nota: 5, concluido: true,  dt: '2026-11-14T16:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000006', c: '22222222-2222-4222-8222-000000000013', nota: 4, concluido: true,  dt: '2026-11-19T19:10:00Z'},
  {u: '11111111-1111-4111-8111-000000000006', c: '22222222-2222-4222-8222-000000000015', nota: 5, concluido: true,  dt: '2026-11-20T14:30:00Z'},
  {u: '11111111-1111-4111-8111-000000000006', c: '22222222-2222-4222-8222-000000000005', nota: 4, concluido: true,  dt: '2026-11-20T21:00:00Z'},

  // Lucas Pereira (usr-05): Séries de Suspense & Crime
  {u: '11111111-1111-4111-8111-000000000005', c: '22222222-2222-4222-8222-000000000007', nota: 4, concluido: true,  dt: '2026-11-15T18:30:00Z'},
  {u: '11111111-1111-4111-8111-000000000005', c: '22222222-2222-4222-8222-000000000008', nota: 5, concluido: true,  dt: '2026-11-17T22:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000005', c: '22222222-2222-4222-8222-000000000009', nota: 5, concluido: true,  dt: '2026-11-19T22:55:00Z'},
  {u: '11111111-1111-4111-8111-000000000005', c: '22222222-2222-4222-8222-000000000010', nota: 4, concluido: true,  dt: '2026-11-20T23:00:00Z'},

  // Beatriz Lima (usr-08): Drama & Suspense
  {u: '11111111-1111-4111-8111-000000000008', c: '22222222-2222-4222-8222-000000000009', nota: 5, concluido: true,  dt: '2026-11-12T20:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000008', c: '22222222-2222-4222-8222-000000000011', nota: 5, concluido: true,  dt: '2026-11-16T21:15:00Z'},
  {u: '11111111-1111-4111-8111-000000000008', c: '22222222-2222-4222-8222-000000000005', nota: 5, concluido: true,  dt: '2026-11-18T19:45:00Z'},
  {u: '11111111-1111-4111-8111-000000000008', c: '22222222-2222-4222-8222-000000000008', nota: 4, concluido: true,  dt: '2026-11-20T20:10:00Z'},

  // Juliana Alves (usr-10): Ação, Drama e Documentário Esporte
  {u: '11111111-1111-4111-8111-000000000010', c: '22222222-2222-4222-8222-000000000004', nota: 4, concluido: true,  dt: '2026-11-10T21:00:00Z'},
  {u: '11111111-1111-4111-8111-000000000010', c: '22222222-2222-4222-8222-000000000006', nota: 4, concluido: true,  dt: '2026-11-14T22:30:00Z'},
  {u: '11111111-1111-4111-8111-000000000010', c: '22222222-2222-4222-8222-000000000011', nota: 5, concluido: true,  dt: '2026-11-17T20:20:00Z'},
  {u: '11111111-1111-4111-8111-000000000010', c: '22222222-2222-4222-8222-000000000015', nota: 4, concluido: true,  dt: '2026-11-19T18:00:00Z'}
] AS ev
MATCH (u:Usuario {id: ev.u}), (c:Conteudo {id: ev.c})
CREATE (u)-[:ASSISTIU {nota: ev.nota, concluido: ev.concluido, data_ultimo_acesso: datetime(ev.dt)}]->(c);

// Resumo da carga
MATCH (u:Usuario) WITH count(u) AS usuarios
MATCH (c:Conteudo) WITH usuarios, count(c) AS conteudos
MATCH (g:Genero) WITH usuarios, conteudos, count(g) AS generos
MATCH ()-[r:ASSISTIU]->()
RETURN usuarios, conteudos, generos, count(r) AS visualizacoes;
