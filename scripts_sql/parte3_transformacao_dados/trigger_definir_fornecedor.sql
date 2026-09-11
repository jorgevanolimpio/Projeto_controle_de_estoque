-- =============================================================
-- Nome: trigger_definir_fornecedor
-- Descrição: Alterar tabelas produtos_filial e fornecedor, relacionar as tabelas
--			  (chave estrangeira), criar função e TRIGGER para inserir novo fornecedor
--			  ou localizar existente.
-- Usado por: 
-- Criado em: 10/09/2026
-- Autor: Jorgevan Olimpio
-- =============================================================

-- 1. Campo usado para informar o fornecedor ao incluir ou alterar um produto.
ALTER TABLE public.produtos_filial
    ADD COLUMN razao_social_fornecedor varchar;
 
-- 2. fornecedor_id precisa ser único isoladamente para ser referenciado
--    por uma chave estrangeira.
ALTER TABLE public.fornecedor
    ADD CONSTRAINT fornecedor_fornecedor_id_uk
    UNIQUE (fornecedor_id);
 
-- 3. Garante que todo fornecedor associado ao produto exista na tabela fornecedor.
ALTER TABLE public.produtos_filial
    ADD CONSTRAINT produtos_filial_fornecedor_fk
    FOREIGN KEY (fornecedor_id)
    REFERENCES public.fornecedor (fornecedor_id);


-- 4.Função e Trigger que cria e localiza o fornecedor antes de gravar o produto:
CREATE OR REPLACE FUNCTION public.fn_definir_fornecedor_produto()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Se o identificador já foi informado, a chave estrangeira valida sua existência.
    IF NEW.fornecedor_id IS NOT NULL THEN
        RETURN NEW;
    END IF;
 
    -- Sem ID, a razão social é necessária para localizar ou cadastrar o fornecedor.
    IF NULLIF(BTRIM(NEW.razao_social_fornecedor), '') IS NULL THEN
        RAISE EXCEPTION
            'Informe fornecedor_id ou razao_social_fornecedor para o produto % da filial %.',
            NEW.produto_id,
            NEW.filial_id;
    END IF;
 
    -- Insere o fornecedor caso não exista. Caso exista, retorna o ID já cadastrado.
    INSERT INTO public.fornecedor (razao_social)
    VALUES (BTRIM(NEW.razao_social_fornecedor))
    ON CONFLICT (razao_social)
    DO UPDATE SET razao_social = EXCLUDED.razao_social
    RETURNING fornecedor_id
    INTO NEW.fornecedor_id;
 
    RETURN NEW;
END;
$$;
 
CREATE TRIGGER trg_definir_fornecedor_produto
BEFORE INSERT OR UPDATE OF fornecedor_id, razao_social_fornecedor
ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION public.fn_definir_fornecedor_produto();