BEGIN; -- inicia a transacao

CREATE TABLE leituras_sensor (
    id INT,
    data_leitura TIMESTAMP,
    valor DECIMAL
);

-- Inserir dados totalmente aleatorios
INSERT INTO leituras_sensor (id, data_leitura, valor)
SELECT 
    (random() * 100000)::int,
    now() - (random() * interval '365 days'),
    random() * 100
FROM generate_series(1, 1000000);

-- Criar um indice B-Tree normal (Non-Clustered por padrao no PG)
CREATE INDEX idx_sensor_data ON leituras_sensor(data_leitura);
ANALYZE leituras_sensor; -- Atualizar estatísticas

-- Verificar a correlacao antes do CLUSTER
SELECT tablename, attname, correlation 
FROM pg_stats 
WHERE tablename = 'leituras_sensor' AND attname = 'data_leitura';

-- Medir o desempenho da consulta antes do CLUSTER
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM leituras_sensor 
WHERE data_leitura BETWEEN now() - interval '10 days' AND now();

-- Executar o Reordenamento Fisico
-- OBS: Isso trava a tabela para leitura e escrita
CLUSTER leituras_sensor USING idx_sensor_data;

-- Atualizar as estatisticas para o banco perceber a mudanca
ANALYZE leituras_sensor;

-- Medir a Correlacao novamente
SELECT attname, correlation 
FROM pg_stats 
WHERE tablename = 'leituras_sensor' AND attname = 'data_leitura';


ROLLBACK;   -- desfaz a transacao