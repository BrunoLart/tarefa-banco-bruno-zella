# Consultas SQL - NexaShop

Consultas SQL do banco da loja NexaShop, todas no arquivo `consultas_nexashop.sql`.

## Padrao

- Comentario numerado antes de cada consulta: `-- 1.1 - Primeiro contato com os dados`
- Consultas na ordem dos exercicios
- Linha em branco entre uma consulta e outra
- Ponto e virgula no fim de cada consulta
- Comandos SQL em MAIUSCULO, tabelas e colunas em minusculo
- Consultas grandes quebradas em linhas, uma palavra-chave por linha
- Apelido de coluna com `AS` (aspas simples se tiver espaco ou simbolo)
- Comentarios sem acento

```sql
-- 1.3 - Quantas categorias a loja realmente vende
SELECT DISTINCT categoria
FROM produtos
ORDER BY categoria;
```

## Tabelas

| Tabela | O que guarda |
| --- | --- |
| `clientes` | dados de quem compra |
| `produtos` | itens a venda, com preco e estoque |
| `pedidos` | compras feitas, com pagamento e canal de venda |
| `avaliacoes` | notas e comentarios dos clientes |

