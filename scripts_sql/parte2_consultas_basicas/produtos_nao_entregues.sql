-- =============================================================
-- Nome: produtos_nao_entregues
-- Descrição: Exibe produtos solicitados que não foram entregues
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================


SELECT
    pc.pedido_id,
    pc.ordem_compra,
    pc.data_pedido,
    pc.filial_id,
    pc.produto_id,
    pc.descricao_produto,
    pc.qtde_pedida,
    pc.data_entrega,
    pc.fornecedor_id,
    f.razao_social AS fornecedor
FROM public.pedido_compra pc
LEFT JOIN public.fornecedor f
    ON f.fornecedor_id = pc.fornecedor_id
WHERE NOT EXISTS (
    SELECT 1
    FROM public.entradas_mercadoria em
    WHERE em.ordem_compra = pc.ordem_compra
      AND em.filial_id = pc.filial_id
      AND em.item = pc.item
      AND em.produto_id = pc.produto_id
)
ORDER BY
    pc.data_pedido,
    pc.ordem_compra,
    pc.produto_id;