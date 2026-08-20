# Atividade Prática de Consolidação — Consultas SQL com MySQL

## Da teoria ao relatório de negócio: o cenário NexaShop

**Alunos:** Gustavo Zella e Bruno Silva

**Curso:** Análise e Desenvolvimento de Sistemas — UNISENAI

**Turma:** ADS

**Data:** 20 de agosto de 2026

**Banco de dados:** `ecommerce_nexashop` (MySQL/MariaDB via XAMPP)

---

## 1. Contexto e papel assumido

A NexaShop é uma loja virtual brasileira que vende produtos de dez categorias
diferentes — de eletrônicos e informática a livros e alimentos — atendendo
clientes em todo o país por três canais de venda: site próprio, aplicativo e
marketplace.

Nesta atividade, assumimos o papel de uma dupla de analistas de dados recém
contratada pela empresa. Nosso trabalho não foi apenas escrever consultas SQL,
mas responder às perguntas que as áreas de negócio (marketing, atendimento,
logística e diretoria) fazem no dia a dia, transformando as tabelas do banco em
indicadores que apoiem decisões. Trabalhamos com quatro tabelas isoladas —
`clientes`, `produtos`, `pedidos` e `avaliacoes` — sem usar operações de junção,
o que nos obrigou a extrair o máximo de cada tabela individualmente e, ao final,
reconhecer os limites dessa abordagem.

---

## 2. Validação do ambiente (Atividade 0)

Antes de qualquer análise, conferimos se a base foi importada corretamente,
contando os registros de cada tabela em uma única consulta.

```sql
-- Atividade 0 - Validacao do ambiente
SELECT 'clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'produtos' AS tabela, COUNT(*) AS total FROM produtos
UNION ALL
SELECT 'pedidos' AS tabela, COUNT(*) AS total FROM pedidos
UNION ALL
SELECT 'avaliacoes' AS tabela, COUNT(*) AS total FROM avaliacoes;
```

**Resultado:**

| tabela | total |
| --- | --- |
| clientes | 3.000 |
| produtos | 250 |
| pedidos | 12.000 |
| avaliacoes | 6.000 |

Ambiente validado: os quatro conjuntos de dados foram importados com os volumes
esperados. Vale notar desde já a proporção entre eles — 12.000 pedidos para
3.000 clientes indicam uma média de 4 pedidos por cliente, e apenas 250 produtos
sustentam todo esse volume de vendas.

*(Print da execução: `resultados/Atividade_0_Validacao_do_Ambiente.pdf`)*

---

## 3. Desenvolvimento por bloco

### Bloco 1 — Reconhecimento do banco

#### Tarefa 1.1 — Primeiro contato com os dados

```sql
-- 1.1 - Primeiro contato com os dados
SELECT * FROM clientes LIMIT 10;

SELECT * FROM produtos LIMIT 10;

SELECT * FROM pedidos LIMIT 10;

SELECT * FROM avaliacoes LIMIT 10;
```

**Resultado:** `resultados/Bloco_1_Tarefa_1.1_Primeiro_Contato.pdf`

**Interpretação de negócio:** Esta primeira leitura serviu para conhecer o
terreno antes de formular qualquer pergunta. Descobrimos quais colunas cada
tabela oferece e, principalmente, quais informações a empresa registra sobre
cada entidade — dados cadastrais e de segmentação em `clientes`, preço e estoque
em `produtos`, valor e status em `pedidos`, notas em `avaliacoes`. O uso do
`LIMIT 10` foi uma decisão consciente de desempenho: com 12.000 pedidos na base,
trazer tudo à tela seria lento e desnecessário para uma inspeção inicial.

#### Tarefa 1.2 — Catálogo de produtos para o marketing

```sql
-- 1.2 - Catalogo de produtos para o marketing
SELECT nome AS Produto, categoria AS Categoria, marca AS Marca, preco AS 'Valor (R$)', estoque AS Estoque
FROM produtos;
```

**Resultado:** 250 produtos listados — `resultados/Bloco_1_Tarefa_1.2_Catalogo_Marketing.pdf`

**Interpretação de negócio:** O time de marketing precisa de uma listagem
legível, não de nomes técnicos de colunas. Renomeamos os campos com `AS` para
que a saída pudesse ser copiada diretamente para uma planilha ou apresentação
sem retrabalho. O catálogo tem 250 produtos ativos e inativos, com preços que
variam de itens de baixo valor até equipamentos acima de R$ 2.000, o que mostra
uma loja posicionada em várias faixas de preço simultaneamente.

