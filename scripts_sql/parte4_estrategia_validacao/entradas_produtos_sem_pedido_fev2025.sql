-- =============================================================
-- Nome: entradas_produtos_sem_pedido_fev2025
-- Descrição: Exibe entradas de produtos sem pedido de compra no mês de fevereiro de 2025
-- Usado por: 
-- Criado em: 11/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

SELECT
    TO_CHAR(em.data_entrada, 'DD/MM/YYYY') AS data_entrada,
    em.nro_nfe,
    em.ordem_compra,
    em.filial_id,
    em.item,
    em.produto_id,
    em.descricao_produto,
    em.qtde_recebida,
    em.custo_unitario
FROM public.entradas_mercadoria em
LEFT JOIN public.pedido_compra pc
    ON pc.ordem_compra = em.ordem_compra
   AND pc.filial_id = em.filial_id
   AND pc.item = em.item
   AND pc.produto_id = em.produto_id
WHERE em.data_entrada BETWEEN DATE '2025-02-01'
  AND  DATE '2025-02-28'
  AND pc.produto_id IS NULL
ORDER BY
    em.data_entrada,
    em.nro_nfe,
    em.item;