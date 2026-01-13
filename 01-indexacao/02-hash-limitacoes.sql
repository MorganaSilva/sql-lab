BEGIN; -- inicia a transacao

-- Tabela de Sessões com 500 mil linhas
CREATE TABLE sessoes (
    id SERIAL PRIMARY KEY,
    token UUID DEFAULT gen_random_uuid(),
    dados JSONB
);

-- Inserir dados
INSERT INTO sessoes (dados) 
SELECT '{"status": "ativo"}'::jsonb 
FROM generate_series(1, 500000);

-- Pegar um token qualquer de exemplo para usar na busca
-- Copie o token que aparecer no resultado desse select!
SELECT token FROM sessoes LIMIT 1;

-- Indice HASH
CREATE INDEX idx_sessoes_token ON sessoes USING hash (token);

-- Cenario de teste igualdade
-- Substitua o UUID abaixo pelo que voce copiou no passo 1
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sessoes WHERE token = 'cole-seu-uuid-aqui';

-- Cenario de teste intervalo
-- O que ira acontecer e que o Hash nao sabe o que e >, então ele vai ignorar o indice
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM sessoes WHERE token > '00000000-0000-0000-0000-000000000000';

ROLLBACK;   -- desfaz a transacao