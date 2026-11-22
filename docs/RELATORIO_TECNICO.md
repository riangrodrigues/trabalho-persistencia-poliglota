# Relatório Técnico — Persistência Poliglota UniStream

**Disciplina:** Desenvolvimento e Persistência de Dados — UniRV  
**Tema:** Plataforma de streaming — Grupo 2

## 1. Objetivo

O projeto demonstra persistência poliglota para uma plataforma de streaming. Cada banco atende ao padrão de dados mais adequado: PostgreSQL para transações, MongoDB para catálogo flexível, Redis para dados de acesso rápido, Cassandra para eventos e Neo4j para relações de recomendação.

## 2. Arquitetura e requisitos

Os cinco serviços são executados em containers Docker conectados por uma rede comum e inicializados pelo `docker compose`. A integração lógica entre bancos usa os UUIDs definidos em `CONTRATO_IDS.md`.

- **PostgreSQL (R1):** usuários, planos, assinaturas e cobranças. Chaves estrangeiras e transações garantem que cobrança e liberação de acesso sejam confirmadas ou desfeitas juntas.
- **MongoDB (R2):** catálogo de filmes, séries e documentários em documentos flexíveis.
- **Redis (R3, R4, R7, R8):** sessões com TTL, ranking semanal em ZSET, progresso em Hash e listas por gênero em cache.
- **Cassandra (R5):** eventos de reprodução consultados por usuário e conteúdo.
- **Neo4j (R6):** relações entre usuários e conteúdos para consultas de recomendação.

## 3. Implementação da parte PostgreSQL e Redis

No PostgreSQL, `criacao.sql` define as entidades e restrições, `carga.sql` insere os dez usuários e três planos do contrato, e `demonstracao.sql` mostra uma assinatura cobrada com sucesso e uma falha de cobrança que reverte a assinatura associada.

No Redis, `carga.txt` prepara sessões com expiração de 30 minutos, ranking semanal com sete dias de validade, progresso por usuário/conteúdo e cache por gênero com uma hora de validade. `demonstracao.txt` consulta e atualiza essas estruturas.

## 4. Execução

Com Docker em execução, use `docker compose up -d` e aguarde os serviços ficarem saudáveis. O orquestrador `python scripts/run_all.py` aplica criação, cargas e demonstrações disponíveis e grava saídas em `outputs/`. Também é possível executar os comandos individuais descritos nos arquivos README de cada banco.

## 5. Conclusão

A solução combina modelos relacionais, documentais, chave-valor, colunar distribuído e grafo. A divisão reduz o acoplamento e permite usar cada tecnologia conforme o requisito, mantendo a associação dos registros por UUID compartilhado.