#### Tarefa 1.3 — Quantas categorias a loja realmente vende

```sql
-- 1.3 - Quantas categorias a loja realmente vende
SELECT DISTINCT categoria
FROM produtos
ORDER BY categoria;
```

**Resultado:** 10 categorias — Alimentos e Bebidas, Automotivo, Beleza e
Cuidados, Brinquedos, Casa e Decoração, Eletrônicos, Esporte e Lazer,
Informática, Livros e Moda.

**Interpretação de negócio:** A NexaShop opera como loja generalista, com dez
categorias cobrindo desde bens duráveis de alto valor até itens de consumo
rápido. Para o marketing, isso significa que campanhas genéricas tendem a ser
ineficazes: o público que compra notebooks provavelmente não é o mesmo que
compra cestas de café. O `DISTINCT` foi essencial aqui — sem ele, a consulta
retornaria uma linha por produto, repetindo cada categoria dezenas de vezes.

#### Tarefa 1.4 — Formas de pagamento e canais de venda aceitos

```sql
-- 1.4 - Formas de pagamento e canais de venda aceitos
SELECT DISTINCT forma_pagamento
FROM pedidos;

SELECT DISTINCT canal_venda
FROM pedidos;
```

**Resultado:**

| forma_pagamento | | canal_venda |
| --- | --- | --- |
| Pix | | Site |
| Cartão de Crédito | | Marketplace |
| Boleto | | App |
| Cartão de Débito | | |

**Interpretação de negócio:** A loja aceita quatro meios de pagamento e vende
por três canais, o que gera doze combinações possíveis de canal e pagamento.
Mapear esses valores foi um passo preparatório importante: as tarefas dos blocos
3 e 5 dependem de saber exatamente quais rótulos existem no banco para poder
agrupá-los e compará-los. Também confirmamos que não há valores inesperados ou
digitados de forma inconsistente nessas colunas.

---

### Bloco 2 — Filtros, busca textual e ordenação

#### Tarefa 2.1 — Clientes ativos da região Sul

```sql
-- 2.1 - Clientes ativos da regiao Sul
SELECT nome, cidade, estado, status
FROM clientes
WHERE status = 'Ativo' AND estado IN ('SC', 'PR', 'RS')
ORDER BY estado, nome;
```

**Resultado:** cerca de 1.560 clientes — `resultados/Bloco_2_Tarefa_2.1_Clientes_Ativos_Sul.pdf`

**Interpretação de negócio:** A região Sul concentra a maior parte da base ativa
da NexaShop, o que faz dela o território natural para uma primeira campanha
regional. O operador `IN` deixou a consulta mais legível do que três condições
`OR` encadeadas, e a dupla condição com `status = 'Ativo'` garante que a lista
não inclua clientes inativos, que gerariam custo de campanha sem retorno
provável.

#### Tarefa 2.2 — Busca de cliente por nome (tela de atendimento)

```sql
-- 2.2 - Busca de cliente por nome (tela de atendimento)
SELECT nome, email, cidade, estado
FROM clientes
WHERE nome LIKE '%Silva%';
```

**Resultado:** 28 clientes — `resultados/Bloco_2_Tarefa_2.2_Busca_por_Nome.pdf`

**Interpretação de negócio:** Esta consulta simula o que o atendente faz quando
um cliente liga e informa apenas o sobrenome. Os `%` em ambos os lados permitem
encontrar "Silva" em qualquer posição do nome, o que é indispensável num
cenário real em que o sobrenome quase nunca é a primeira palavra. O resultado
traz e-mail e cidade justamente para que o atendente confirme a identidade antes
de prosseguir — buscar por sobrenome comum retorna várias pessoas diferentes.

#### Tarefa 2.3 — Clientes sem telefone cadastrado

```sql
-- 2.3 - Clientes sem telefone cadastrado
SELECT nome, email, cidade, estado
FROM clientes
WHERE telefone IS NULL;
```

**Resultado:** cerca de 438 clientes sem telefone.

