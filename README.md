# Desafio SysStock

Projeto de ETL, modelagem relacional e validação de dados para um cenário de controle de estoque. A solução lê uma planilha Excel, padroniza e valida os dados, envia os registros aprovados ao PostgreSQL e disponibiliza scripts SQL para análise, transformação, integridade e automação do vínculo com fornecedores.

## Objetivo

Estruturar dados de vendas, pedidos de compra, entradas de mercadoria, produtos por filial e fornecedores, permitindo:

- carga de dados tratados no PostgreSQL;
- retenção de registros inválidos para revisão;
- consultas operacionais e analíticas;
- validação de inconsistências de dados;
- associação automática de fornecedores aos produtos por meio de trigger.

## Estrutura do projeto

```text
.
├── base_teste_systock.xlsx                     # Fonte de dados de entrada
├── main.ipynb                                  # Pipeline ETL
├── models.py                                   # Modelos SQLAlchemy e criação das tabelas
├── requirements.txt                            # Dependências Python
├── dados_para_revisar/
│   └── pedidos_para_revisar.xlsx                # Registros rejeitados pelo ETL
├── docs/
│   ├── data_dictionary.md                       # Dicionário de dados
│   └── etl_pipelines.md                         # Registro do pipeline ETL
└── scripts_sql/
    ├── regras_de_negocios.md                    # Regras e pontos de validação com o cliente
    ├── parte2_consultas_basicas/                # Consultas operacionais
    ├── parte3_transformacao_dados/              # Consultas analíticas e trigger de fornecedor
    └── parte4_estrategia_validacao/             # Consultas de qualidade dos dados
```

## Dados de origem

O arquivo `base_teste_systock.xlsx` possui cinco abas:

| Aba | Conteúdo |
|---|---|
| `venda` | Itens vendidos, quantidade, preço, data, horário e filial. |
| `pedido_compra` | Pedidos, produtos solicitados, quantidades, fornecedor e entrega. |
| `entradas_mercadoria` | Recebimentos de mercadoria e custo unitário. |
| `produtos_filial` | Produto, estoque, preços e fornecedor por filial. |
| `fornecedor` | Identificador e razão social dos fornecedores. |

Os detalhes dos campos estão em [docs/data_dictionary.md](docs/data_dictionary.md).

## Pipeline ETL

O notebook [main.ipynb](main.ipynb) faz a extração, transformação e carga dos dados no PostgreSQL.

### Etapas

1. Lê as cinco abas do arquivo Excel.
2. Padroniza datas, números, textos e identificadores.
3. Corrige os nomes de campos de `produtos_filial` e `fornecedor`.
4. Remove duplicidades.
5. Valida campos obrigatórios, valores negativos, datas inconsistentes e recebimentos acima do solicitado.
6. Salva registros rejeitados em `dados_para_revisar/` com uma coluna `erro`.
7. Insere dados válidos com `ON CONFLICT DO NOTHING`.

Ordem de carga:

```text
fornecedor → produtos_filial → pedido_compra → entradas_mercadoria → venda
```

O comportamento detalhado do processo está em [docs/etl_pipelines.md](docs/etl_pipelines.md).

## Pré-requisitos

- Python 3.10 ou superior;
- PostgreSQL acessível;
- Jupyter Notebook ou JupyterLab.

Instale as bibliotecas do projeto:

```bash
python -m venv .venv
```

No Windows:

```powershell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

No Linux ou macOS:

```bash
source .venv/bin/activate
pip install -r requirements.txt
```

## Configuração do banco

O notebook utiliza a variável de ambiente `DATABASE_URL`. Crie um arquivo `.env` na raiz do projeto com uma conexão válida:

```env
DATABASE_URL=postgresql+psycopg://usuario:senha@localhost:5432/desafio_systock
```

Não versione o arquivo `.env`.

> `models.py` contém a definição ORM das tabelas e executa `Base.metadata.create_all(...)`. Antes de utilizar o projeto em outro ambiente, revise a URL fixa presente nesse arquivo para evitar credenciais no código-fonte e manter a configuração alinhada ao `DATABASE_URL`.

## Execução

1. Crie o banco `desafio_systock` no PostgreSQL.
2. Configure `DATABASE_URL` no arquivo `.env`.
3. Mantenha `base_teste_systock.xlsx` na raiz do projeto.
4. Inicie o Jupyter:

   ```bash
   jupyter notebook
   ```

5. Abra `main.ipynb` e execute as células na sequência apresentada.
6. Revise os arquivos gerados em `dados_para_revisar/`.

## Scripts SQL

Todos os scripts consideram as tabelas no schema `public` do PostgreSQL.

### Consultas básicas

| Arquivo | Descrição |
|---|---|
| `parte2_consultas_basicas/vendas_produto_fev2025.sql` | Soma quantidade e valor de vendas por produto em fevereiro de 2025. |
| `parte2_consultas_basicas/produtos_nao_entregues.sql` | Lista produtos de pedidos sem entrada de mercadoria correspondente. |

### Transformação e análise

| Arquivo | Descrição |
|---|---|
| `venda_produtos_mais_10x.sql` | Exibe vendas dos produtos requisitados em mais de dez pedidos. |
| `produtos_estoque_solicitados_mais_10x.sql` | Mostra estoque e preços desses produtos. |
| `pedidos_produtos_mais_10x.sql` | Lista os pedidos desses produtos e suas quantidades pendentes. |

### Validação de dados

| Arquivo | Descrição |
|---|---|
| `vendas_produto_fev2025_nao_cadastrados.sql` | Identifica vendas de fevereiro sem produto cadastrado na filial. |
| `valida_estoque_negativo.sql` | Verifica estoque ou preços negativos. |
| `recebimento_x_pedido_produto_fev2025.sql` | Identifica recebimentos acima do solicitado. |
| `pedidos_data_inconsistentes.sql` | Localiza entregas previstas antes da data do pedido. |
| `entradas_produtos_sem_pedido_fev2025.sql` | Identifica entradas sem pedido de compra. |

## Trigger de fornecedor

Os scripts abaixo automatizam o fornecedor de um produto:

- [trigger_definir_fornecedor.sql](scripts_sql/parte3_transformacao_dados/trigger_definir_fornecedor.sql) cria uma coluna auxiliar, as restrições, a função PL/pgSQL e a trigger.
- [insert_teste_trigger.sql](scripts_sql/parte3_transformacao_dados/insert_teste_trigger.sql) insere um produto de exemplo sem `fornecedor_id`, usando a razão social para localizar ou cadastrar o fornecedor.
- [documentacao_trigger_definir_fornecedor.md](scripts_sql/parte3_transformacao_dados/documentacao_trigger_definir_fornecedor.md) descreve a regra, o teste e os pré-requisitos da trigger.

## Pontos de atenção

- A aba `pedido_compra` possui dois blocos de dados. O ETL trata e une ambos antes da validação.
- Os identificadores de fornecedor da planilha usam o prefixo `F`; o pipeline o remove para trabalhar com IDs numéricos.
- `qtde_pendente` é calculada como `qtde_pedida - qtde_entregue` durante o tratamento de pedidos.
- A trigger requer que `fornecedor_id` seja gerado automaticamente no banco e que `razao_social` tenha unicidade para o `ON CONFLICT` funcionar.
- A execução do notebook é manual. Não há agendamento, alertas ou retentativas automáticas configuradas.

## Documentação complementar

- [Dicionário de dados](docs/data_dictionary.md)
- [Registro do pipeline ETL](docs/etl_pipelines.md)
- [Regras de negócio](scripts_sql/regras_de_negocios.md)
