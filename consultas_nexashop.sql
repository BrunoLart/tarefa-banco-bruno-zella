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