**Interpretação de negócio:** Aproximadamente 15% da base não tem telefone
cadastrado, uma lacuna relevante para qualquer estratégia de contato ativo ou
recuperação de carrinho por SMS. Foi necessário usar `IS NULL` em vez de
`= NULL`, porque em SQL a ausência de valor não é comparável pelos operadores
comuns. A recomendação prática é acionar esses clientes por e-mail, o único
canal disponível para eles, pedindo a atualização do cadastro.

#### Tarefa 2.4 — Pedidos de ticket intermediário aprovados

```sql
-- 2.4 - Pedidos de ticket intermediario aprovados
SELECT id, valor_total, forma_pagamento, canal_venda, status
FROM pedidos
WHERE status = 'Aprovado' AND valor_total BETWEEN 100 AND 500
ORDER BY valor_total DESC;
```

**Resultado:** cerca de 3.250 pedidos — `resultados/Bloco_2_Tarefa_2.4_Ticket_Intermediario.pdf`

**Interpretação de negócio:** A faixa de R$ 100 a R$ 500 concentra um volume
expressivo de pedidos aprovados, representando o comportamento de compra mais
frequente da loja. O `BETWEEN` inclui os dois extremos, o que atende exatamente
ao enunciado. Para o negócio, esta é a faixa ideal para testar ações de
incremento de ticket — como frete grátis acima de determinado valor —, já que
existe um grande contingente de pedidos próximo ao limite superior.

#### Tarefa 2.5 — Alerta de reposição de estoque

```sql
-- 2.5 - Alerta de reposicao de estoque
SELECT nome, categoria, estoque
FROM produtos
WHERE ativo = 1 AND estoque < 10
ORDER BY estoque ASC;
```

**Resultado:**

| nome | categoria | estoque |
| --- | --- | --- |
| Kit Halteres Kairo Plus | Esporte e Lazer | 0 |
| Romance Best-seller Bravo | Livros | 1 |
| Kit Ferramentas Veicular Orbita Start | Automotivo | 3 |
| Jogo de Panelas Lumina Start | Casa e Decoração | 3 |
| Barbeador Elétrico Orbita Max | Beleza e Cuidados | 3 |
| Camiseta Básica Prime Max | Moda | 4 |
| Cesta de Café Especial Vello Max | Alimentos e Bebidas | 8 |
| Notebook Orbita Pro | Informática | 8 |
| Jaqueta Jeans Prime Plus | Moda | 8 |
| Barbeador Elétrico Lumina Pro | Beleza e Cuidados | 9 |

**Interpretação de negócio:** Dez produtos ativos estão com estoque crítico, e um
deles — o Kit Halteres Kairo Plus — está zerado, ou seja, continua anunciado no
site sem possibilidade de entrega. A ordenação crescente coloca a urgência no
topo da lista, que é como a equipe de compras precisa ler o relatório. O filtro
por `ativo = 1` é o que dá utilidade prática à consulta: produtos desativados
com estoque baixo não representam problema algum e só poluiriam o alerta.

#### Tarefa 2.6 — Alcance das campanhas de cupom

```sql
-- 2.6 - Alcance das campanhas de cupom
SELECT id, valor_total, cupom_desconto
FROM pedidos
WHERE cupom_desconto IS NOT NULL;
```

**Resultado:** cerca de 3.320 pedidos com cupom — `resultados/Bloco_2_Tarefa_2.6_Cupons.pdf`

**Interpretação de negócio:** Aproximadamente 28% dos 12.000 pedidos usaram algum
cupom de desconto, o que revela uma dependência considerável de promoções para
converter vendas. O `IS NOT NULL` é a forma correta de perguntar "quais pedidos
têm cupom", já que os demais registram ausência de valor, e não um cupom vazio.
Para a diretoria, o número levanta uma pergunta de margem: se quase um terço das
vendas envolve desconto, é preciso avaliar se o cupom está atraindo clientes
novos ou apenas reduzindo a receita de quem compraria de qualquer forma.

---

### Bloco 3 — Indicadores agregados

#### Tarefa 3.1 — Radar de ticket médio

```sql
-- 3.1 - Radar de ticket medio
SELECT COUNT(*) AS qtde_pedidos, ROUND(AVG(valor_total), 2) AS ticket_medio, MIN(valor_total) AS menor_valor, MAX(valor_total) AS maior_valor
FROM pedidos
WHERE status = 'Aprovado';
```

**Resultado:**

