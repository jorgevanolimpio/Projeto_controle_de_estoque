# Dicionário de Dados

## Tabela: `venda`

**Descrição**: Tabela fato com uma linha por item vendido em cada venda.
**Grão**: 1 linha = 1 item de 1 venda.
**Atualização**: diária.

| Coluna | Tipo | Nulo? | Descrição | Exemplo |
|---|---|---|---|---|
| `venda_id` | INT | Não | Identificador da venda, Chave primária | `10234` |
| `data_emissao` | DATE | Não | Data da venda, Chave primária | `1/11/2025` |
| `horarimov` | VARCHAR(8) | Não | Horário da venda, Chave primária | `00:00:00` |
| `produto_id` | VARCHAR(25) | Não | Identificador do produto, Chave primária | `P1` |
| `qtde_vendida` | FLOAT | Sim | Quantidade vendida do produto | `5` |
| `valor_unitario` | NUMERIC (15,4) | Não | Valor monetário unitário do produto | `78,93` |
| `filial_id` | BIGINT | Não | Identificador da filial, chave primária | `1` |
| `item` | INT | Não | | Quantidade de itens na venda, chave primária | `1` |
| `unidade_medida` | VARCHAR(3) | Não | | Unidade de medida do produto | `UN` |
---

## Tabela: `pedido_compra`

**Descrição**: Tabela de pedido com uma linha por item pedido.
**Grão**: 1 linha = 1 item de 1 pedido.

| Coluna | Tipo | Nulo? | Descrição | Exemplo |
|---|---|---|---|---|
| `pedido_id` | BIGINT | Não | Identificador do pedido, Chave primária | `1` |
| `data_pedido` | DATE | Não | Data do pedido | `2025-01-02` |
| `item` | INT | Não | Quantidade de itens na venda, chave primária | `1` |
| `produto_id` | VARCHAR(25) | Não | Identificador do produto, Chave primária | `P1` |
| `descricao_produto` | VARCHAR(255) | Não | Descrição do produto | `Produto 1` |
| `ordem_compra` | BIGINT | Não | Identificador da ordem de compra | `1` |
| `qtde_pedida` | FLOAT | Não | Quantidade pedida do produto | `5` |
| `filial_id` | BIGINT | Não | Identificador da filial, chave primária | `1` |
| `data_entrega` | DATE | Não | Data prevista da entrega | `2025-01-02` |
| `qtde_entregue` | FLOAT | Não | Quantidade entregue do produto | `5` |
| `valor_unitario` | NUMERIC (15,4) | Não | Valor monetário unitário do produto | `78,93` |
| `fornecedor_id` | BIGINT | Não | Identificador do fornecedor | `1` |
---

## Tabela: `entradas_mercadoria`

**Descrição**: Tabela de entrada de mercadoria com uma linha por item de entrada.
**Grão**: 1 linha = 1 item de 1 entrada.

| Coluna | Tipo | Nulo? | Descrição | Exemplo |
|---|---|---|---|---|
| `data_entrada` | DATE | Não | Data de entrada | `2025-01-02` |
| `nro_nfe` | VARCHAR(25) | Não | Identificador da nota fiscal de entrada, chave primária | `NFE1` |
| `item` | INT | Não | Quantidade de itens na venda, chave primária | `1` |
| `produto_id` | VARCHAR(25) | Não | Identificador do produto, chave primária | `P1` |
| `descricao_produto` | VARCHAR(255) | Não | Descrição do produto | `Produto 1` |
| `ordem_compra` | BIGINT | Não | Identificador da ordem de compra, chave primária | `1` |
| `qtde_recebida` | FLOAT | Não | Quantidade pedida do produto | `5` |
| `filial_id` | BIGINT | Não | Identificador da filial, chave primária | `1` |
| `custo_unitario` | NUMERIC (15,4) | Não | Valor monetário do custo unitário do produto | `84,35` |
---

## Tabela: `produtos_filial`

**Descrição**: Tabela de produtos por filial com uma linha por produto.
**Grão**: 1 linha = 1 filial e 1 produto.

| Coluna | Tipo | Nulo? | Descrição | Exemplo |
|---|---|---|---|---|
| `filial_id` | BIGINT | Não | Identificador da filial, chave primária | `1` |
| `produto_id` | VARCHAR(25) | Não | Identificador do produto, chave primária | `P1` |
| `descricao` | VARCHAR(255) | Não | Descrição do produto | `Produto 1` |
| `estque` | FLOAT | Não | Quantidade do produto em estoque | `88` |
| `preco_unitario` | NUMERIC (15,4) | Não | Valor monetário do preço unitário do produto | `42,65` |
| `preco_compra` | NUMERIC (15,4) | Não | Valor monetário do precõ da compra do produto | `114,13` |
| `preco_venda` | NUMERIC (15,4) | Não | Valor monetário do preço de venda do produto | `84,35` |
| `idfornecedor` | VARCHAR(25) | Não | Identificador do fornecedor | `F8` |
---

## Tabela: `fornecedor`

**Descrição**: Tabela de fornecedores com uma linha por fornecedor.
**Grão**: 1 linha = 1 fornecedor.

| Coluna | Tipo | Nulo? | Descrição | Exemplo |
|---|---|---|---|---|
| `idfornecedor` | VARCHAR(25) | Não | Identificador do fornecedor, chave primária | `F1` |
| `razao_social` | VARCHAR(255) | Não | Razão Social do fornecedor, chave primária | `Fornecedor 1 LTDA` |
---