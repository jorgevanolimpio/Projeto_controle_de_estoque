-- Use o insert abaixo para testar a funcionalidade da TRIGGER criada 

INSERT INTO public.produtos_filial (
    filial_id,
    produto_id,
    descricao,
    estoque,
    preco_unitario,
    preco_compra,
    preco_venda,
    razao_social_fornecedor
)
VALUES (
    1,
    'PROD-001',
    'Produto de exemplo',
    0,
    10.00,
    8.00,
    12.00,
    'Fornecedor Exemplo Ltda.'
);