| qtde_pedidos | ticket_medio | menor_valor | maior_valor |
| --- | --- | --- | --- |
| 8.448 | 1.657,63 | 16,62 | 22.356,60 |

**Interpretação de negócio:** Os 8.448 pedidos aprovados têm ticket médio de
R$ 1.657,63, mas o intervalo entre o menor (R$ 16,62) e o maior (R$ 22.356,60)
pedido é tão grande que a média sozinha engana. Uma diferença de mais de mil
vezes entre os extremos indica que a loja atende dois públicos muito distintos
no mesmo canal: compras de conveniência e aquisições de alto valor. Analisar
apenas o ticket médio, sem olhar a dispersão, levaria a decisões erradas de
precificação e de frete.

#### Tarefa 3.2 — Faturamento por forma de pagamento

```sql
-- 3.2 - Faturamento por forma de pagamento
SELECT forma_pagamento, SUM(valor_total) AS faturamento_total
FROM pedidos
WHERE status = 'Aprovado'
GROUP BY forma_pagamento
ORDER BY faturamento_total DESC;
```

**Resultado:**

| forma_pagamento | faturamento_total |
| --- | --- |
| Cartão de Crédito | 6.295.737,24 |
| Pix | 5.212.400,88 |
| Boleto | 1.299.030,75 |
| Cartão de Débito | 1.196.485,65 |

**Interpretação de negócio:** Cartão de crédito e Pix concentram juntos cerca de
82% do faturamento aprovado, enquanto boleto e débito somam menos de 20%. O
crédito lidera provavelmente por permitir parcelamento em compras de valor alto,
e o Pix já aparece muito próximo, o que é notável para um meio de pagamento à
vista. Qualquer instabilidade no processamento desses dois meios representaria
risco direto à maior parte da receita, o que recomenda atenção redobrada à sua
disponibilidade.

#### Tarefa 3.3 — Onde estão os clientes da NexaShop

```sql
-- 3.3 - Onde estao os clientes da NexaShop
SELECT estado, COUNT(*) AS qtde_clientes
FROM clientes
GROUP BY estado
ORDER BY qtde_clientes DESC;
```

**Resultado:**

| estado | qtde_clientes |
| --- | --- |
| SC | 1.499 |
| SP | 449 |
| PR | 265 |
| RJ | 243 |
| RS | 231 |
| MG | 161 |
| BA | 152 |

**Interpretação de negócio:** Santa Catarina sozinha responde por 1.499 dos
3.000 clientes, ou seja, exatamente metade da base — mais do que a soma dos seis
estados seguintes. Essa concentração revela uma operação com forte identidade
regional, mas também um risco: metade do negócio depende da economia de um único
estado. Para a logística, por outro lado, é uma oportunidade clara de otimizar
prazos e custos de entrega priorizando o Sul.

#### Tarefa 3.4 — Estados prioritários para expansão

```sql
-- 3.4 - Estados prioritarios para expansao
SELECT estado, COUNT(*) AS qtde_clientes
FROM clientes
GROUP BY estado
HAVING COUNT(*) > 200
ORDER BY qtde_clientes DESC;
```

**Resultado:**

| estado | qtde_clientes |
| --- | --- |
| SC | 1.499 |
| SP | 449 |
| PR | 265 |
| RJ | 243 |
| RS | 231 |

**Interpretação de negócio:** Cinco estados ultrapassam a marca de 200 clientes e
formam o núcleo relevante da operação. A diferença técnica em relação à tarefa
anterior é importante: o `HAVING` filtra depois do agrupamento, olhando para o
resultado da contagem, algo que o `WHERE` não conseguiria fazer por atuar antes
de os grupos existirem. Do ponto de vista estratégico, São Paulo chama atenção
por ser o segundo colocado sendo o maior mercado consumidor do país — há espaço
evidente de crescimento ali.

#### Tarefa 3.5 — Perfil etário por segmento de cliente

```sql
-- 3.5 - Perfil etario por segmento de cliente
SELECT segmento, ROUND(AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())), 1) AS idade_media
FROM clientes
GROUP BY segmento;
```

**Resultado:**

| segmento | idade_media |
| --- | --- |
| Atacado | 39,9 |
| Corporativo | 39,1 |
| Varejo | 38,4 |

