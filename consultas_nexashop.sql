-- Atividade 0 - Validacao do ambiente
SELECT 'clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'produtos' AS tabela, COUNT(*) AS total FROM produtos
UNION ALL
SELECT 'pedidos' AS tabela, COUNT(*) AS total FROM pedidos
UNION ALL
SELECT 'avaliacoes' AS tabela, COUNT(*) AS total FROM avaliacoes;


-- 1.1 - Primeiro contato com os dados
SELECT * FROM clientes LIMIT 10;

SELECT * FROM produtos LIMIT 10;

SELECT * FROM pedidos LIMIT 10;

SELECT * FROM avaliacoes LIMIT 10;

-- 1.2 - Catalogo de produtos para o marketing
SELECT nome AS Produto, categoria AS Categoria, marca AS Marca, preco AS 'Valor (R$)', estoque AS Estoque
FROM produtos;

-- 1.3 - Quantas categorias a loja realmente vende
SELECT DISTINCT categoria
FROM produtos
ORDER BY categoria;

-- 1.4 - Formas de pagamento e canais de venda aceitos
SELECT DISTINCT forma_pagamento
FROM pedidos;

SELECT DISTINCT canal_venda
FROM pedidos;

-- 2.1 - Clientes ativos da regiao Sul
SELECT nome, cidade, estado, status
FROM clientes
WHERE status = 'Ativo' AND estado IN ('SC', 'PR', 'RS')
ORDER BY estado, nome;

-- 2.2 - Busca de cliente por nome (tela de atendimento)
SELECT nome, email, cidade, estado
FROM clientes
WHERE nome LIKE '%Silva%';

-- 2.3 - Clientes sem telefone cadastrado
SELECT nome, email, cidade, estado
FROM clientes
WHERE telefone IS NULL;

-- 2.4 - Pedidos de ticket intermediario aprovados
SELECT id, valor_total, forma_pagamento, canal_venda, status
FROM pedidos
WHERE status = 'Aprovado' AND valor_total BETWEEN 100 AND 500
ORDER BY valor_total DESC;

-- 2.5 - Alerta de reposicao de estoque
SELECT nome, categoria, estoque
FROM produtos
WHERE ativo = 1 AND estoque < 10
ORDER BY estoque ASC;

-- 2.6 - Alcance das campanhas de cupom
SELECT id, valor_total, cupom_desconto
FROM pedidos
WHERE cupom_desconto IS NOT NULL;


-- 4.1 - Classificando avaliacoes
SELECT id, nota,
CASE
WHEN nota = 5 THEN 'Excelente'
WHEN nota = 4 THEN 'Boa'
WHEN nota = 3 THEN 'Regular'
ELSE 'Insatisfatoria'
END AS faixa_avaliacao
FROM avaliacoes;

-- 4.2 - Quantas avaliacoes caem em cada faixa
SELECT
CASE
WHEN nota = 5 THEN 'Excelente'
WHEN nota = 4 THEN 'Boa'
WHEN nota = 3 THEN 'Regular'
ELSE 'Insatisfatoria'
END AS faixa_avaliacao,
COUNT(*) AS qtde_avaliacoes
FROM avaliacoes
GROUP BY faixa_avaliacao
ORDER BY qtde_avaliacoes DESC;

-- 4.3 - Taxa de aprovacao de pedidos
SELECT ROUND(AVG(CASE WHEN status = 'Aprovado' THEN 1 ELSE 0 END) * 100, 2) AS taxa_aprovacao_pct
FROM pedidos;

-- 4.4 - Perfil de relacionamento dos clientes
SELECT
CASE
WHEN TIMESTAMPDIFF(YEAR, data_cadastro, CURDATE()) < 1 THEN 'Novo'
WHEN TIMESTAMPDIFF(YEAR, data_cadastro, CURDATE()) <= 3 THEN 'Fiel'
ELSE 'Veterano'
END AS perfil_relacionamento,
COUNT(*) AS qtde_clientes
FROM clientes
GROUP BY perfil_relacionamento
ORDER BY qtde_clientes DESC;