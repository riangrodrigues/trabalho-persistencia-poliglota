# Guia de Integração — PostgreSQL (Requisito R1)

Este diretório está reservado para os scripts de **PostgreSQL** (`R1`: usuários, planos, assinaturas e cobranças com atomicidade ACID).

## 1. Conexão com o Container (`docker-compose.yml`)

- **Container:** `streaming-postgres`
- **Host/Porta:** `localhost:5432`
- **Usuário (`POSTGRES_USER`):** `admin`
- **Senha (`POSTGRES_PASSWORD`):** `123456`
- **Banco (`POSTGRES_DB`):** `streaming`
- **Pasta montada no container:** `/scripts/postgres`

## 2. Arquivos Esperados

Crie nesta pasta (`postgres/`) os três scripts abaixo para que o orquestrador (`scripts/run_all.py`) os detecte e execute automaticamente:

1. `criacao.sql` — Criação das tabelas (`usuarios`, `planos`, `assinaturas`, `cobrancas`), chaves primárias, estrangeiras e constraints.
2. `carga.sql` — Carga inicial seguindo **exatamente os mesmos UUIDs** definidos em [CONTRATO_IDS.md](../CONTRATO_IDS.md) (10 usuários e 3 planos).
3. `demonstracao.sql` — Mínimo de 2 operações demonstrando o requisito **R1**:
   - **Sucesso transacional (`BEGIN` ... `COMMIT`):** registrar assinatura, cobrar plano e liberar acesso ao usuário de forma atômica;
   - **Rollback (`BEGIN` ... `ROLLBACK`):** simular falha na cobrança (ex.: pagamento recusado ou valor inválido) e comprovar que a assinatura/acesso não ficam inconsistentes.

## 3. Contrato de IDs (Obrigatório)

Consulte [../CONTRATO_IDS.md](../CONTRATO_IDS.md) para os UUIDs exatos:
- Usuários (`usr-01` a `usr-10`): `11111111-1111-4111-8111-000000000001` .. `000000000010`
- Planos (`Básico`, `Padrão`, `Premium`): `44444444-4444-4444-8444-000000000001` .. `000000000003`

## 4. Comandos para Testar via `docker exec`

```bash
docker exec -i streaming-postgres psql -U admin -d streaming -f /scripts/postgres/criacao.sql
docker exec -i streaming-postgres psql -U admin -d streaming -f /scripts/postgres/carga.sql
docker exec -i streaming-postgres psql -U admin -d streaming -f /scripts/postgres/demonstracao.sql
```