**Interpretação de negócio:** As idades médias dos três segmentos são
praticamente idênticas, variando apenas 1,5 ano entre o maior e o menor. A
conclusão honesta aqui é que a idade **não** é um critério útil para diferenciar
os segmentos da NexaShop — quem compra no varejo tem o mesmo perfil etário de
quem compra no atacado. Um resultado sem diferença também é um achado válido:
ele indica que a segmentação de campanhas deve se apoiar em outros atributos,
como histórico de compra ou região, e não em faixa etária.

#### Tarefa 3.6 — Valor de estoque parado por categoria

```sql
-- 3.6 - Valor de estoque parado por categoria
SELECT categoria, SUM(preco * estoque) AS valor_em_estoque
FROM produtos
WHERE ativo = 1
GROUP BY categoria
ORDER BY valor_em_estoque DESC;
```

**Resultado:**

| categoria | valor_em_estoque |
| --- | --- |
| Informática | 13.142.221,12 |
| Eletrônicos | 12.776.045,00 |
| Esporte e Lazer | 4.791.018,56 |
| Casa e Decoração | 2.576.483,67 |
| Beleza e Cuidados | 1.220.957,61 |
| Automotivo | 1.172.639,02 |
| Moda | 1.147.603,72 |
| Brinquedos | 815.836,47 |
| Alimentos e Bebidas | 578.268,42 |
| Livros | 547.811,14 |

**Interpretação de negócio:** Informática e Eletrônicos concentram cerca de
R$ 25,9 milhões dos R$ 38,8 milhões imobilizados em estoque — aproximadamente
67% do capital parado em apenas duas das dez categorias. Como o cálculo
multiplica preço por quantidade dentro do próprio `SUM`, ele revela o valor
financeiro real em prateleira, e não apenas o número de peças. Esse é o tipo de
indicador que interessa diretamente ao financeiro: qualquer atraso na venda
dessas duas categorias trava um volume expressivo de capital de giro.

---

### Bloco 4 — Classificação com CASE e regras de negócio

#### Tarefa 4.1 — Classificando avaliações

```sql
-- 4.1 - Classificando avaliacoes
SELECT id, nota,
CASE
WHEN nota = 5 THEN 'Excelente'
WHEN nota = 4 THEN 'Boa'
WHEN nota = 3 THEN 'Regular'
ELSE 'Insatisfatoria'
END AS faixa_avaliacao
FROM avaliacoes;
```

**Resultado:** 6.000 avaliações classificadas — `resultados/Bloco_4_Tarefa_4.1_Classificando_Avaliacoes.pdf`

**Interpretação de negócio:** O `CASE` traduz a nota numérica em um rótulo que
qualquer área da empresa entende sem precisar decorar a escala. Notas 1 e 2 são
absorvidas pelo `ELSE` como "Insatisfatória", uma decisão de negócio deliberada:
para efeito de ação corretiva, tanto faz se o cliente deu 1 ou 2 — os dois casos
exigem o mesmo tipo de resposta da empresa.

#### Tarefa 4.2 — Quantas avaliações caem em cada faixa

```sql
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
```

**Resultado:**

| faixa_avaliacao | qtde_avaliacoes |
| --- | --- |
| Excelente | 2.402 |
| Boa | 1.826 |
| Regular | 890 |
| Insatisfatória | 882 |

**Interpretação de negócio:** As avaliações positivas (Excelente e Boa) somam
4.228 de 6.000, ou 70% do total — um resultado saudável. Ainda assim, 882
clientes registraram experiências insatisfatórias, e esse é o grupo que merece
investigação: 15% de insatisfação é volume suficiente para afetar a reputação da
loja em marketplaces. Agrupar pelo próprio rótulo criado no `CASE` permitiu
contar por faixa sem repetir a lógica de classificação duas vezes.

#### Tarefa 4.3 — Taxa de aprovação de pedidos

```sql
-- 4.3 - Taxa de aprovacao de pedidos
SELECT ROUND(AVG(CASE WHEN status = 'Aprovado' THEN 1 ELSE 0 END) * 100, 2) AS taxa_aprovacao_pct
FROM pedidos;
```

**Resultado:** **70,40%**

**Interpretação de negócio:** Cerca de 30% dos pedidos não chegam à aprovação, o
que significa que quase um em cada três pedidos gerados não se converte em
receita. A técnica empregada é elegante e vale registrar: ao transformar o
status em 1 ou 0 e tirar a média, obtém-se diretamente a proporção de aprovados,
sem precisar de duas consultas separadas. Essa mesma técnica foi reaproveitada na
investigação da tarefa 5.3.

