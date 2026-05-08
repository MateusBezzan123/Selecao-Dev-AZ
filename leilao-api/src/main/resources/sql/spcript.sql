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

-- ============================================================
-- DML - Massa de Dados Inicial para Testes
-- ============================================================

-- ------------------------------------------------------------
-- tb_unidade (10 registros)
-- ------------------------------------------------------------

INSERT INTO tb_unidade (id, nome, createdAt, updatedAt) VALUES
                                                            (NEXTVAL('seq_unidade'), 'Unidade',        NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Caixa',          NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Kg',             NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Litro',          NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Metro',          NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Par',            NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Pacote',         NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Tonelada',       NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Metro Quadrado', NOW(), NOW()),
                                                            (NEXTVAL('seq_unidade'), 'Metro Cúbico',   NOW(), NOW());

-- ------------------------------------------------------------
-- tb_empresa (12 registros — vendedores + compradores)
-- ------------------------------------------------------------

INSERT INTO tb_empresa (id, razaoSocial, cnpj, logradouro, municipio, numero, complemento, bairro, cep, telefone, email, site, usuario, senha, createdAt, updatedAt) VALUES
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Leilões Brasil Ltda',         '11.111.111/0001-11', 'Rua das Flores',      'São Paulo',       '100', 'Sala 1',  'Centro',        '01310-100', '(11) 3000-1111', 'contato@leiloesbrasil.com.br',  'www.leiloesbrasil.com.br',  'leiloesbrasil',  'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Hasta Pública Goiás S.A.',    '22.222.222/0001-22', 'Av. Goiás',           'Goiânia',         '200', NULL,      'Setor Central', '74010-010', '(62) 3000-2222', 'contato@hastago.com.br',        'www.hastago.com.br',        'hastago',        'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Arremate Fácil Eireli',       '33.333.333/0001-33', 'Rua do Comércio',     'Belo Horizonte',  '300', 'Loja 2',  'Savassi',       '30130-110', '(31) 3000-3333', 'contato@arrematefacil.com.br',  'www.arrematefacil.com.br',  'arrematefacil',  'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'SuperLeilão Nordeste Ltda',   '44.444.444/0001-44', 'Av. Boa Viagem',      'Recife',          '400', 'Apto 10', 'Boa Viagem',    '51011-000', '(81) 3000-4444', 'contato@superleilao.com.br',    'www.superleilao.com.br',    'superleilao',    'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Tech Leilões ME',             '55.555.555/0001-55', 'Rua da Tecnologia',   'Curitiba',        '500', NULL,      'Batel',         '80420-090', '(41) 3000-5555', 'contato@techleiloes.com.br',    'www.techleiloes.com.br',    'techleiloes',    'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Comprador Alpha S.A.',        '66.666.666/0001-66', 'Rua Alpha',           'Porto Alegre',    '10',  NULL,      'Moinhos',       '90570-020', '(51) 3000-6666', 'contato@alpha.com.br',          'www.alpha.com.br',          'compradoralpha', 'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Indústria Beta Ltda',         '77.777.777/0001-77', 'Av. Industrial',      'Campinas',        '77',  'Galpão 3','Distrito Ind.', '13054-040', '(19) 3000-7777', 'contato@industriabeta.com.br',  'www.industriabeta.com.br',  'industriabeta',  'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Construtora Gamma Eireli',    '88.888.888/0001-88', 'Rua das Obras',       'Salvador',        '88',  NULL,      'Pituba',        '41810-001', '(71) 3000-8888', 'contato@gamma.com.br',          'www.gamma.com.br',          'consgamma',      'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Distribuidora Delta ME',      '99.999.999/0001-99', 'Rua Delta',           'Manaus',          '99',  'Sala 5',  'Adrianópolis',  '69057-040', '(92) 3000-9999', 'contato@delta.com.br',          'www.delta.com.br',          'distdelta',      'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Agro Epsilon Ltda',           '10.101.010/0001-10', 'Estrada Rural',       'Goianésia',       '101', NULL,      'Zona Rural',    '76380-000', '(62) 3001-0101', 'contato@agroepsilon.com.br',    'www.agroepsilon.com.br',    'agroepsilon',    'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Transportes Zeta S.A.',       '12.121.212/0001-12', 'Rodovia BR-153',      'Anápolis',        '0',   'KM 5',    'Distrito Ind.', '75132-020', '(62) 3001-1212', 'contato@zeta.com.br',           'www.zeta.com.br',           'transpzeta',     'senha123', NOW(), NOW()),
                                                                                                                                                                         (NEXTVAL('seq_empresa'), 'Comércio Eta ME',             '13.131.313/0001-13', 'Av. Brasil',          'Brasília',        '13',  NULL,      'Asa Norte',     '70040-010', '(61) 3001-1313', 'contato@eta.com.br',            'www.eta.com.br',            'comercioeta',    'senha123', NOW(), NOW());

