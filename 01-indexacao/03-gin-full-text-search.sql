BEGIN; -- inicia a transacao

-- criar tabela de Logs
CREATE TABLE logs_sistema (
    id SERIAL PRIMARY KEY,
    data_evento TIMESTAMP DEFAULT now(),
    mensagem TEXT
);

-- inserir 200.000 linhas de lixo
INSERT INTO logs_sistema (mensagem)
SELECT 'INFO: O usuário ' || generate_series || ' acessou o sistema com sucesso via ' || 
       CASE WHEN random() > 0.5 THEN 'Mobile' ELSE 'Web' END
FROM generate_series(1, 200000);

-- inserir 1 linha do erro para encontrar
INSERT INTO logs_sistema (mensagem) 
VALUES ('CRITICAL: Falha catastrófica no núcleo do processamento de pagamentos. Error code 500.');

-- teste a: jeito errado (LIKE com wildcard no começo)
-- o banco sera obrigado a ler todas as 200k linhas e verificar string por string.
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM logs_sistema WHERE mensagem LIKE '%catastrófica%';

-- solucionando a necessidade de ler todas as linhas, criar indice invertido (GIN)
-- converter o texto para vetor (tokens) e indexamos.
CREATE INDEX idx_logs_gin ON logs_sistema USING gin(to_tsvector('portuguese', mensagem));

-- usar o operador @@ (match) em vez de LIKE
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM logs_sistema 
WHERE to_tsvector('portuguese', mensagem) @@ to_tsquery('catastrófica');

ROLLBACK;   -- desfaz a transacao