#### Tarefa 4.4 — Perfil de relacionamento dos clientes

```sql
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
```

**Resultado:**

| perfil_relacionamento | qtde_clientes |
| --- | --- |
| Fiel | 1.970 |
| Novo | 642 |
| Veterano | 388 |

**Interpretação de negócio:** A base é dominada por clientes "Fiéis" (1.970 de
3.000, ou 66%), cadastrados entre 1 e 3 anos atrás. Os 642 clientes novos
mostram que a aquisição continua funcionando, enquanto os 388 veteranos formam
um grupo pequeno mas provavelmente valioso, que acompanha a loja há mais de três
anos. A leitura estratégica é que a NexaShop tem uma base madura e estável, e
não uma operação que depende de captar clientes novos a todo momento.

---

### Bloco 5 — Desafio integrador (sem JOIN)

#### Tarefa 5.1 — Ranking de canal de venda e forma de pagamento

```sql
-- 5.1 - Ranking de canal de venda e forma de pagamento
SELECT canal_venda, forma_pagamento, COUNT(*) AS qtde_pedidos, SUM(valor_total) AS faturamento
FROM pedidos
WHERE status = 'Aprovado'
GROUP BY canal_venda, forma_pagamento
HAVING COUNT(*) >= 200
ORDER BY faturamento DESC
LIMIT 5;
```

**Resultado:**

| canal_venda | forma_pagamento | qtde_pedidos | faturamento |
| --- | --- | --- | --- |
| Site | Cartão de Crédito | 1.738 | 2.722.578,68 |
| App | Cartão de Crédito | 1.567 | 2.585.309,93 |
| Site | Pix | 1.358 | 2.341.419,61 |
| App | Pix | 1.255 | 2.172.113,36 |
| Marketplace | Cartão de Crédito | 615 | 987.848,63 |

**Interpretação de negócio:** As cinco combinações principais são todas
formadas por Site ou App pagando com Crédito ou Pix — o marketplace só aparece
na quinta posição, com faturamento três vezes menor que o do líder. Isso mostra
que os canais próprios da NexaShop sustentam o negócio, o que é positivo por
evitar dependência de intermediários e suas comissões. Esta consulta reuniu num
único comando todos os recursos da atividade: filtro, agrupamento por duas
colunas, filtro sobre o agrupamento, ordenação e limite.

#### Tarefa 5.2 — Categorias "premium" do catálogo

```sql
-- 5.2 - Categorias "premium" do catalogo
SELECT categoria, COUNT(*) AS qtde_produtos, ROUND(AVG(preco), 2) AS preco_medio
FROM produtos
WHERE ativo = 1
GROUP BY categoria
HAVING AVG(preco) > 300
ORDER BY preco_medio DESC;
```

**Resultado:**

| categoria | qtde_produtos | preco_medio |
| --- | --- | --- |
| Informática | 23 | 3.034,90 |
| Eletrônicos | 23 | 2.449,06 |
| Esporte e Lazer | 24 | 1.168,71 |
| Casa e Decoração | 25 | 528,27 |

**Interpretação de negócio:** Apenas quatro das dez categorias têm preço médio
acima de R$ 300, e Informática lidera com R$ 3.034,90 — quase seis vezes o valor
de Casa e Decoração, a última da lista. Cruzando com a tarefa 3.6, o quadro fica
coerente: são justamente essas categorias premium que concentram o capital
imobilizado em estoque. Para o negócio, elas exigem uma estratégia própria, com
foco em parcelamento e garantia, bem diferente da usada para itens de ticket
baixo.

#### Tarefa 5.3 — Investigação: o boleto cancela mais que os outros meios de pagamento?

```sql
-- 5.3 - Investigacao: o boleto cancela mais que os outros meios de pagamento?
SELECT forma_pagamento, COUNT(*) AS total_pedidos, ROUND(AVG(CASE WHEN status = 'Cancelado' THEN 1 ELSE 0 END) * 100, 2) AS taxa_cancelamento_pct
FROM pedidos
GROUP BY forma_pagamento
ORDER BY taxa_cancelamento_pct DESC;
```

**Resultado:**

