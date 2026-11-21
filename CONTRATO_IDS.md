# Contrato de IDs e Integração entre os 5 Bancos — UniStream (Plataforma de Streaming)

Este documento define o **contrato único de identificadores** compartilhado por todos os cinco bancos da arquitetura de persistência poliglota. Seguindo estes IDs exatamente, os dados do **PostgreSQL**, **Redis**, **MongoDB**, **Cassandra** e **Neo4j** permanecem 100% coerentes entre si.

---

## 1. Convenção de Identificadores

Usamos **UUIDs determinísticos (RFC 4122)** para `usuario_id`, `conteudo_id` e `estudio_id`:
- Compatível nativamente com `UUID` no **PostgreSQL** e no **Cassandra**;
- Armazenado como `_id` (string UUID) no **MongoDB**;
- Armazenado como propriedade `id` (string UUID com constraint `UNIQUE`) no **Neo4j**;
- Usado diretamente nas chaves do **Redis** (ex.: `sessao:usuario:<usuario_id>`).

Prefixos fixos facilitam a leitura humana durante a demonstração e a arguição:
- **Usuários:** `11111111-1111-4111-8111-0000000000XX`
- **Conteúdos:** `22222222-2222-4222-8222-0000000000XX`
- **Estúdios (MongoDB):** `33333333-3333-4333-8333-0000000000XX`
- **Planos (PostgreSQL):** `44444444-4444-4444-8444-0000000000XX`

---

## 2. Usuários (PostgreSQL `usuarios`, Redis `sessao/progresso`, Cassandra `eventos_por_usuario`, Neo4j `:Usuario`)

| Código | `usuario_id` (UUID) | Nome | Email | Plano Sugerido |
| :--- | :--- | :--- | :--- | :--- |
| `usr-01` | `11111111-1111-4111-8111-000000000001` | João Silva | `joao.silva@unistream.com` | Premium |
| `usr-02` | `11111111-1111-4111-8111-000000000002` | Maria Oliveira | `maria.oliveira@unistream.com` | Premium |
| `usr-03` | `11111111-1111-4111-8111-000000000003` | Pedro Santos | `pedro.santos@unistream.com` | Padrão |
| `usr-04` | `11111111-1111-4111-8111-000000000004` | Ana Costa | `ana.costa@unistream.com` | Padrão |
| `usr-05` | `11111111-1111-4111-8111-000000000005` | Lucas Pereira | `lucas.pereira@unistream.com` | Básico |
| `usr-06` | `11111111-1111-4111-8111-000000000006` | Carla Mendes | `carla.mendes@unistream.com` | Premium |
| `usr-07` | `11111111-1111-4111-8111-000000000007` | Rafael Souza | `rafael.souza@unistream.com` | Padrão |
| `usr-08` | `11111111-1111-4111-8111-000000000008` | Beatriz Lima | `beatriz.lima@unistream.com` | Básico |
| `usr-09` | `11111111-1111-4111-8111-000000000009` | Gabriel Rocha | `gabriel.rocha@unistream.com` | Premium |
| `usr-10` | `11111111-1111-4111-8111-000000000010` | Juliana Alves | `juliana.alves@unistream.com` | Padrão |

---

## 3. Conteúdos (MongoDB `conteudos`, Redis `ranking/progresso/genero`, Cassandra `eventos_*`, Neo4j `:Conteudo`)

| Código | `conteudo_id` (UUID) | Título | Tipo | Gêneros |
| :--- | :--- | :--- | :--- | :--- |
| `cnt-01` | `22222222-2222-4222-8222-000000000001` | Interestelar | `filme` | Ficção Científica, Drama |
| `cnt-02` | `22222222-2222-4222-8222-000000000002` | A Origem | `filme` | Ficção Científica, Ação |
| `cnt-03` | `22222222-2222-4222-8222-000000000003` | Blade Runner 2049 | `filme` | Ficção Científica, Suspense |
| `cnt-04` | `22222222-2222-4222-8222-000000000004` | Matrix | `filme` | Ficção Científica, Ação |
| `cnt-05` | `22222222-2222-4222-8222-000000000005` | Parasita | `filme` | Suspense, Drama |
| `cnt-06` | `22222222-2222-4222-8222-000000000006` | Mad Max: Estrada da Fúria | `filme` | Ação, Ficção Científica |
| `cnt-07` | `22222222-2222-4222-8222-000000000007` | Stranger Things | `serie` | Suspense, Ficção Científica |
| `cnt-08` | `22222222-2222-4222-8222-000000000008` | Dark | `serie` | Suspense, Ficção Científica |
| `cnt-09` | `22222222-2222-4222-8222-000000000009` | Breaking Bad | `serie` | Drama, Crime |
| `cnt-10` | `22222222-2222-4222-8222-000000000010` | Severance | `serie` | Suspense, Ficção Científica |
| `cnt-11` | `22222222-2222-4222-8222-000000000011` | The Last of Us | `serie` | Drama, Ação |
| `cnt-12` | `22222222-2222-4222-8222-000000000012` | Nosso Planeta | `documentario` | Documentário, Natureza |
| `cnt-13` | `22222222-2222-4222-8222-000000000013` | O Dilema das Redes | `documentario` | Documentário, Tecnologia |
| `cnt-14` | `22222222-2222-4222-8222-000000000014` | Cosmos: Mundos Possíveis | `documentario` | Documentário, Ciência |
| `cnt-15` | `22222222-2222-4222-8222-000000000015` | Free Solo | `documentario` | Documentário, Esporte |

