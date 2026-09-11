-- =============================================================
-- Nome: valida_estoque_negativo
-- Descrição: Exibe estoque com valores negativos
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

SELECT
    filial_id,
    produto_id,
    descricao,
    estoque,
    preco_unitario,
    preco_compra,
    preco_venda
FROM public.produtos_filial
WHERE estoque < 0
   OR preco_unitario < 0
   OR preco_compra < 0
   OR preco_venda < 0
ORDER BY
    filial_id,
    produto_id;