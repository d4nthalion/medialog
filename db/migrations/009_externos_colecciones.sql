-- =====================================================================
--  009 — Identificadores externos y colecciones
-- =====================================================================

-- ---------------------------------------------------------------------
--  DAT_ID_EXTERNO_OBRA
-- ---------------------------------------------------------------------
--  Podria modelarse como un dato EAV mas, pero se necesita una clave
--  UNICA sobre (fuente, id_externo), y en un EAV eso no es posible: el
--  indice unico habria que ponerlo sobre una columna de valor generica
--  compartida con el resto de datos.
-- ---------------------------------------------------------------------
CREATE TABLE DAT_ID_EXTERNO_OBRA (
    id                    bigserial    PRIMARY KEY,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    fuente_id             int          NOT NULL REFERENCES CFG_FUENTE_EXTERNA(id),
    id_externo            varchar(60)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_id_externo UNIQUE (fuente_id, id_externo)
);

COMMENT ON TABLE DAT_ID_EXTERNO_OBRA IS
    'Correspondencia entre una obra del catalogo y su ficha en una fuente externa (TMDB, IMDB, OpenLibrary, ISBN). Su clave unica es lo que impide que un reimport duplique obras: antes de dar de alta, el importador busca aqui.';

COMMENT ON COLUMN DAT_ID_EXTERNO_OBRA.obra_id IS
    'Obra del catalogo. Una misma obra puede tener varios identificadores, uno por fuente.';
COMMENT ON COLUMN DAT_ID_EXTERNO_OBRA.id_externo IS
    'Identificador tal cual lo devuelve la fuente. Se guarda como texto y no como numero porque no todas las fuentes usan claves numericas: los ISBN pueden acabar en X y los codigos de IMDB empiezan por tt.';

CREATE INDEX idx_id_externo_obra
    ON DAT_ID_EXTERNO_OBRA (obra_id);


-- ---------------------------------------------------------------------
--  DAT_COLECCION
-- ---------------------------------------------------------------------
CREATE TABLE DAT_COLECCION (
    id                    bigserial    PRIMARY KEY,
    nombre                text         NOT NULL,
    descripcion           text,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_COLECCION IS
    'Agrupacion editorial de obras: sagas, trilogias, universos compartidos. Es del CATALOGO, no del usuario: no confundir con las listas que crea cada persona, que iran en el dominio social. Puede mezclar tipos, de modo que El Senor de los Anillos agrupe los libros y las peliculas en una sola coleccion.';

COMMENT ON COLUMN DAT_COLECCION.nombre IS
    'Nombre de la saga o coleccion.';


-- ---------------------------------------------------------------------
--  DAT_OBRA_COLECCION
-- ---------------------------------------------------------------------
CREATE TABLE DAT_OBRA_COLECCION (
    id                    bigserial    PRIMARY KEY,
    coleccion_id          bigint       NOT NULL REFERENCES DAT_COLECCION(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_obra_coleccion UNIQUE (coleccion_id, obra_id)
);

COMMENT ON TABLE DAT_OBRA_COLECCION IS
    'Pertenencia de una obra a una coleccion, con su posicion. Aqui va el numero de volumen dentro de una saga, que por eso no es un dato EAV del libro.';

COMMENT ON COLUMN DAT_OBRA_COLECCION.orden IS
    'Posicion de la obra dentro de la coleccion: numero de volumen o de entrega. Es orden de publicacion, no cronologia interna de la ficcion.';

CREATE INDEX idx_obra_coleccion_por_obra
    ON DAT_OBRA_COLECCION (obra_id);
