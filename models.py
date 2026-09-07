from sqlalchemy import create_engine, Column, Integer, String, Numeric, Date, Float, BigInteger
from sqlalchemy.orm import declarative_base

# Conectar ao banco

db = create_engine("postgresql+psycopg://postgres:123456@localhost:5432/desafio_systock")


Base = declarative_base()

# Criar as tabelas

class Venda(Base):
    __tablename__ = 'venda'

    venda_id = Column(
        'venda_id', 
        BigInteger, 
        nullable=False, 
        primary_key=True, 
        autoincrement=True
        )
    data_emissao = Column(
        'data_emissao', 
        Date, 
        nullable=False, 
        primary_key=True
        )
    horariomov = Column(
        'horariomov', 
        String(10), 
        default='00:00:00', 
        nullable=False, 
        primary_key=True
        )
    produto_id = Column(
        'produto_id', 
        String(25), 
        default='0', 
        nullable=False, 
        primary_key=True
        )
    qtde_vendida = Column(
        'qtde_vendida', 
        Float
        )
    valor_unitario = Column(
        'valor_unitario', 
        Numeric(12, 4), 
        default=0, 
        nullable=False
        )
    filial_id = Column(
        'filial_id', 
        BigInteger, 
        default=1, 
        nullable=False, 
        primary_key=True
        )
    item = Column(
        'item', 
        Integer, 
        default=0, 
        nullable=False, 
        primary_key=True
        )
    unidade_vendida = Column(
        'unidade_vendida', 
        String(3)
        )

class PedidoCompra(Base):
    __tablename__ = 'pedido_compra'

    pedido_id = Column(
        'pedido_id',
        Float,
        primary_key=True,
        autoincrement=True
        )
    data_pedido = Column(
        'data_pedido',
          Date
          )
    item = Column(
        'item', 
        Integer, 
        nullable=False, 
        primary_key=True
        )
    produto_id = Column(
        'produto_id', 
        String(25), 
        nullable=False,
        primary_key=True
        )
    descricao_produto = Column(
        'descricao_produto', 
        String(255)
        )
    ordem_compra = Column(
        'ordem_compra', 
        BigInteger, 
        nullable=False
        )
    qtde_pedida = Column(
        'qtde_pedida', 
        Float
        )
    filial_id = Column(
        'filial_id', 
        Integer
        )
    data_entrega = Column(
        'data_entrega', 
        Date
        )
    qtde_entregue = Column(
        'qtde_entregue', 
        Float, 
        default=0, 
        nullable=False
        )
    qtde_pendente = Column(
        'qtde_pendente', 
        Float, 
        default=0, 
        nullable=False
        )
    preco_compra = Column(
        'preco_compra', 
        Float
        )
    fornecedor_id = Column(
        'fornecedor_id', 
        Integer
        )

class EntradaMercadoria(Base):
    __tablename__ = 'entradas_mercadoria'

    data_entrada = Column(
        'data_entrada', 
        Date
        )
    nro_nfe = Column(
        'nro_nfe', 
        String(255), 
        nullable=False, 
        primary_key=True
        )
    item = Column(
        'item', 
        Integer, 
        default=0,
        nullable=False, 
        primary_key=True
        )
    produto_id = Column(
        'produto_id', 
        String(25), 
        default='0', 
        nullable=False, 
        primary_key=True
        )
    descricao_produto = Column(
        'descricao_produto', 
        String(255)
        )
    ordem_compra = Column(
        'ordem_compra', 
        BigInteger, 
        primary_key=True
        )
    qtde_recebida = Column(
        'qtde_recebida', 
        Float
        )
    filial_id = Column(
        'filial_id', 
        Integer
        )
    custo_unitario = Column(
        'custo_unitario', 
        Numeric(12, 4), 
        default=0, 
        nullable=False
        )

class ProdutoFilial(Base):
    __tablename__ = 'produtos_filial'

    filial_id = Column(
        'filial_id', 
        Integer, 
        primary_key=True
        )
    produto_id = Column(
        'produto_id', 
        String(255), 
        nullable=False, 
        primary_key=True
        )
    descricao = Column(
        'descricao', 
        String(255), 
        nullable=False
        )
    estoque = Column(
        'estoque', 
        Float, 
        default=0, 
        nullable=False
        )
    preco_unitario = Column(
        'preco_unitario', 
        Numeric(12, 4), 
        default=0, 
        nullable=False
        )
    preco_compra = Column(
        'preco_compra', 
        Numeric(12, 4), 
        default=0, 
        nullable=False)
    preco_venda = Column(
        'preco_venda', 
        Numeric(12, 4), 
        default=0, 
        nullable=False
        )
    fornecedor_id = Column(
        'fornecedor_id', 
        Integer
        )

class Fornecedor(Base):
    __tablename__ = 'fornecedor'

    fornecedor_id = Column(
        'fornecedor_id', 
        String(25), 
        nullable=False, 
        primary_key= True,
        autoincrement=True
        )
    razao_social = Column(
        'razao_social', 
        String(255), 
        nullable=False, 
        primary_key= True
        )


Base.metadata.create_all(db)