-- =====================================================================
--  013 — Listas de usuario e interaccion social sobre contenido
-- =====================================================================

-- ---------------------------------------------------------------------
--  DAT_LISTA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_LISTA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    nombre                varchar(120) NOT NULL,
    descripcion           text,
    es_publica            boolean      NOT NULL DEFAULT true,
    es_ordenada           boolean      NOT NULL DEFAULT false,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_lista_usuario_nombre UNIQUE (usuario_id, nombre)
);

COMMENT ON TABLE DAT_LISTA IS
    'Lista creada por un usuario. NO confundir con DAT_COLECCION: aquella es del catalogo y agrupa sagas y trilogias como hecho objetivo; esta es subjetiva y pertenece a quien la crea. Puede mezclar libros, peliculas y series, porque todas sus entradas apuntan al supertipo DAT_OBRA.';

COMMENT ON COLUMN DAT_LISTA.es_publica IS
    'Si false, solo la ve su autor.';
COMMENT ON COLUMN DAT_LISTA.es_ordenada IS
    'Si true, el orden de las obras es significativo y se respeta al mostrarla (un ranking). Si false, el orden es libre y la aplicacion puede reordenar por titulo o por ano.';

CREATE INDEX idx_lista_usuario
    ON DAT_LISTA (usuario_id, fecha_alta DESC);

-- Descubrimiento: listas publicas recientes.
CREATE INDEX idx_lista_publicas
    ON DAT_LISTA (fecha_alta DESC)
    WHERE es_publica = true;


-- ---------------------------------------------------------------------
--  DAT_LISTA_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_LISTA_OBRA (
    id                    bigserial    PRIMARY KEY,
    lista_id              bigint       NOT NULL REFERENCES DAT_LISTA(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    orden                 smallint     NOT NULL DEFAULT 0,
    comentario            text,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_lista_obra UNIQUE (lista_id, obra_id)
);

COMMENT ON TABLE DAT_LISTA_OBRA IS
    'Pertenencia de una obra a una lista. La clave unica impide anadir dos veces la misma obra a la misma lista.';

COMMENT ON COLUMN DAT_LISTA_OBRA.orden IS
    'Posicion dentro de la lista. Solo significativa si la lista es ordenada.';
COMMENT ON COLUMN DAT_LISTA_OBRA.comentario IS
    'Nota del autor sobre por que esta obra esta en la lista. Es lo que convierte una lista en contenido y no en un monton de portadas.';

CREATE INDEX idx_lista_obra_por_lista
    ON DAT_LISTA_OBRA (lista_id, orden);

-- "En que listas aparece esta obra", en su ficha.
CREATE INDEX idx_lista_obra_por_obra
    ON DAT_LISTA_OBRA (obra_id);


-- ---------------------------------------------------------------------
--  DAT_ME_GUSTA_RESENA  /  DAT_ME_GUSTA_LISTA
-- ---------------------------------------------------------------------
--  Dos tablas en vez de una generica con (tipo, id). Es la misma
--  decision que con DAT_OBRA: una FK polimorfica no tiene integridad
--  referencial y permite apuntar a filas que no existen. Aqui las
--  tablas son pequenas y duplicarlas apenas cuesta.
-- ---------------------------------------------------------------------
CREATE TABLE DAT_ME_GUSTA_RESENA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    resena_id             bigint       NOT NULL REFERENCES DAT_RESENA(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_me_gusta_resena UNIQUE (usuario_id, resena_id)
);

COMMENT ON TABLE DAT_ME_GUSTA_RESENA IS
    'Me gusta de un usuario a una resena. La clave unica impide contar dos veces al mismo usuario.';

CREATE INDEX idx_me_gusta_resena_por_resena
    ON DAT_ME_GUSTA_RESENA (resena_id);


CREATE TABLE DAT_ME_GUSTA_LISTA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    lista_id              bigint       NOT NULL REFERENCES DAT_LISTA(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_me_gusta_lista UNIQUE (usuario_id, lista_id)
);

COMMENT ON TABLE DAT_ME_GUSTA_LISTA IS
    'Me gusta de un usuario a una lista.';

CREATE INDEX idx_me_gusta_lista_por_lista
    ON DAT_ME_GUSTA_LISTA (lista_id);


-- ---------------------------------------------------------------------
--  DAT_COMENTARIO_RESENA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_COMENTARIO_RESENA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    resena_id             bigint       NOT NULL REFERENCES DAT_RESENA(id) ON DELETE CASCADE,
    comentario_padre_id   bigint       REFERENCES DAT_COMENTARIO_RESENA(id) ON DELETE CASCADE,
    texto                 text         NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_comentario_texto CHECK (length(trim(texto)) > 0)
);

COMMENT ON TABLE DAT_COMENTARIO_RESENA IS
    'Comentario sobre una resena, con respuestas anidadas. Es la funcionalidad que trae moderacion consigo: conviene no abrirla hasta tener el rol MODERADOR en uso.';

COMMENT ON COLUMN DAT_COMENTARIO_RESENA.comentario_padre_id IS
    'Comentario al que responde, nulo si es de primer nivel. La autorreferencia permite hilos de profundidad arbitraria; conviene que la aplicacion limite ese anidamiento a dos o tres niveles.';

CREATE INDEX idx_comentario_resena
    ON DAT_COMENTARIO_RESENA (resena_id, fecha_alta);
