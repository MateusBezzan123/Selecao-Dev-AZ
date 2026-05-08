-- ------------------------------------------------------------
-- SEQUENCES
-- ------------------------------------------------------------

CREATE SEQUENCE seq_empresa
    INCREMENT 1 MINVALUE 1 MAXVALUE 9999999 START 1 CACHE 1;

CREATE SEQUENCE seq_leilao
    INCREMENT 1 MINVALUE 1 MAXVALUE 9999999 START 1 CACHE 1;

CREATE SEQUENCE seq_lote
    INCREMENT 1 MINVALUE 1 MAXVALUE 9999999 START 1 CACHE 1;

CREATE SEQUENCE seq_unidade
    INCREMENT 1 MINVALUE 1 MAXVALUE 9999999 START 1 CACHE 1;

-- ------------------------------------------------------------
-- TABELA: tb_unidade
-- ------------------------------------------------------------

CREATE TABLE tb_unidade
(
    id          INTEGER      NOT NULL DEFAULT NEXTVAL('seq_unidade'),
    nome        VARCHAR(128) NOT NULL,
    createdAt   TIMESTAMP    NOT NULL,
    updatedAt   TIMESTAMP    NOT NULL,

    CONSTRAINT unidade_pk PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- TABELA: tb_empresa
-- ------------------------------------------------------------

CREATE TABLE tb_empresa
(
    id           INTEGER      NOT NULL DEFAULT NEXTVAL('seq_empresa'),
    razaoSocial  VARCHAR(64)  NOT NULL,
    cnpj         VARCHAR(32)  NOT NULL,
    logradouro   VARCHAR(64),
    municipio    VARCHAR(64),
    numero       VARCHAR(10),
    complemento  VARCHAR(64),
    bairro       VARCHAR(64),
    cep          VARCHAR(16),
    telefone     VARCHAR(32),
    email        VARCHAR(254),
    site         VARCHAR(254),
    usuario      VARCHAR(20)  NOT NULL,
    senha        VARCHAR(128),
    createdAt    TIMESTAMP    NOT NULL,
    updatedAt    TIMESTAMP    NOT NULL,

    CONSTRAINT empresa_pk         PRIMARY KEY (id),
    CONSTRAINT empresa_cnpj_uk    UNIQUE (cnpj),
    CONSTRAINT empresa_usuario_uk UNIQUE (usuario)
);

-- ------------------------------------------------------------
-- TABELA: tb_leilao
-- ------------------------------------------------------------

CREATE TABLE tb_leilao
(
    id              INTEGER      NOT NULL DEFAULT NEXTVAL('seq_leilao'),
    codigo          INTEGER      NOT NULL,
    descricao       VARCHAR(60)  NOT NULL,
    vendedor        INTEGER      NOT NULL,
    inicioPrevisto  TIMESTAMP    NOT NULL,
    createdAt       TIMESTAMP    NOT NULL,
    updatedAt       TIMESTAMP    NOT NULL,

    CONSTRAINT leilao_pk PRIMARY KEY (id)
);

-- ------------------------------------------------------------
-- TABELA: tb_lote
-- ------------------------------------------------------------

CREATE TABLE tb_lote
(
    id           INTEGER      NOT NULL DEFAULT NEXTVAL('seq_lote'),
    numeroLote   INTEGER      NOT NULL,
    descricao    VARCHAR(60)  NOT NULL,
    quantidade   NUMERIC      NOT NULL,
    valorInicial NUMERIC      NOT NULL,
    unidade      VARCHAR(128) NOT NULL,
    leilao       INTEGER      NOT NULL,
    createdAt    TIMESTAMP    NOT NULL,
    updatedAt    TIMESTAMP    NOT NULL,

    CONSTRAINT lote_pk       PRIMARY KEY (id),
    CONSTRAINT leilao_lote_fk FOREIGN KEY (leilao) REFERENCES tb_leilao (id)
);

-- ------------------------------------------------------------
-- TABELA: tb_comprador
-- (chave primária composta: empresa + leilao)
-- ------------------------------------------------------------

CREATE TABLE tb_comprador
(
    empresa  INTEGER NOT NULL,
    leilao   INTEGER NOT NULL,

    CONSTRAINT comprador_pk      PRIMARY KEY (empresa, leilao),
    CONSTRAINT empresa_comp_fk   FOREIGN KEY (empresa) REFERENCES tb_empresa (id),
    CONSTRAINT leilao_comp_fk    FOREIGN KEY (leilao)  REFERENCES tb_leilao  (id)
);
