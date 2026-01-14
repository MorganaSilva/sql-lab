BEGIN; -- inicia a transacao

CREATE TABLE entregadores (
    id SERIAL PRIMARY KEY,
    posicao POINT --tipo geometrico nativo do Postgres
);

--gerar 500k pontos aleatorios (X e Y entre 0 e 1000)
INSERT INTO entregadores (posicao)
SELECT point(random() * 1000, random() * 1000)
FROM generate_series(1, 500000);

EXPLAIN (ANALYZE, BUFFERS)
--o operador <@ significa "esta contido em"
SELECT * FROM entregadores 
WHERE posicao <@ box '((200,200),(300,300))';

CREATE INDEX idx_entregadores_gist ON entregadores USING gist(posicao);

--rodar a mesma query novamente
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM entregadores 
WHERE posicao <@ box '((200,200),(300,300))';

ROLLBACK;   -- desfaz a transacao