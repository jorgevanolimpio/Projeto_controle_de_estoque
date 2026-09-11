-- =============================================================
-- Nome: vendas_produto_fev2025_nao_cadastrados
-- Descrição: Exibe vendas agrupadas por produtos em quantidade e valores no mês de fevereiro de 2025
-- Usado por: 
-- Criado em: 11/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

SELECT
    v.venda_id,
    TO_CHAR(v.data_emissao, 'DD/MM/YYYY') AS data_emissao,
    v.horariomov,
    v.filial_id,
    v.item,
    v.produto_id,
    v.qtde_vendida,
    v.valor_unitario
FROM public.venda v
LEFT JOIN public.produtos_filial pf
    ON pf.filial_id = v.filial_id
   AND pf.produto_id = v.produto_id
WHERE v.data_emissao BETWEEN DATE '2025-02-01'
  AND DATE '2025-02-28'
  AND pf.produto_id IS NULL
ORDER BY
    v.data_emissao,
    v.venda_id,
    v.item;