| forma_pagamento | total_pedidos | taxa_cancelamento_pct |
| --- | --- | --- |
| **Boleto** | 1.397 | **29,56** |
| Cartão de Débito | 1.013 | 14,22 |
| Cartão de Crédito | 5.349 | 11,95 |
| Pix | 4.241 | 11,74 |

*(Análise completa na seção 4 deste relatório.)*

**Interpretação de negócio:** A hipótese do gestor se confirma. O boleto cancela
29,56% dos pedidos, mais que o dobro da taxa de qualquer outro meio de
pagamento. O detalhe decisivo é que os outros três meios ficam todos numa faixa
estreita entre 11,74% e 14,22% — o boleto não é apenas o pior, ele é um ponto
fora da curva.

---

## 4. Desafio investigativo (Tarefa 5.3)

Seguindo o raciocínio **sintoma → evidência → hipótese → validação → conclusão**:

**Sintoma.** Em reunião, um gestor da NexaShop afirmou que "pedidos pagos por
boleto parecem cancelar mais". A afirmação partiu de uma percepção do dia a dia,
sem respaldo numérico — e uma percepção, ainda que venha de um gestor
experiente, não é um fato até ser verificada.

**Evidência.** Calculamos a taxa de cancelamento de cada forma de pagamento,
aplicando a técnica da tarefa 4.3 (transformar o status em 1 ou 0 com `CASE` e
tirar a média) agrupada por `forma_pagamento`. Os números encontrados foram:
boleto com **29,56%** de cancelamento sobre 1.397 pedidos, cartão de débito com
14,22% sobre 1.013, cartão de crédito com 11,95% sobre 5.349 e Pix com 11,74%
sobre 4.241 pedidos.

**Hipótese.** A explicação mais provável está na natureza do próprio meio de
pagamento. Pix e cartões confirmam o pagamento em segundos, no ato da compra. O
boleto, ao contrário, tem prazo de vencimento de alguns dias, e nesse intervalo
o cliente pode desistir, esquecer de pagar, encontrar o produto mais barato em
outro lugar ou simplesmente perder o boleto. O cancelamento, nesse caso, não
seria um problema do produto nem do atendimento, mas uma consequência natural do
pagamento não instantâneo.

**Validação.** Três aspectos dos dados sustentam essa leitura. Primeiro, a
magnitude: 29,56% é mais que o dobro dos 11,74% do Pix, uma diferença grande
demais para ser variação aleatória. Segundo, o volume: 1.397 pedidos por boleto
formam uma amostra grande o bastante para que o percentual seja confiável — não
se trata de um punhado de casos isolados. Terceiro, e mais revelador, o padrão
de agrupamento: as três formas de pagamento com confirmação imediata ficam todas
concentradas entre 11,74% e 14,22%, enquanto o boleto se afasta isoladamente
desse conjunto. Se a causa fosse outra — um problema de estoque ou de logística,
por exemplo —, era de esperar que os cancelamentos se distribuíssem de forma
mais parecida entre os meios de pagamento.

**Conclusão.** **A hipótese do gestor se confirma.** Pedidos pagos por boleto de
fato cancelam significativamente mais que os demais, numa proporção de
aproximadamente 2,5 vezes. Cabe registrar, porém, o limite do que a consulta
permite afirmar: os dados comprovam **que** o boleto cancela mais, mas não
provam **por que** isso acontece. A explicação do prazo de vencimento é a
hipótese mais plausível diante do padrão observado, e não um fato demonstrado —
para confirmá-la seria preciso analisar a data de cancelamento em relação à data
do pedido, verificando se os cancelamentos se concentram próximo ao vencimento
do boleto. Do ponto de vista prático, ainda assim já é possível recomendar ações
de baixo risco: enviar lembrete de vencimento e destacar o Pix como alternativa
imediata no momento da escolha do pagamento.

---

## 5. Conclusão geral

### Os três principais insights

**1. Metade da base de clientes está em um único estado.** Santa Catarina
concentra 1.499 dos 3.000 clientes — mais que a soma dos seis estados seguintes.
Essa concentração é simultaneamente a maior força e a maior vulnerabilidade da
NexaShop: permite eficiência logística e identidade regional, mas amarra metade
do negócio à economia de um único estado.

**2. O boleto cancela 2,5 vezes mais que os demais meios de pagamento.** Com
29,56% de cancelamento contra uma faixa de 11,74% a 14,22% dos pagamentos de
confirmação imediata, o boleto é um ponto fora da curva claro. Considerando que
a taxa geral de aprovação da loja é de 70,40%, esse meio de pagamento responde
por uma parcela desproporcional da receita que não se concretiza.

