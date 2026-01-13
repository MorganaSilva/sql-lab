BEGIN; -- inicia a transacao

-- DDL e DML para geracao de massa
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    data_pedido TIMESTAMP,
    valor DECIMAL(10,2)
);

-- Inserindo 1 milhao de linhas
INSERT INTO pedidos (cliente_id, data_pedido, valor)
SELECT 
    (random() * 5000)::int,
    now() - (random() * interval '365 days'),
    (random() * 1000)::decimal
FROM generate_series(1, 1000000);

-- Consulta sem indice
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM pedidos 
WHERE data_pedido > now() - interval '7 days';

-- Criando indice B-tree na coluna data_pedido
CREATE INDEX idx_pedidos_data ON pedidos USING btree (data_pedido);

-- Consulta com indice
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM pedidos 
WHERE data_pedido > now() - interval '7 days';

ROLLBACK;   -- desfaz a transacao

