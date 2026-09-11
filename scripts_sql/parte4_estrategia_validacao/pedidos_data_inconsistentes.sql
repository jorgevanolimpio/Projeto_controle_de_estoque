-- =============================================================
-- Nome: pedidos_data_inconsistentes
-- Descrição: Exibe pedidos com datas de entregas menor que a data de pedido
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

SELECT
    pedido_id,
    item,
    ordem_compra,
    produto_id,
    data_pedido,
    data_entrega
FROM public.pedido_compra
WHERE data_entrega < data_pedido
ORDER BY
    data_pedido,
    pedido_id,
    item;