---

## 4. Planos de Assinatura (Referência para PostgreSQL — R1)

| `plano_id` (UUID) | Nome | Preço Mensal (R$) | Telas Simultâneas | Qualidade |
| :--- | :--- | :---: | :---: | :--- |
| `44444444-4444-4444-8444-000000000001` | Básico | 24.90 | 1 | HD (720p) |
| `44444444-4444-4444-8444-000000000002` | Padrão | 39.90 | 2 | Full HD (1080p) |
| `44444444-4444-4444-8444-000000000003` | Premium | 55.90 | 4 | Ultra HD (4K) |

---

## 5. Padrão de Chaves Sugerido para o Redis (R3, R4, R7, R8)

| Requisito | Padrão de Chave | Estrutura | TTL | Exemplo de Valor |
| :--- | :--- | :--- | :--- | :--- |
| **R3** (Sessão por dispositivo) | `sessao:usuario:<usuario_id>:<dispositivo>` | `Hash` ou `String` | `1800s` (30 min) | `token`, `ip`, `dispositivo`, `ultimo_acesso` |
| **R4** (Ranking semanal) | `ranking:semanal:<ano>-W<semana>` | `Sorted Set (ZSET)` | `604800s` (7 dias) | membro `<conteudo_id>`, score = visualizações |
| **R7** (Ponto de parada) | `progresso:usuario:<usuario_id>:<conteudo_id>` | `Hash` | Sem TTL (ou `90d`) | `posicao_segundos`, `episodio`, `atualizado_em` |
| **R8** (Cache por gênero) | `catalogo:genero:<slug>` | `Set` ou `String (JSON)` | `3600s` (1 hora) | lista de `{id, titulo, tipo}` (ex.: `catalogo:genero:ficcao-cientifica`) |

### Slugs de Gênero Padronizados (R8)
- `ficcao-cientifica`, `suspense`, `drama`, `acao`, `crime`, `documentario`, `natureza`, `tecnologia`, `ciencia`, `esporte`

---

## 6. Fluxo de Dados entre os Bancos (Simulação de Aplicação)

1. **Cadastro e Assinatura (`R1` → PostgreSQL):** cria `usuario_id`, `assinatura` e `cobranca` em transação ACID.
2. **Login no Dispositivo (`R3` → Redis):** grava `sessao:usuario:<usuario_id>:<dispositivo>` com TTL de 30 min.
3. **Navegação por Gênero (`R8` → Redis, alimentado pelo MongoDB `R2`):** consulta `catalogo:genero:<slug>` no Redis sem bater no MongoDB; ao abrir detalhes do título, lê o documento polimórfico no **MongoDB**.
4. **Reprodução (`R4`, `R5`, `R7` → Redis + Cassandra):**
   - Cada evento (`play`, `pause`, `avanco`, `abandono`, `conclusao`) é gravado em alta vazão no **Cassandra** (`eventos_por_usuario` e `eventos_por_conteudo`);
   - O ponto exato de parada é atualizado a cada poucos segundos no **Redis** (`progresso:usuario:<usuario_id>:<conteudo_id>`);
   - Ao dar `play`, incrementa `ZINCRBY ranking:semanal:... 1 <conteudo_id>` no **Redis**.
5. **Recomendações (`R6` → Neo4j):** ao assistir/concluir um conteúdo, sincroniza a aresta `(:Usuario)-[:ASSISTIU]->(:Conteudo)` no **Neo4j**, habilitando consultas de filtragem colaborativa em milissegundos.
