-- =====================================================================
--  006 — Modelo EAV de SERIE
-- =====================================================================
--  Misma estructura que 004_eav_libro.sql. Ver ese fichero para el
--  razonamiento completo del patron.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_TIPO_DATO_SERIE
-- ---------------------------------------------------------------------
CREATE TABLE CFG_TIPO_DATO_SERIE (
    id                    serial       PRIMARY KEY,
    codigo                varchar(40)  NOT NULL UNIQUE,
    nombre                varchar(80)  NOT NULL,
    tipo_dato             tipo_dato_enum NOT NULL,
    es_multiple           boolean      NOT NULL DEFAULT false,
    obligatorio           boolean      NOT NULL DEFAULT false,
    unidad                varchar(20),
    grupo                 varchar(40),
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_TIPO_DATO_SERIE IS
    'Define QUE datos puede tener una serie. No incluye numero de temporadas ni de episodios: son datos DERIVADOS que se calculan con COUNT sobre DAT_TEMPORADA y DAT_EPISODIO. Almacenarlos garantizaria que algun dia se desincronicen.';

COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.codigo IS
    'Identificador estable del dato. Cuando el concepto existe tambien en libro o pelicula debe escribirse IGUAL en los tres catalogos.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.tipo_dato IS
    'Determina en que columna valor_* de DAT_DATO_SERIE se guarda el dato.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.es_multiple IS
    'Si el dato admite varios valores por serie, diferenciados por posicion. Caso tipico: genero y pais_produccion.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.obligatorio IS
    'Si el dato debe estar informado para dar la serie por completa. Regla de la API, no restriccion de integridad.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.unidad IS
    'Unidad de medida para mostrar junto al valor: minutos.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.grupo IS
    'Agrupacion del dato en el formulario y en la ficha. Solo presentacion.';
COMMENT ON COLUMN CFG_TIPO_DATO_SERIE.orden IS
    'Posicion del dato dentro de su grupo al pintar el formulario.';


-- ---------------------------------------------------------------------
--  CFG_OPCION_DATO_SERIE
-- ---------------------------------------------------------------------
CREATE TABLE CFG_OPCION_DATO_SERIE (
    id                    serial       PRIMARY KEY,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_SERIE(id) ON DELETE CASCADE,
    codigo                varchar(40)  NOT NULL,
    etiqueta              varchar(80)  NOT NULL,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_opcion_serie_codigo UNIQUE (tipo_dato_id, codigo)
);

COMMENT ON TABLE CFG_OPCION_DATO_SERIE IS
    'Vocabulario cerrado de los datos de tipo OPCION de serie: generos, estado de emision, tipo de serie, clasificacion por edades.';
COMMENT ON COLUMN CFG_OPCION_DATO_SERIE.codigo IS
    'Identificador estable de la opcion. El dato estado (EN_EMISION, FINALIZADA, CANCELADA, EN_PAUSA) es el que permite avisar de episodios nuevos, asi que sus codigos no deben cambiarse.';
COMMENT ON COLUMN CFG_OPCION_DATO_SERIE.etiqueta IS
    'Texto que ve el usuario. Puede cambiarse sin romper nada; el codigo no.';


-- ---------------------------------------------------------------------
--  DAT_DATO_SERIE
-- ---------------------------------------------------------------------
CREATE TABLE DAT_DATO_SERIE (
    id                    bigserial    PRIMARY KEY,
    serie_id              bigint       NOT NULL REFERENCES DAT_SERIE(obra_id) ON DELETE CASCADE,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_SERIE(id),
    valor_texto           text,
    valor_entero          bigint,
    valor_decimal         numeric(14,2),
    valor_fecha           date,
    valor_bool            boolean,
    valor_opcion_id       int          REFERENCES CFG_OPCION_DATO_SERIE(id),
    valor_idioma_id       int          REFERENCES CFG_IDIOMA(id),
    valor_pais_id         int          REFERENCES CFG_PAIS(id),
    posicion              smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_dato_serie_un_valor CHECK (
        num_nonnulls(valor_texto, valor_entero, valor_decimal, valor_fecha,
                     valor_bool, valor_opcion_id, valor_idioma_id, valor_pais_id) = 1
    ),

    CONSTRAINT uq_dato_serie UNIQUE (serie_id, tipo_dato_id, posicion)
);

COMMENT ON TABLE DAT_DATO_SERIE IS
    'Valores concretos de los datos de cada serie: la V del EAV.';

COMMENT ON COLUMN DAT_DATO_SERIE.serie_id IS
    'Serie a la que pertenece el valor. Apunta a DAT_SERIE, no a DAT_OBRA.';
COMMENT ON COLUMN DAT_DATO_SERIE.tipo_dato_id IS
    'Que dato es. Su tipo_dato indica cual de las columnas valor_* esta informada.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_texto IS
    'Valor para los datos TEXTO y TEXTO_LARGO.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_entero IS
    'Valor para los datos ENTERO, como la duracion media de episodio en minutos.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_decimal IS
    'Valor para los datos DECIMAL.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_fecha IS
    'Valor para los datos FECHA: inicio y fin de emision. La fecha de fin queda sin fila mientras la serie siga en emision.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_bool IS
    'Valor para los datos BOOL.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_opcion_id IS
    'Valor para los datos OPCION. Debe pertenecer al mismo tipo_dato_id de la fila; lo garantiza la API.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_idioma_id IS
    'Valor para los datos IDIOMA.';
COMMENT ON COLUMN DAT_DATO_SERIE.valor_pais_id IS
    'Valor para los datos PAIS.';
COMMENT ON COLUMN DAT_DATO_SERIE.posicion IS
    'Orden del valor cuando el dato es multiple; 0 cuando es unico.';

CREATE INDEX idx_dato_serie_tipo
    ON DAT_DATO_SERIE (tipo_dato_id, valor_opcion_id)
    WHERE valor_opcion_id IS NOT NULL;

CREATE INDEX idx_dato_serie_entero
    ON DAT_DATO_SERIE (tipo_dato_id, valor_entero)
    WHERE valor_entero IS NOT NULL;
