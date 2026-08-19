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

-- 3.1 - Radar de ticket medio
SELECT COUNT(*) AS qtde_pedidos, ROUND(AVG(valor_total), 2) AS ticket_medio, MIN(valor_total) AS menor_valor, MAX(valor_total) AS maior_valor
FROM pedidos
WHERE status = 'Aprovado';

-- 3.2 - Faturamento por forma de pagamento
SELECT forma_pagamento, SUM(valor_total) AS faturamento_total
FROM pedidos
WHERE status = 'Aprovado'
GROUP BY forma_pagamento
ORDER BY faturamento_total DESC;

-- 3.3 - Onde estao os clientes da NexaShop
SELECT estado, COUNT(*) AS qtde_clientes
FROM clientes
GROUP BY estado
ORDER BY qtde_clientes DESC;

-- 3.4 - Estados prioritarios para expansao
SELECT estado, COUNT(*) AS qtde_clientes
FROM clientes
GROUP BY estado
HAVING COUNT(*) > 200
ORDER BY qtde_clientes DESC;

-- 3.5 - Perfil etario por segmento de cliente
SELECT segmento, ROUND(AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())), 1) AS idade_media
FROM clientes
GROUP BY segmento;

-- 3.6 - Valor de estoque parado por categoria
SELECT categoria, SUM(preco * estoque) AS valor_em_estoque
FROM produtos
WHERE ativo = 1
GROUP BY categoria
ORDER BY valor_em_estoque DESC;