-- ------------------------------------------------------------
-- tb_leilao (10 registros)
-- vendedor referencia ids de tb_empresa (1 a 5 = vendedores)
-- ------------------------------------------------------------

INSERT INTO tb_leilao (id, codigo, descricao, vendedor, inicioPrevisto, createdAt, updatedAt) VALUES
                                                                                                  (NEXTVAL('seq_leilao'), 1001, 'Leilão de Equipamentos Industriais',    1, '2025-06-10 09:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1002, 'Leilão de Veículos e Máquinas Agrícolas', 2, '2025-06-15 10:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1003, 'Leilão de Materiais de Construção',     3, '2025-06-20 08:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1004, 'Leilão de Eletrônicos e Informática',   4, '2025-07-01 14:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1005, 'Leilão de Imóveis Rurais',              5, '2025-07-05 09:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1006, 'Leilão de Sucata Metálica',             1, '2025-07-10 08:30:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1007, 'Leilão de Produtos Alimentícios',       2, '2025-07-15 10:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1008, 'Leilão de Ferramentas e Utensílios',    3, '2025-07-20 09:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1009, 'Leilão de Combustíveis e Lubrificantes',4, '2025-08-01 13:00:00', NOW(), NOW()),
                                                                                                  (NEXTVAL('seq_leilao'), 1010, 'Leilão de Animais de Grande Porte',     5, '2025-08-10 07:00:00', NOW(), NOW());

-- ------------------------------------------------------------
-- tb_lote (10 registros — distribuídos entre os leilões)
-- ------------------------------------------------------------

INSERT INTO tb_lote (id, numeroLote, descricao, quantidade, valorInicial, unidade, leilao, createdAt, updatedAt) VALUES
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Torno Mecânico CNC 2020',          1,      15000.00, 'Unidade',  1, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 2, 'Compressor de Ar Industrial 10HP', 2,       4500.00, 'Unidade',  1, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Trator New Holland TL75E',         1,      85000.00, 'Unidade',  2, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 2, 'Colheitadeira John Deere S560',    1,     320000.00, 'Unidade',  2, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Cimento CP II (pallets)',          500,       650.00, 'Tonelada', 3, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 2, 'Vergalhão CA-50 (bobinas)',        10000,    4800.00, 'Kg',       3, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Notebook Dell Latitude 5420',      20,       2800.00, 'Unidade',  4, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 2, 'Switch Cisco Catalyst 24 portas',  5,        1200.00, 'Unidade',  4, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Área Rural 50 Alqueires Goiás',    1,    1500000.00, 'Unidade',  5, NOW(), NOW()),
                                                                                                                     (NEXTVAL('seq_lote'), 1, 'Sucata de Aço Carbono',            5000,      850.00, 'Tonelada', 6, NOW(), NOW());

-- ------------------------------------------------------------
-- tb_comprador (10 registros — empresa x leilao)
-- empresas 6 a 12 como compradores
-- ------------------------------------------------------------

INSERT INTO tb_comprador (empresa, leilao) VALUES
                                               (6,  1),
                                               (7,  1),
                                               (8,  2),
                                               (9,  2),
                                               (10, 3),
                                               (11, 3),
                                               (12, 4),
                                               (6,  5),
                                               (7,  6),
                                               (8,  7);
