-- =====================================================================
--  005 — Modelo EAV de PELICULA
-- =====================================================================
--  Misma estructura que 004_eav_libro.sql. Ver ese fichero para el
--  razonamiento completo del patron.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_TIPO_DATO_PELICULA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_TIPO_DATO_PELICULA (
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

COMMENT ON TABLE CFG_TIPO_DATO_PELICULA IS
    'Define QUE datos puede tener una pelicula. Es el esquema del EAV de pelicula, y la fuente desde la que la API construye sus formularios.';

COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.codigo IS
    'Identificador estable del dato. Cuando el concepto existe tambien en libro o serie debe escribirse IGUAL en los tres catalogos (sinopsis, genero, idioma_original, titulo_original, clasificacion_edad).';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.tipo_dato IS
    'Determina en que columna valor_* de DAT_DATO_PELICULA se guarda el dato.';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.es_multiple IS
    'Si el dato admite varios valores por pelicula, diferenciados por posicion. Caso tipico: genero y pais_produccion, porque las coproducciones son la norma. Lo aplica la API.';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.obligatorio IS
    'Si el dato debe estar informado para dar la pelicula por completa. Regla de la API, no restriccion de integridad.';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.unidad IS
    'Unidad de medida para mostrar junto al valor: minutos, USD.';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.grupo IS
    'Agrupacion del dato en el formulario y en la ficha. Solo presentacion.';
COMMENT ON COLUMN CFG_TIPO_DATO_PELICULA.orden IS
    'Posicion del dato dentro de su grupo al pintar el formulario.';


-- ---------------------------------------------------------------------
--  CFG_OPCION_DATO_PELICULA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_OPCION_DATO_PELICULA (
    id                    serial       PRIMARY KEY,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_PELICULA(id) ON DELETE CASCADE,
    codigo                varchar(40)  NOT NULL,
    etiqueta              varchar(80)  NOT NULL,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_opcion_pelicula_codigo UNIQUE (tipo_dato_id, codigo)
);

COMMENT ON TABLE CFG_OPCION_DATO_PELICULA IS
    'Vocabulario cerrado de los datos de tipo OPCION de pelicula: generos, clasificacion por edades, color. Evita que el mismo concepto entre escrito de tres formas distintas y rompa los filtros.';
COMMENT ON COLUMN CFG_OPCION_DATO_PELICULA.codigo IS
    'Identificador estable de la opcion, usado por los filtros. Unico dentro de su dato.';
COMMENT ON COLUMN CFG_OPCION_DATO_PELICULA.etiqueta IS
    'Texto que ve el usuario. Puede cambiarse sin romper nada; el codigo no.';


-- ---------------------------------------------------------------------
--  DAT_DATO_PELICULA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_DATO_PELICULA (
    id                    bigserial    PRIMARY KEY,
    pelicula_id           bigint       NOT NULL REFERENCES DAT_PELICULA(obra_id) ON DELETE CASCADE,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_PELICULA(id),
    valor_texto           text,
    valor_entero          bigint,
    valor_decimal         numeric(14,2),
    valor_fecha           date,
    valor_bool            boolean,
    valor_opcion_id       int          REFERENCES CFG_OPCION_DATO_PELICULA(id),
    valor_idioma_id       int          REFERENCES CFG_IDIOMA(id),
    valor_pais_id         int          REFERENCES CFG_PAIS(id),
    posicion              smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_dato_pelicula_un_valor CHECK (
        num_nonnulls(valor_texto, valor_entero, valor_decimal, valor_fecha,
                     valor_bool, valor_opcion_id, valor_idioma_id, valor_pais_id) = 1
    ),

    CONSTRAINT uq_dato_pelicula UNIQUE (pelicula_id, tipo_dato_id, posicion)
);

COMMENT ON TABLE DAT_DATO_PELICULA IS
    'Valores concretos de los datos de cada pelicula: la V del EAV. Una fila por dato, o varias si el dato es multiple.';

COMMENT ON COLUMN DAT_DATO_PELICULA.pelicula_id IS
    'Pelicula a la que pertenece el valor. Apunta a DAT_PELICULA y no a DAT_OBRA para que sea imposible colgar un dato de pelicula de un libro.';
COMMENT ON COLUMN DAT_DATO_PELICULA.tipo_dato_id IS
    'Que dato es. Su tipo_dato indica cual de las columnas valor_* esta informada.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_texto IS
    'Valor para los datos TEXTO y TEXTO_LARGO.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_entero IS
    'Valor para los datos ENTERO, como la duracion en minutos. Tipado para que ordenar y filtrar por rango sea numerico.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_decimal IS
    'Valor para los datos DECIMAL: presupuesto y recaudacion.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_fecha IS
    'Valor para los datos FECHA, como la fecha de estreno.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_bool IS
    'Valor para los datos BOOL.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_opcion_id IS
    'Valor para los datos OPCION. Debe pertenecer al mismo tipo_dato_id de la fila; lo garantiza la API.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_idioma_id IS
    'Valor para los datos IDIOMA.';
COMMENT ON COLUMN DAT_DATO_PELICULA.valor_pais_id IS
    'Valor para los datos PAIS, como cada pais de una coproduccion.';
COMMENT ON COLUMN DAT_DATO_PELICULA.posicion IS
    'Orden del valor cuando el dato es multiple; 0 cuando es unico.';

CREATE INDEX idx_dato_pelicula_tipo
    ON DAT_DATO_PELICULA (tipo_dato_id, valor_opcion_id)
    WHERE valor_opcion_id IS NOT NULL;

CREATE INDEX idx_dato_pelicula_entero
    ON DAT_DATO_PELICULA (tipo_dato_id, valor_entero)
    WHERE valor_entero IS NOT NULL;

CREATE INDEX idx_dato_pelicula_pais
    ON DAT_DATO_PELICULA (valor_pais_id)
    WHERE valor_pais_id IS NOT NULL;
