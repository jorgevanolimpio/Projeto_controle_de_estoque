-- =============================================================
-- Nome: produtos_estoque_solicitado_mais_10x
-- Descrição: Exibe produtos solicitados em estoque com mais de 10x
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
    pf.filial_id,
    CONCAT_WS(' - ', pf.produto_id, pf.descricao) AS produto,
    pf.estoque,
    pf.preco_unitario,
    pf.preco_compra,
    pf.preco_venda,
    pf.fornecedor_id,
    pr.total_requisicoes
FROM public.produtos_filial pf
INNER JOIN produtos_requisitados pr
    ON pr.filial_id = pf.filial_id
   AND pr.produto_id = pf.produto_id
ORDER BY
    pf.estoque