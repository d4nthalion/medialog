-- =====================================================================
--  007 — Modelo EAV de EPISODIO
-- =====================================================================
--  El catalogo mas pequeno de los cuatro: sinopsis, duracion, fecha de
--  emision y numero absoluto. Se monta igual que los demas por si crece.
--
--  DAT_TEMPORADA NO tiene EAV: sus campos son fijos y no varian.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_TIPO_DATO_EPISODIO
-- ---------------------------------------------------------------------
CREATE TABLE CFG_TIPO_DATO_EPISODIO (
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

COMMENT ON TABLE CFG_TIPO_DATO_EPISODIO IS
    'Define QUE datos puede tener un episodio. El titulo y el numero de episodio NO estan aqui: viven en DAT_OBRA y DAT_EPISODIO respectivamente, porque se leen en cada fila de la lista de episodios.';

COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.codigo IS
    'Identificador estable del dato, coherente con los otros catalogos cuando el concepto se repite.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.tipo_dato IS
    'Determina en que columna valor_* de DAT_DATO_EPISODIO se guarda el dato.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.es_multiple IS
    'Si el dato admite varios valores por episodio, diferenciados por posicion.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.obligatorio IS
    'Si el dato debe estar informado. Regla de la API, no restriccion de integridad.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.unidad IS
    'Unidad de medida para mostrar junto al valor: minutos.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.grupo IS
    'Agrupacion del dato en el formulario. Solo presentacion.';
COMMENT ON COLUMN CFG_TIPO_DATO_EPISODIO.orden IS
    'Posicion del dato dentro de su grupo al pintar el formulario.';


-- ---------------------------------------------------------------------
--  CFG_OPCION_DATO_EPISODIO
-- ---------------------------------------------------------------------
CREATE TABLE CFG_OPCION_DATO_EPISODIO (
    id                    serial       PRIMARY KEY,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_EPISODIO(id) ON DELETE CASCADE,
    codigo                varchar(40)  NOT NULL,
    etiqueta              varchar(80)  NOT NULL,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_opcion_episodio_codigo UNIQUE (tipo_dato_id, codigo)
);

COMMENT ON TABLE CFG_OPCION_DATO_EPISODIO IS
    'Vocabulario cerrado de los datos de tipo OPCION de episodio. Hoy va vacia: ningun dato de episodio es de tipo OPCION todavia. Se crea igualmente para que el patron sea identico en los cuatro tipos y anadir un dato de opcion no requiera migracion de estructura.';
COMMENT ON COLUMN CFG_OPCION_DATO_EPISODIO.codigo IS
    'Identificador estable de la opcion. Unico dentro de su dato.';
COMMENT ON COLUMN CFG_OPCION_DATO_EPISODIO.etiqueta IS
    'Texto que ve el usuario.';


-- ---------------------------------------------------------------------
--  DAT_DATO_EPISODIO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_DATO_EPISODIO (
    id                    bigserial    PRIMARY KEY,
    episodio_id           bigint       NOT NULL REFERENCES DAT_EPISODIO(obra_id) ON DELETE CASCADE,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_EPISODIO(id),
    valor_texto           text,
    valor_entero          bigint,
    valor_decimal         numeric(14,2),
    valor_fecha           date,
    valor_bool            boolean,
    valor_opcion_id       int          REFERENCES CFG_OPCION_DATO_EPISODIO(id),
    valor_idioma_id       int          REFERENCES CFG_IDIOMA(id),
    valor_pais_id         int          REFERENCES CFG_PAIS(id),
    posicion              smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_dato_episodio_un_valor CHECK (
        num_nonnulls(valor_texto, valor_entero, valor_decimal, valor_fecha,
                     valor_bool, valor_opcion_id, valor_idioma_id, valor_pais_id) = 1
    ),

    CONSTRAINT uq_dato_episodio UNIQUE (episodio_id, tipo_dato_id, posicion)
);

COMMENT ON TABLE DAT_DATO_EPISODIO IS
    'Valores concretos de los datos de cada episodio. Es la tabla que mas crece del esquema: una serie larga son cientos de episodios, y cada uno varias filas aqui.';

COMMENT ON COLUMN DAT_DATO_EPISODIO.episodio_id IS
    'Episodio al que pertenece el valor.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.tipo_dato_id IS
    'Que dato es. Su tipo_dato indica cual de las columnas valor_* esta informada.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_texto IS
    'Valor para los datos TEXTO y TEXTO_LARGO.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_entero IS
    'Valor para los datos ENTERO: duracion en minutos, numero absoluto.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_decimal IS
    'Valor para los datos DECIMAL.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_fecha IS
    'Valor para los datos FECHA, como la fecha de emision.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_bool IS
    'Valor para los datos BOOL.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_opcion_id IS
    'Valor para los datos OPCION.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_idioma_id IS
    'Valor para los datos IDIOMA.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.valor_pais_id IS
    'Valor para los datos PAIS.';
COMMENT ON COLUMN DAT_DATO_EPISODIO.posicion IS
    'Orden del valor cuando el dato es multiple; 0 cuando es unico.';

CREATE INDEX idx_dato_episodio_fecha
    ON DAT_DATO_EPISODIO (tipo_dato_id, valor_fecha)
    WHERE valor_fecha IS NOT NULL;
