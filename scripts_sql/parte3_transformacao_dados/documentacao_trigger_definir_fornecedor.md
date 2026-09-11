# Trigger para definição automática de fornecedor

Esta documentação descreve a criação e o teste da trigger implementada em `trigger_definir_fornecedor.sql`. A trigger automatiza o vínculo entre `produtos_filial` e `fornecedor` durante a inclusão ou alteração de um produto.

## Finalidade

Ao gravar um produto em `public.produtos_filial`, o processo aceita duas formas de informar seu fornecedor:

1. informar diretamente `fornecedor_id`; ou
2. informar `razao_social_fornecedor` e deixar a trigger localizar ou cadastrar o fornecedor, preenchendo `fornecedor_id` automaticamente.

Se nenhuma dessas informações for fornecida, a operação é interrompida com erro.

## Script de criação

Execute [trigger_definir_fornecedor.sql](trigger_definir_fornecedor.sql) em um banco PostgreSQL que já contenha as tabelas `public.produtos_filial` e `public.fornecedor`.

O script executa as etapas abaixo.

### 1. Criação do campo auxiliar no produto

```sql
ALTER TABLE public.produtos_filial
ADD COLUMN razao_social_fornecedor varchar;
```

Esse campo recebe a razão social quando o identificador numérico do fornecedor não é conhecido no momento da gravação.

### 2. Garantia de unicidade do fornecedor

```sql
ALTER TABLE public.fornecedor
ADD CONSTRAINT fornecedor_fornecedor_id_uk UNIQUE (fornecedor_id);
```

A restrição permite que `fornecedor_id` seja referenciado isoladamente por uma chave estrangeira.

### 3. Criação do relacionamento entre produto e fornecedor

```sql
ALTER TABLE public.produtos_filial
ADD CONSTRAINT produtos_filial_fornecedor_fk
FOREIGN KEY (fornecedor_id)
REFERENCES public.fornecedor (fornecedor_id);
```

Com isso, todo `fornecedor_id` registrado em `produtos_filial` precisa existir em `fornecedor`.

### 4. Criação da função

A função `public.fn_definir_fornecedor_produto()` é escrita em PL/pgSQL e é executada antes da inserção ou atualização do produto.

Sua lógica é:

```text
fornecedor_id informado?
├── Sim: mantém o valor; a chave estrangeira valida a existência.
└── Não: razao_social_fornecedor foi informada?
    ├── Não: interrompe a operação com exceção.
    └── Sim: insere ou localiza o fornecedor pela razão social
        e preenche NEW.fornecedor_id.
```

O comando `INSERT ... ON CONFLICT (razao_social) DO UPDATE ... RETURNING fornecedor_id` reutiliza o fornecedor existente quando a mesma razão social já estiver cadastrada. Para esse fluxo funcionar, `razao_social` deve possuir uma restrição `UNIQUE` ou uma chave primária compatível com o `ON CONFLICT`.

### 5. Criação da trigger

```sql
CREATE TRIGGER trg_definir_fornecedor_produto
BEFORE INSERT OR UPDATE OF fornecedor_id, razao_social_fornecedor
ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION public.fn_definir_fornecedor_produto();
```

A trigger é executada para cada linha antes de um `INSERT` ou de uma atualização dos campos `fornecedor_id` ou `razao_social_fornecedor`.

## Teste

Execute [insert_teste_trigger.sql](insert_teste_trigger.sql) após criar a função e a trigger.

O script insere o produto `PROD-001` na filial `1` sem fornecer `fornecedor_id`, mas com a razão social `Fornecedor Exemplo Ltda.`. O comportamento esperado é:

1. a trigger identifica a ausência de `fornecedor_id`;
2. o fornecedor é criado, se ainda não existir, ou localizado por `razao_social`;
3. `fornecedor_id` é gravado automaticamente no produto;
4. o produto é inserido respeitando a chave estrangeira.

Use a consulta abaixo para verificar o resultado:

```sql
SELECT
    pf.filial_id,
    pf.produto_id,
    pf.descricao,
    pf.fornecedor_id,
    f.razao_social
FROM public.produtos_filial pf
INNER JOIN public.fornecedor f
    ON f.fornecedor_id = pf.fornecedor_id
WHERE pf.filial_id = 1
  AND pf.produto_id = 'PROD-001';
```

## Pré-requisitos e cuidados

- Execute o script de criação apenas uma vez por banco, pois ele adiciona coluna e restrições sem usar `IF NOT EXISTS`.
- A inserção automática em `fornecedor` informa apenas `razao_social`. Portanto, `fornecedor_id` precisa ser gerado automaticamente pelo banco, por exemplo com `IDENTITY`, `SERIAL` ou uma sequência com valor padrão.
- O `ON CONFLICT (razao_social)` requer unicidade em `fornecedor.razao_social`. Verifique se ela já é chave primária ou possui uma restrição `UNIQUE` antes de criar a função.
- Se o produto já tiver `fornecedor_id`, a trigger não substitui esse valor com base na razão social.
- O script de teste inclui dados de exemplo. Não o execute em produção sem ajustar ou remover os valores de teste.
