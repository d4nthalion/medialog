-- =====================================================================
--  003 — Nucleo: supertipo DAT_OBRA y sus subtipos
-- =====================================================================
--  Patron: class table inheritance.
--
--  DAT_OBRA guarda lo comun a cualquier obra. DAT_LIBRO, DAT_PELICULA,
--  DAT_SERIE, DAT_TEMPORADA y DAT_EPISODIO COMPARTEN SU CLAVE PRIMARIA
--  con ella (obra_id es a la vez PK y FK).
--
--  Esto es lo que permite que una review, un rating o un elemento de
--  lista tengan una unica FK con integridad real hacia "cualquier obra".
--  Sin este supertipo harian falta dos columnas (tipo_obra + id) sin FK
--  posible, que es el agujero clasico por el que entran las referencias
--  huerfanas.
-- =====================================================================

-- ---------------------------------------------------------------------
--  DAT_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_OBRA (
    id                    bigserial    PRIMARY KEY,
    tipo_obra_id          int          NOT NULL REFERENCES CFG_TIPO_OBRA(id),
    titulo                text         NOT NULL,
    titulo_normalizado    text         GENERATED ALWAYS AS (fn_normalizar(titulo)) STORED,
    anio                  smallint,
    portada_url           text,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_obra_anio CHECK (anio IS NULL OR anio BETWEEN 1000 AND 2200)
);

COMMENT ON TABLE DAT_OBRA IS
    'Supertipo de toda obra catalogable: libro, pelicula, serie, temporada o episodio. Es el unico destino valido de una FK cuando algo se refiere a "una obra cualquiera" (reviews, ratings, listas, ids externos, personas, colecciones). Los datos especificos de cada tipo viven en su tabla DAT_DATO_* correspondiente.';

COMMENT ON COLUMN DAT_OBRA.tipo_obra_id IS
    'Discriminador del subtipo. Indica en cual de las tablas DAT_LIBRO / DAT_PELICULA / DAT_SERIE / DAT_TEMPORADA / DAT_EPISODIO esta el detalle de esta fila.';
COMMENT ON COLUMN DAT_OBRA.titulo IS
    'Titulo canonico, en el idioma principal del catalogo. Esta desnormalizado fuera del EAV a proposito: se lee en todas las pantallas, y hacer un join contra DAT_DATO_* por cada tarjeta de una parrilla es exactamente como se degradan los modelos EAV.';
COMMENT ON COLUMN DAT_OBRA.titulo_normalizado IS
    'Columna GENERADA a partir de titulo: minusculas y sin acentos. Soporta el indice trigram de busqueda difusa. No se escribe nunca a mano.';
COMMENT ON COLUMN DAT_OBRA.anio IS
    'Ano de referencia: publicacion del libro, estreno de la pelicula, inicio de emision de la serie. Se guarda aparte del EAV porque casi todos los listados ordenan o filtran por el.';
COMMENT ON COLUMN DAT_OBRA.portada_url IS
    'URL de la imagen de portada o poster. Se guarda la URL, no el binario.';

-- Busqueda difusa: permite que «interestelar» encuentre «Interstellar».
CREATE INDEX idx_obra_titulo_trgm
    ON DAT_OBRA USING gin (titulo_normalizado gin_trgm_ops);

-- Listados y filtros por tipo y ano, que son la navegacion por defecto.
CREATE INDEX idx_obra_tipo_anio
    ON DAT_OBRA (tipo_obra_id, anio DESC);


-- ---------------------------------------------------------------------
--  DAT_LIBRO / DAT_PELICULA / DAT_SERIE
-- ---------------------------------------------------------------------
--  Estas tablas apenas tienen columnas propias, y es correcto: todo su
--  contenido variable esta en su EAV. Existen para dos cosas concretas:
--    1. dar un destino de FK con tipo real a DAT_DATO_*, de modo que sea
--       imposible colgar un dato de libro de una pelicula;
--    2. materializar la pertenencia al subtipo.
-- ---------------------------------------------------------------------

CREATE TABLE DAT_LIBRO (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_LIBRO IS
    'Subtipo libro. Sin columnas propias: sus datos estan en DAT_DATO_LIBRO. Existe para que las FK de DAT_DATO_LIBRO tengan un destino tipado y no se puedan colgar datos de libro de una pelicula.';
COMMENT ON COLUMN DAT_LIBRO.obra_id IS
    'PK y FK a la vez hacia DAT_OBRA. No hay id propio: el libro y su obra son la misma entidad.';


CREATE TABLE DAT_PELICULA (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_PELICULA IS
    'Subtipo pelicula. Sin columnas propias: sus datos estan en DAT_DATO_PELICULA.';
COMMENT ON COLUMN DAT_PELICULA.obra_id IS
    'PK y FK a la vez hacia DAT_OBRA.';


CREATE TABLE DAT_SERIE (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_SERIE IS
    'Subtipo serie. Sin columnas propias: sus datos estan en DAT_DATO_SERIE. El numero de temporadas y de episodios NO se guarda aqui, se calcula con COUNT sobre DAT_TEMPORADA y DAT_EPISODIO.';
COMMENT ON COLUMN DAT_SERIE.obra_id IS
    'PK y FK a la vez hacia DAT_OBRA.';


-- ---------------------------------------------------------------------
--  DAT_TEMPORADA
-- ---------------------------------------------------------------------
--  Sin EAV a proposito: sus campos son fijos y no varian entre series.
-- ---------------------------------------------------------------------
CREATE TABLE DAT_TEMPORADA (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    serie_id              bigint       NOT NULL REFERENCES DAT_SERIE(obra_id) ON DELETE CASCADE,
    numero                smallint     NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_temporada_serie_numero UNIQUE (serie_id, numero),
    CONSTRAINT ck_temporada_numero CHECK (numero >= 0)
);

COMMENT ON TABLE DAT_TEMPORADA IS
    'Temporada de una serie. Es tambien una fila de DAT_OBRA, de modo que se puede puntuar y resenar por separado sin ningun mecanismo adicional. No tiene EAV porque sus campos son fijos.';
COMMENT ON COLUMN DAT_TEMPORADA.serie_id IS
    'Serie a la que pertenece. Apunta a DAT_SERIE y no a DAT_OBRA para que sea imposible colgar una temporada de un libro.';
COMMENT ON COLUMN DAT_TEMPORADA.numero IS
    'Numero de temporada dentro de la serie. Se admite 0 para las temporadas de especiales, que es como las numera TMDB.';


-- ---------------------------------------------------------------------
--  DAT_EPISODIO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_EPISODIO (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    temporada_id          bigint       NOT NULL REFERENCES DAT_TEMPORADA(obra_id) ON DELETE CASCADE,
    numero                smallint     NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_episodio_temporada_numero UNIQUE (temporada_id, numero),
    CONSTRAINT ck_episodio_numero CHECK (numero > 0)
);

COMMENT ON TABLE DAT_EPISODIO IS
    'Episodio de una temporada. Es tambien una fila de DAT_OBRA, lo que permite marcarlo como visto y puntuarlo individualmente.';
COMMENT ON COLUMN DAT_EPISODIO.temporada_id IS
    'Temporada a la que pertenece. La serie se obtiene navegando a DAT_TEMPORADA; no se duplica aqui para no tener dos verdades.';
COMMENT ON COLUMN DAT_EPISODIO.numero IS
    'Numero de episodio dentro de su temporada. La numeracion continua a lo largo de toda la serie, si se necesita, va en el dato EAV numero_absoluto.';
