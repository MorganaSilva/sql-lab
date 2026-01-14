# SQL Lab

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15%2B-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Focus](https://img.shields.io/badge/Focus-Performance%20%26%20Internals-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

Este repositório é um **laboratório prático de Engenharia de Banco de Dados**, focado em desmistificar o comportamento interno do PostgreSQL. Aqui estão documentados experimentos reais sobre indexação, estruturas físicas de armazenamento, concorrência e otimização de queries.

---

## Objetivo
Preencher a lacuna entre o conhecimento básico de SQL (`SELECT`, `JOIN`) e a engenharia avançada necessária para escalar sistemas. Cada laboratório responde a perguntas como:
- Por que minha query está lenta mesmo com índice?
- Qual o custo real de um `LIKE` vs Full-Text Search?
- Como a desordem física dos dados (Heap) impacta o I/O do disco?

## Módulos de Estudo

### 1. Indexing Deep Dive (`/01-indexes`)
Análise profunda das estruturas de dados e quando utilizá-las.
- **B-Tree:** O impacto em ranges e igualdades (Benchmark: Seq Scan vs Index Scan).
- **Hash Index:** A prova de conceito de sua velocidade O(1) e falha em range queries.
- **GIN (Generalized Inverted Index):** Otimização de Full-Text Search (118x mais rápido que `LIKE`).
- **GiST (Spatial):** Indexação geométrica com R-Trees para dados de localização.

### 2. Physical Storage & Layout (`/02-storage`)
- **Heap vs. Clustered:** Demonstração prática do comando `CLUSTER` e métricas de correlação (`pg_stats`) para reduzir I/O em até 90%.

### 3. Concurrency & Locking (Em Breve)
- Row-level locking, Deadlocks e isolamento de transações.

---

## Tech Stack & Ferramentas
* **Database:** PostgreSQL 15+ (Local via Docker ou Instalação nativa).
* **Análise:** `EXPLAIN (ANALYZE, BUFFERS)`, `pg_stat_user_indexes`.
* **Client:** DBeaver / pgAdmin / PSQL.

---

## Resultados

Abaixo estão os resultados obtidos nos laboratórios deste repositório, executados em ambiente local com massa de dados controlada.

### 1. Full-Text Search: LIKE vs GIN
*Cenário: Buscar um log de erro específico em 200.000 linhas de texto não estruturado.*

| Método | Query | Scan Type | Tempo (ms) | I/O (Buffers) |
| :--- | :--- | :--- | :--- | :--- |
| **LIKE** | `LIKE '%termo%'` | Seq Scan | **36.114 ms** | 2.715 |
| **GIN** | `@@ to_tsquery` | Bitmap Scan | **0.305 ms** | **8** |
> **Impacto:** O índice invertido foi **~118x mais rápido** e reduziu a leitura de páginas de memória em 99%.

### 2. Physical Clustering: Heap vs Clustered
*Cenário: Range Scan de 10 dias em uma tabela de 1 milhão de linhas.*

| Estado Físico | Métrica "Correlation" | Scan Type | Tempo (ms) | Shared Hits |
| :--- | :--- | :--- | :--- | :--- |
| **Heap (Caos)** | `0.0003` (Random) | Bitmap Heap Scan | 75.437 ms | 7.195 |
| **Clustered** | `1.0000` (Ordenado) | Index Scan | **22.918 ms** | **204** |
> **Impacto:** A organização física dos dados reduziu a necessidade de I/O em **97%**, eliminando a leitura aleatória (Random Seek).

### 3. Hash Index: A Limitação
*Cenário: Busca de UUID em 500.000 registros.*

| Operação | Query | Resultado | Tempo |
| :--- | :--- | :--- | :--- |
| **Igualdade** | `token = '...'` |Index Scan | **0.272 ms** |
| **Intervalo** | `token > '...'` | Seq Scan | **82.711 ms** |
> **Aprendizado:** Hash Indexes são inúteis para intervalos, forçando o banco a varrer a tabela inteira (300x mais lento neste teste).

---

## Como reproduzir os laboratórios

Cada pasta contém scripts `.sql` autossuficientes.

**Passo a Passo:**

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/SEU-USUARIO/sql-mastery-lab.git](https://github.com/SEU-USUARIO/sql-mastery-lab.git)
   cd sql-mastery-lab

2. Escolha um Cenário: Navegue até à pasta desejada (ex: 01-indexacao).

3. Execute o Script: Cada ficheiro .sql utiliza uma Transação Segura (BEGIN; ... ROLLBACK;).

    - Isto significa que o script cria as tabelas, gera os dados, executa os testes e desfaz tudo automaticamente no final. O seu banco de dados permanece limpo após a execução.

*Dica: Se desejar manter os dados para explorar manualmente, altere a última linha do script de ROLLBACK; para COMMIT;.*


## Contribuição

Este projeto é aberto para aprendizado e contribuições são muito bem-vindas! Se você quer adicionar novos cenários de teste, corrigir bugs ou melhorar a documentação, siga os passos abaixo.

### Como posso ajudar?

1.  **Discutir Resultados:** Encontrou um plano de execução diferente no seu hardware? Abra uma **Issue** para debatermos o porquê.
2.  **Novos Cenários:** Sinta-se à vontade para criar Pull Requests com novos laboratórios.

### Guia para Pull Requests

Para manter a qualidade e segurança dos laboratórios, pedimos que novos scripts sigam este padrão:

* **Self-contained:** O script deve criar, popular, testar e limpar tudo sozinho.
* **Transacional:** Use blocos `BEGIN; ... ROLLBACK;` para garantir que quem rodar o script não fique com "lixo" no banco.
* **Comentado:** Explique o objetivo de cada query complexa.

**Exemplo de estrutura aceita:**

```sql
/* LAB: Nome do Teste
   Objetivo: Explicar o que estamos testando
*/
BEGIN;
    -- 1. Setup
    CREATE TABLE teste_x (...);
    
    -- 2. Execução
    EXPLAIN ANALYZE SELECT ...;
ROLLBACK;
```

<p align="center"> Feito com ☕, <b>EXPLAIN ANALYZE</b> e PostgreSQL. </p>
