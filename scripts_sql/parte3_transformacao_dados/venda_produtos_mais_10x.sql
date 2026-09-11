-- =============================================================
-- Nome: venda_produtos_mais_10x
-- Descrição: Exibe vendas de produtos solicitados mais de 10x
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
    v.venda_id,
    v.item,
    v.filial_id,
    CONCAT_WS(' - ', v.produto_id, pf.descricao) AS produto,
    TO_CHAR(v.data_emissao, 'DD/MM/YYYY') AS data_emissao,
    v.horariomov AS horario_movimento,
    v.unidade_medida,
    v.qtde_vendida,
    v.valor_unitario,
    v.qtde_vendida * v.valor_unitario AS valor_total,
    pr.total_requisicoes
FROM public.venda v
INNER JOIN produtos_requisitados pr
    ON pr.filial_id = v.filial_id
   AND pr.produto_id = v.produto_id
LEFT JOIN public.produtos_filial pf
    ON pf.filial_id = v.filial_id
   AND pf.produto_id = v.produto_id
ORDER BY
    v.data_emissao,
    v.venda_id,
    v.item;