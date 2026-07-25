-- =====================================================================
--  004 — Modelo EAV de LIBRO
-- =====================================================================
--  Tres tablas que se repiten identicas para cada tipo de obra:
--
--    CFG_TIPO_DATO_LIBRO   la A de EAV: que datos puede tener un libro
--    CFG_OPCION_DATO_LIBRO vocabulario cerrado de los datos tipo OPCION
--    DAT_DATO_LIBRO        la V de EAV: los valores concretos
--
--  La E de EAV es DAT_LIBRO, creada en 003.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_TIPO_DATO_LIBRO
-- ---------------------------------------------------------------------
CREATE TABLE CFG_TIPO_DATO_LIBRO (
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

COMMENT ON TABLE CFG_TIPO_DATO_LIBRO IS
    'Define QUE datos puede tener un libro. Es el esquema del EAV: sin esta tabla cualquiera podria inventarse atributos. La API construye los formularios de alta y edicion leyendo de aqui, en vez de tenerlos escritos en el codigo.';

COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.codigo IS
    'Identificador estable del dato, usado por la API y el frontend. Cuando el concepto existe tambien en pelicula o serie debe escribirse IGUAL en los tres catalogos (sinopsis, genero, idioma_original...) para poder tratarlos de forma uniforme y evitar un switch por tipo de obra en cada componente.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.tipo_dato IS
    'Determina en que columna valor_* de DAT_DATO_LIBRO se guarda el dato. La API valida contra este campo antes de escribir.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.es_multiple IS
    'Si es true el libro puede tener varios valores de este dato, diferenciados por la columna posicion (caso de genero). Si es false solo puede tener uno. Esta restriccion la aplica la API: la base de datos no puede comprobarla con un indice unico porque la condicion vive en esta tabla, no en la de valores.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.obligatorio IS
    'Si el dato debe estar informado para dar el libro por completo. Es una regla de validacion de la API, no una restriccion de integridad: en un EAV no se puede forzar NOT NULL sobre una fila que aun no existe.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.unidad IS
    'Unidad de medida para mostrar junto al valor: paginas, minutos, USD. Solo presentacion.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.grupo IS
    'Agrupacion del dato en el formulario y en la ficha (por ejemplo Publicacion o Clasificacion). Solo presentacion.';
COMMENT ON COLUMN CFG_TIPO_DATO_LIBRO.orden IS
    'Posicion del dato dentro de su grupo al pintar el formulario.';


-- ---------------------------------------------------------------------
--  CFG_OPCION_DATO_LIBRO
-- ---------------------------------------------------------------------
CREATE TABLE CFG_OPCION_DATO_LIBRO (
    id                    serial       PRIMARY KEY,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_LIBRO(id) ON DELETE CASCADE,
    codigo                varchar(40)  NOT NULL,
    etiqueta              varchar(80)  NOT NULL,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_opcion_libro_codigo UNIQUE (tipo_dato_id, codigo)
);

COMMENT ON TABLE CFG_OPCION_DATO_LIBRO IS
    'Vocabulario cerrado de los datos de tipo OPCION: generos, tipo narrativo, publico objetivo. Sin esta tabla se acumularian "Ciencia ficcion", "ciencia-ficcion" y "Sci-Fi" como tres generos distintos, y filtrar por genero dejaria de funcionar. Va por tipo de obra porque su FK apunta a CFG_TIPO_DATO_LIBRO, que ya es una tabla por tipo.';
COMMENT ON COLUMN CFG_OPCION_DATO_LIBRO.codigo IS
    'Identificador estable de la opcion, usado por los filtros de la API. Unico dentro de su dato.';
COMMENT ON COLUMN CFG_OPCION_DATO_LIBRO.etiqueta IS
    'Texto que ve el usuario. Puede cambiarse sin romper nada; el codigo no.';


-- ---------------------------------------------------------------------
--  DAT_DATO_LIBRO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_DATO_LIBRO (
    id                    bigserial    PRIMARY KEY,
    libro_id              bigint       NOT NULL REFERENCES DAT_LIBRO(obra_id) ON DELETE CASCADE,
    tipo_dato_id          int          NOT NULL REFERENCES CFG_TIPO_DATO_LIBRO(id),
    valor_texto           text,
    valor_entero          bigint,
    valor_decimal         numeric(14,2),
    valor_fecha           date,
    valor_bool            boolean,
    valor_opcion_id       int          REFERENCES CFG_OPCION_DATO_LIBRO(id),
    valor_idioma_id       int          REFERENCES CFG_IDIOMA(id),
    valor_pais_id         int          REFERENCES CFG_PAIS(id),
    posicion              smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    -- Exactamente una columna de valor informada. Es la restriccion que
    -- impide que una fila diga a la vez «Dune» y 412.
    CONSTRAINT ck_dato_libro_un_valor CHECK (
        num_nonnulls(valor_texto, valor_entero, valor_decimal, valor_fecha,
                     valor_bool, valor_opcion_id, valor_idioma_id, valor_pais_id) = 1
    ),

    -- Evita duplicados exactos y, de paso, ordena los valores multiples.
    CONSTRAINT uq_dato_libro UNIQUE (libro_id, tipo_dato_id, posicion)
);

COMMENT ON TABLE DAT_DATO_LIBRO IS
    'Valores concretos de los datos de cada libro: la V del EAV. Una fila por dato, o varias si el dato es multiple. Es la tabla de mayor volumen del esquema.';

COMMENT ON COLUMN DAT_DATO_LIBRO.libro_id IS
    'Libro al que pertenece el valor. Apunta a DAT_LIBRO y no a DAT_OBRA: asi es imposible colgar un dato de libro de una pelicula.';
COMMENT ON COLUMN DAT_DATO_LIBRO.tipo_dato_id IS
    'Que dato es. Su tipo_dato indica cual de las columnas valor_* esta informada.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_texto IS
    'Valor para los datos TEXTO y TEXTO_LARGO.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_entero IS
    'Valor para los datos ENTERO. Se guarda tipado, y no como texto, para que los filtros por rango y las ordenaciones sean numericos: en texto, 9 iria despues de 120.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_decimal IS
    'Valor para los datos DECIMAL, con dos decimales. Pensado para importes.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_fecha IS
    'Valor para los datos FECHA.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_bool IS
    'Valor para los datos BOOL.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_opcion_id IS
    'Valor para los datos OPCION. Debe pertenecer al mismo tipo_dato_id de la fila; esa coherencia la garantiza la API, no la base de datos.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_idioma_id IS
    'Valor para los datos IDIOMA.';
COMMENT ON COLUMN DAT_DATO_LIBRO.valor_pais_id IS
    'Valor para los datos PAIS.';
COMMENT ON COLUMN DAT_DATO_LIBRO.posicion IS
    'Orden del valor cuando el dato es multiple; 0 cuando es unico. Forma parte de la clave unica, de modo que dos valores del mismo dato deben tener posiciones distintas.';

-- Acceso principal: todos los datos de un libro para pintar su ficha.
CREATE INDEX idx_dato_libro_tipo
    ON DAT_DATO_LIBRO (tipo_dato_id, valor_opcion_id)
    WHERE valor_opcion_id IS NOT NULL;

-- Filtros por rango numerico (paginas, ano).
CREATE INDEX idx_dato_libro_entero
    ON DAT_DATO_LIBRO (tipo_dato_id, valor_entero)
    WHERE valor_entero IS NOT NULL;

-- Los indices anteriores son PARCIALES: solo indexan las filas que
-- realmente tienen ese tipo de valor. En un EAV, donde la inmensa
-- mayoria de las columnas van a NULL, esto es lo que evita que los
-- indices crezcan al tamano de la tabla.
