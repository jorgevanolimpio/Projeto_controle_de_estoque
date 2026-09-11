# Registro de Pipeline ETL

## Job: `etl_base_systock`

- **Fonte**: arquivo `base_teste_systock.xlsx`, localizado na raiz do projeto.
- **Abas de origem**: `venda`, `pedido_compra`, `entradas_mercadoria`, `produtos_filial` e `fornecedor`.
- **Destino**: tabelas `fornecedor`, `produtos_filial`, `pedido_compra`, `entradas_mercadoria` e `venda` no PostgreSQL `desafio_systock`.
- **Executor**: notebook `main.ipynb`.
- **Frequência**: sob demanda. O notebook informa carga diária como intenção operacional, mas não há agendador configurado no projeto.
- **Orquestração**: execução manual pelo Jupyter Notebook/JupyterLab.
- **Dependências**: Python, Pandas, OpenPyXL, SQLAlchemy, Psycopg e `python-dotenv`; variável de ambiente `DATABASE_URL` configurada.

## Finalidade

Carregar dados operacionais de estoque no PostgreSQL após padronização, validação e remoção de duplicidades. Registros que não atendem às regras são gravados em arquivos Excel na pasta `dados_para_revisar/` e não são enviados ao banco.

## Etapas do processo

1. Carrega as cinco abas da planilha de origem uma única vez.
2. Padroniza tipos de dados, nomes de campos e valores textuais.
3. Remove espaços no início/fim de textos e elimina linhas duplicadas.
4. Aplica regras de validação específicas por entidade.
5. Separa registros válidos e inválidos.
6. Exporta os registros inválidos para arquivos de revisão, quando existirem.
7. Cria a conexão PostgreSQL a partir de `DATABASE_URL`.
8. Insere os registros válidos com `INSERT ... ON CONFLICT DO NOTHING`.
9. Libera as conexões ao final da execução.

## Ordem de carga

```text
fornecedor → produtos_filial → pedido_compra → entradas_mercadoria → venda
```

Essa é a ordem utilizada no notebook para carregar primeiro as entidades de referência e depois os movimentos.

## Transformações e validações

### `venda`

**Transformações**

- Converte `venda_id`, `filial_id` e `item` para inteiro anulável.
- Converte `data_emissao` para data/hora.
- Remove espaços de `horariomov`, `produto_id` e `unidade_medida`.
- Converte `qtde_vendida` e `valor_unitario` para numérico.
- Remove registros duplicados.

**Validações**

- `data_emissao` e `produto_id` obrigatórios.
- `qtde_vendida` obrigatória e não negativa.
- `valor_unitario` obrigatório e não negativo.

**Arquivo de pendências**: `dados_para_revisar/vendas_para_revisar.xlsx`.

### `pedido_compra`

**Tratamento estrutural**

A aba possui dois blocos de dados. O primeiro contém doze colunas com cabeçalhos. O segundo contém registros sem cabeçalho e uma coluna excedente, removida pelo notebook. Após nomear as colunas, o ETL une os blocos e atribui `pedido_id` nulo aos registros do segundo bloco.

**Transformações**

- Converte `data_pedido` e `data_entrega` para data/hora.
- Converte `pedido_id`, `item`, `ordem_compra`, `qtde_pedida`, `filial_id`, `qtde_entregue` e `fornecedor_id` para inteiro anulável.
- Converte `preco_compra` para numérico e remove espaços de `produto_id` e `descricao_produto`.
- Remove registros duplicados.
- Calcula `qtde_pendente` como `qtde_pedida - qtde_entregue` para compatibilizar os dados com o schema de destino.

**Validações**

- `produto_id`, `descricao_produto` e `fornecedor_id` obrigatórios.
- `ordem_compra` obrigatória e diferente de zero.
- `qtde_pedida` obrigatória e não negativa.
- `qtde_entregue` não pode ser maior que `qtde_pedida`.
- `preco_compra` obrigatório e não negativo.
- `data_entrega` não pode ser anterior a `data_pedido`.

**Arquivo de pendências**: `dados_para_revisar/pedidos_para_revisar.xlsx`.

### `entradas_mercadoria`

**Transformações**

- Converte `data_entrada` para data/hora.
- Remove espaços de `nro_nfe`, `produto_id` e `descricao_produto`.
- Converte `item`, `ordem_compra`, `qtde_recebida` e `filial_id` para inteiro anulável.
- Converte `custo_unitario` para numérico e remove duplicidades.

**Validações**

- `nro_nfe` obrigatório.
- `ordem_compra` obrigatória e não negativa.
- `qtde_recebida` obrigatória e não negativa.
- `custo_unitario` obrigatório e não negativo.

**Arquivo de pendências**: `dados_para_revisar/entradas_mercadoria_para_revisar.xlsx`.

### `produtos_filial`

**Transformações**

- Renomeia `idproduto` para `produto_id` e `idfornecedor` para `fornecedor_id`.
- Remove o prefixo `F` de `fornecedor_id` e converte o valor para inteiro anulável.
- Converte `filial_id` e `estoque` para inteiro anulável.
- Converte `preco_unitario`, `preco_compra` e `preco_venda` para numérico.
- Remove espaços de `produto_id` e `descricao`, além de duplicidades.

**Validações**

- `produto_id`, `descricao` e `fornecedor_id` obrigatórios.
- `estoque`, `preco_unitario`, `preco_compra` e `preco_venda` não podem ser nulos ou negativos.

**Arquivo de pendências**: `dados_para_revisar/produtos_filial_para_revisar.xlsx`.

### `fornecedor`

**Transformações**

- Renomeia `idfornecedor` para `fornecedor_id`.
- Remove o prefixo `F` e converte `fornecedor_id` para inteiro.
- Remove espaços de `razao_social` e duplicidades pela razão social.

**Validações**

- `razao_social` obrigatória.

**Arquivo de pendências**: `dados_para_revisar/fornecedor_para_revisar.xlsx`.

## Estratégia de carga

Cada entidade é carregada com `sqlalchemy.dialects.postgresql.insert` e `on_conflict_do_nothing`. Assim, uma nova execução não interrompe a carga quando a chave de conflito já existe.

| Tabela | Colunas usadas para conflito |
|---|---|
| `fornecedor` | `fornecedor_id`, `razao_social` |
| `produtos_filial` | `filial_id`, `produto_id` |
| `pedido_compra` | `pedido_id`, `produto_id`, `item` |
| `entradas_mercadoria` | `ordem_compra`, `item`, `produto_id`, `nro_nfe` |
| `venda` | `filial_id`, `venda_id`, `data_emissao`, `produto_id`, `item`, `horariomov` |

O notebook registra no log o número de linhas válidas e o número de linhas efetivamente inseridas por tabela. Em caso de falha durante a inserção, a transação é desfeita e a exceção é registrada.

## Tratamento de erros e limitações

- A ausência de `DATABASE_URL` interrompe o notebook antes da conexão com o banco.
- Registros inválidos são retidos nos arquivos de revisão, com a coluna `erro` descrevendo cada problema identificado.
- Não há agendamento, alertas automáticos, tentativas de reexecução nem monitoramento configurados.
- As validações de relacionamento entre tabelas são tratadas pelas consultas em `scripts_sql/parte4_estrategia_validacao/`, e não pelo notebook de carga.
- O notebook deve ser executado na ordem de suas células, pois os DataFrames tratados são reutilizados nas etapas posteriores.

## Histórico de mudanças

| Data | Mudança | Autor |
|---|---|---|
| 2026-09-11 | Registro criado a partir da implementação de `main.ipynb`. | |
