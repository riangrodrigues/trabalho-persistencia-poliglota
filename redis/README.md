# Guia de Integração — Redis (Requisitos R3, R4, R7 e R8)

Este diretório está reservado para os scripts do **Redis**, responsável pelas operações em memória de baixa latência da plataforma **UniStream**:
- **R3:** Sessão do usuário em cada dispositivo com expiração automática por TTL (`1800` segundos / 30 minutos), sem rotina de limpeza.
- **R4:** Ranking semanal de conteúdos mais assistidos, sempre ordenado (`Sorted Set`).
- **R7:** Ponto exato de parada da reprodução com leitura e escrita a cada poucos segundos (`Hash`).
- **R8:** Listagem de conteúdos por gênero na tela de navegação em cache, sem consultar o catálogo principal no MongoDB.

## 1. Conexão com o Container (`docker-compose.yml`)

- **Container:** `streaming-redis`
- **Host/Porta:** `localhost:6379`
- **Persistência habilitada:** AOF (`redis-server --appendonly yes`)
- **Pasta montada no container:** `/scripts/redis`

## 2. Arquivos Esperados

Crie nesta pasta (`redis/`) os scripts com os comandos Redis (ou um par `.txt`/`.redis`):

- `criacao.txt` *(opcional)* ou `carga.txt` / `carga.redis` — Carga inicial de sessões com TTL, ranking semanal, pontos de parada e cache de gêneros populado a partir do catálogo do MongoDB.
- `demonstracao.txt` / `demonstracao.redis` — Operações demonstrando R3 (`SET` + `EX` + `TTL`), R4 (`ZINCRBY` + `ZREVRANGE ... WITHSCORES`), R7 (`HSET`/`HGETALL`) e R8 (`SMEMBERS` ou `GET` do cache de gênero sem bater no MongoDB).

*(O orquestrador `scripts/run_all.py` detecta automaticamente `criacao.txt`/`criacao.redis`, `carga.txt`/`carga.redis` e `demonstracao.txt`/`demonstracao.redis` nesta pasta.)*

## 3. Padrão de Chaves e Contrato de IDs

Use os UUIDs de usuário e conteúdo definidos em [../CONTRATO_IDS.md](../CONTRATO_IDS.md):

| Requisito | Padrão de Chave | Estrutura | TTL |
| :--- | :--- | :--- | :--- |
| **R3** (Sessão) | `sessao:usuario:<usuario_id>:<dispositivo>` | `Hash` ou `String` | `1800s` (30 min) |
| **R4** (Ranking semanal) | `ranking:semanal:<ano>-W<semana>` | `Sorted Set (ZSET)` | `604800s` (7 dias) |
| **R7** (Ponto de parada) | `progresso:usuario:<usuario_id>:<conteudo_id>` | `Hash` | Sem TTL (ou `90d`) |
| **R8** (Cache por gênero) | `catalogo:genero:<slug>` | `Set` ou `String (JSON)` | `3600s` (1 hora) |

### Slugs de Gênero no MongoDB (para alinhar o cache R8)
- `ficcao-cientifica`, `suspense`, `drama`, `acao`, `crime`, `documentario`, `natureza`, `tecnologia`, `ciencia`, `esporte`

## 4. Comandos para Testar via `docker exec`

No PowerShell ou terminal Linux/macOS:
```bash
# Modo interativo
docker exec -it streaming-redis redis-cli

# Executando arquivo de comandos montado no container
docker exec streaming-redis sh -c "redis-cli < /scripts/redis/carga.txt"
docker exec streaming-redis sh -c "redis-cli < /scripts/redis/demonstracao.txt"
```