**3. Dois terços do capital em estoque estão em duas categorias.** Informática e
Eletrônicos somam cerca de R$ 25,9 milhões dos R$ 38,8 milhões imobilizados, e
são também as categorias de maior preço médio (R$ 3.034,90 e R$ 2.449,06). São
as que mais imobilizam capital de giro e, portanto, as que exigem maior
disciplina de giro de estoque.

### Recomendação de negócio

**Reduzir o cancelamento em pedidos por boleto.** É a ação com melhor relação
entre esforço e retorno identificada nesta análise. Recomendamos três medidas
combinadas: enviar lembrete automático de vencimento por e-mail e SMS antes do
prazo final; oferecer o Pix como alternativa destacada no momento do pagamento,
já que ele tem a menor taxa de cancelamento (11,74%) e é igualmente à vista; e
reservar o estoque do pedido por prazo menor que o vencimento do boleto,
evitando que produtos de categorias de alto valor fiquem bloqueados por vendas
que provavelmente não se concretizarão. Considerando os 1.397 pedidos por boleto
registrados, reduzir esse cancelamento à média dos demais meios recuperaria
aproximadamente 220 pedidos.

Vale ressaltar uma limitação desta recomendação: como não conseguimos cruzar
pedidos com clientes, não sabemos se o cancelamento por boleto se concentra em
um perfil específico de comprador. Essa investigação depende das técnicas da
próxima unidade.

---

## 6. Ponte para a próxima aula (Tarefa 6.1)

**(a) A pergunta que tentamos responder e não conseguimos**

Durante a análise do bloco 3, ao descobrirmos que Santa Catarina concentra
metade dos clientes, surgiu naturalmente a pergunta seguinte: **quais cidades
geram mais faturamento para a NexaShop?** Sabíamos onde os clientes estão e
sabíamos quanto a loja fatura, mas não conseguimos ligar uma coisa à outra com
uma consulta só.

**(b) Onde está cada informação necessária**

A informação está dividida entre duas tabelas diferentes:

| Informação necessária | Tabela onde está | Coluna |
| --- | --- | --- |
| Cidade do cliente | `clientes` | `cidade` |
| Valor do pedido | `pedidos` | `valor_total` |

A tabela `clientes` sabe onde cada pessoa mora, mas não sabe quanto ela gastou.
A tabela `pedidos` sabe o valor de cada compra, mas não sabe de onde veio o
cliente que a fez.

**(c) Por que é necessário combinar as duas tabelas**

Nenhuma das duas tabelas contém, sozinha, todas as colunas de que precisamos.
Poderíamos agrupar `pedidos` por qualquer coluna que ele já tenha — forma de
pagamento, canal de venda, status —, mas não por cidade, porque essa coluna
simplesmente não existe ali. Tentar contornar isso rodando duas consultas
separadas não resolve: teríamos uma lista de clientes por cidade e outra lista de
valores por pedido, sem nenhuma forma de saber qual pedido pertence a qual
cliente.

O que falta é uma maneira de dizer ao banco que o cliente identificado em
`pedidos` é a mesma pessoa cadastrada em `clientes` — ou seja, uma operação que
combine as duas tabelas usando a coluna que as conecta, o identificador do
cliente. Com essa ligação, cada pedido "herdaria" a cidade do cliente que o fez,
e aí sim poderíamos agrupar o faturamento por cidade.

Entendemos que é exatamente esse o tema da próxima aula: as operações de junção
(`JOIN`), que permitem consultar duas ou mais tabelas relacionadas como se
fossem uma só. Várias perguntas que ficaram em aberto nesta atividade — como o
perfil dos clientes que mais cancelam por boleto, ou quais categorias cada
segmento prefere — dependem dessa técnica para serem respondidas.

---

## Anexo — Script SQL

O arquivo [`consultas_nexashop.sql`](consultas_nexashop.sql) contém todas as 23
consultas desta atividade, numeradas e comentadas, na ordem dos blocos
(Atividade 0 e blocos 1 a 5).

Os resultados de cada consulta, exportados do MySQL/MariaDB, estão na pasta
[`resultados/`](resultados/), com um arquivo PDF por tarefa.
