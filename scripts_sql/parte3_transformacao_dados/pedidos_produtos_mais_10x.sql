-- =============================================================
-- Nome: pedidos_produtos_mais_10x
-- Descrição: Pedidos de produto com mais de 10 vezes no periodo
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

WITH produtos_requisitados AS (
    SELECT
        pc.filial_id,
        pc.produto_id,
        COUNT(DISTINCT pc.pedido_id) AS total_requisicoes
    FROM public.pedido_compra pc
    GROUP BY
        pc.filial_id,
        pc.produto_id
    HAVING COUNT(DISTINCT pc.pedido_id) > 10
)
SELECT
    pc.pedido_id,
    pc.item,
    pc.ordem_compra,
    pc.filial_id,
    CONCAT_WS(' - ', pc.produto_id, pc.descricao_produto) AS produto,
    TO_CHAR(pc.data_pedido, 'DD/MM/YYYY') AS data_pedido,
    TO_CHAR(pc.data_entrega, 'DD/MM/YYYY') AS data_entrega,
    pc.qtde_pedida,
    pc.qtde_entregue,
    pc.qtde_pendente,
    pc.preco_compra,
    pr.total_requisicoes
FROM public.pedido_compra pc
INNER JOIN produtos_requisitados pr
    ON pr.filial_id = pc.filial_id
   AND pr.produto_id = pc.produto_id
ORDER BY
    pr.total_requisicoes DESC,
    pc.produto_id,
    pc.data_pedido,
    pc.pedido_id;