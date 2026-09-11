-- =============================================================
-- Nome: recebimento_x_pedido_produto_fev2025
-- Descrição: Exibe recebimento acima do solicitado no mês de fevereiro de 2025
-- Usado por: 
-- Criado em: 11/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

WITH recebimentos AS (
    SELECT
        em.ordem_compra,
        em.filial_id,
        em.item,
        em.produto_id,
        SUM(em.qtde_recebida) AS qtde_total_recebida
    FROM public.entradas_mercadoria em
    GROUP BY
        em.ordem_compra,
        em.filial_id,
        em.item,
        em.produto_id
)
SELECT
    pc.pedido_id,
    pc.ordem_compra,
    pc.item,
    pc.filial_id,
    pc.produto_id,
    pc.qtde_pedida,
    r.qtde_total_recebida,
    r.qtde_total_recebida - pc.qtde_pedida AS qtde_recebida_acima_do_pedido
FROM public.pedido_compra pc
INNER JOIN recebimentos r
    ON r.ordem_compra = pc.ordem_compra
   AND r.filial_id = pc.filial_id
   AND r.item = pc.item
   AND r.produto_id = pc.produto_id
WHERE r.qtde_total_recebida > pc.qtde_pedida
  AND (
        pc.data_pedido >= DATE '2025-02-01'
        AND pc.data_pedido <= DATE '2025-02-28'
        OR EXISTS (
            SELECT 1
            FROM public.entradas_mercadoria em
            WHERE em.ordem_compra = pc.ordem_compra
              AND em.filial_id = pc.filial_id
              AND em.item = pc.item
              AND em.produto_id = pc.produto_id
              AND em.data_entrada >= DATE '2025-02-01'
              AND em.data_entrada <= DATE '2025-02-28'
        )
      )
ORDER BY
    pc.ordem_compra,
    pc.filial_id,
    pc.item,
    pc.produto_id;