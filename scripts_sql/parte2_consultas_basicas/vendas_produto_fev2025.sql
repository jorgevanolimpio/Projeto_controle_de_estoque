-- =============================================================
-- Nome: vendas_produto_fev2025
-- Descrição: Exibe vendas agrupadas por produtos em quantidade e valores no mês de fevereiro de 2025
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

SELECT
    pf.produto_id,
    pf.descricao AS produto,
    SUM(v.qtde_vendida) AS quantidade_total_vendida,
    SUM(v.qtde_vendida * v.valor_unitario) AS valor_total_vendas
FROM public.venda v
INNER JOIN public.produtos_filial pf
    ON pf.filial_id = v.filial_id
   AND pf.produto_id = v.produto_id
WHERE v.data_emissao BETWEEN DATE '2025-02-01'
  AND DATE '2025-02-28'
GROUP BY
    pf.produto_id,
    pf.descricao
ORDER BY
    valor_total_vendas DESC,
    pf.descricao;