-- =====================================================================
--  012 — Interaccion del usuario con las obras
-- =====================================================================
--  La parte que hay que acertar del dominio social. Tres conceptos que
--  se confunden con facilidad y que aqui van SEPARADOS:
--
--    DAT_VALORACION  la nota ACTUAL. Una por usuario y obra. Se corrige.
--    DAT_REGISTRO    el diario. Varias por usuario y obra. Se acumula.
--    DAT_RESENA      el texto. Varias, ligadas o no a un registro.
--
--  Mezclarlas es el error clasico: o pierdes el historial al recalificar,
--  o acabas con cinco notas activas sin saber cual es "la del usuario".
--
--  NOTA SOBRE EPISODIOS: no hace falta ninguna tabla para "episodio
--  visto". Un episodio ya es una fila de DAT_OBRA, asi que marcarlo es
--  un DAT_REGISTRO mas. Lo mismo para puntuar una temporada suelta.
--  Esto es lo que compra el supertipo de 003.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_ESTADO_USUARIO_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_ESTADO_USUARIO_OBRA (
    id                    serial       PRIMARY KEY,
    codigo                varchar(20)  NOT NULL UNIQUE,
    nombre                varchar(50)  NOT NULL,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_ESTADO_USUARIO_OBRA IS
    'Estados en que puede estar una obra para un usuario: PENDIENTE, EN_CURSO, COMPLETADA, ABANDONADA, SIGUIENDO.';


-- ---------------------------------------------------------------------
--  DAT_ESTADO_USUARIO_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_ESTADO_USUARIO_OBRA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    estado_id             int          NOT NULL REFERENCES CFG_ESTADO_USUARIO_OBRA(id),
    progreso              int,
    fecha_cambio_estado   timestamptz  NOT NULL DEFAULT now(),
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_estado_usuario_obra UNIQUE (usuario_id, obra_id),
    CONSTRAINT ck_estado_progreso CHECK (progreso IS NULL OR progreso >= 0)
);

COMMENT ON TABLE DAT_ESTADO_USUARIO_OBRA IS
    'En que punto esta un usuario con una obra. UNA sola tabla en lugar de tres separadas para lista de pendientes, "leyendo ahora" y abandonados: son estados mutuamente excluyentes del mismo hecho, y como tablas independientes habria que sincronizarlas a mano.';

COMMENT ON COLUMN DAT_ESTADO_USUARIO_OBRA.progreso IS
    'Por donde va: pagina del libro o numero de episodio. Nulo si el estado no lo necesita. Su significado depende del tipo de obra, y lo interpreta la aplicacion.';
COMMENT ON COLUMN DAT_ESTADO_USUARIO_OBRA.fecha_cambio_estado IS
    'Cuando entro en el estado actual. Distinta de fecha_modificacion, que tambien cambia al actualizar solo el progreso.';

-- Pantalla principal del usuario: sus pendientes, lo que tiene en curso.
CREATE INDEX idx_estado_usuario
    ON DAT_ESTADO_USUARIO_OBRA (usuario_id, estado_id, fecha_cambio_estado DESC);

-- "Cuanta gente tiene esto pendiente", en la ficha de la obra.
CREATE INDEX idx_estado_obra
    ON DAT_ESTADO_USUARIO_OBRA (obra_id, estado_id);


-- ---------------------------------------------------------------------
--  DAT_VALORACION
-- ---------------------------------------------------------------------
CREATE TABLE DAT_VALORACION (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    nota                  smallint     NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_valoracion UNIQUE (usuario_id, obra_id),
    CONSTRAINT ck_valoracion_nota CHECK (nota BETWEEN 1 AND 10)
);

COMMENT ON TABLE DAT_VALORACION IS
    'Nota ACTUAL de un usuario para una obra. Una sola fila por par: cambiar de opinion es un UPDATE, no una fila nueva. El historial de consumo vive en DAT_REGISTRO, que es otra cosa.';

COMMENT ON COLUMN DAT_VALORACION.nota IS
    'Puntuacion de 1 a 10, que representa media estrella cada punto sobre un maximo de cinco: 7 son tres estrellas y media. Se guarda como ENTERO y no como decimal a proposito: comparar 4.5 en coma flotante da sorpresas, y con enteros el CHECK es trivial. La conversion a estrellas es cosa del frontend.';

-- Calculo de la nota media de una obra (ver 014).
CREATE INDEX idx_valoracion_obra
    ON DAT_VALORACION (obra_id);

-- Perfil: las notas de un usuario, de mas alta a mas baja.
CREATE INDEX idx_valoracion_usuario
    ON DAT_VALORACION (usuario_id, nota DESC);


-- ---------------------------------------------------------------------
--  DAT_REGISTRO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_REGISTRO (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    fecha_inicio          date,
    fecha_fin             date,
    es_repeticion         boolean      NOT NULL DEFAULT false,
    es_privado            boolean      NOT NULL DEFAULT false,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_registro_fechas
        CHECK (fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

COMMENT ON TABLE DAT_REGISTRO IS
    'Diario: cada vez que un usuario ve o lee una obra. Es acumulativo, no se corrige: releer Dune tres veces son tres filas. Marcar un episodio como visto es tambien un registro, porque un episodio ya es una obra.';

COMMENT ON COLUMN DAT_REGISTRO.fecha_inicio IS
    'Cuando empezo. En peliculas suele coincidir con fecha_fin; en libros y series pueden separarse meses. Nulo si el usuario solo recuerda haberla consumido.';
COMMENT ON COLUMN DAT_REGISTRO.fecha_fin IS
    'Cuando termino. Es la fecha por la que se ordena el diario.';
COMMENT ON COLUMN DAT_REGISTRO.es_repeticion IS
    'Marca de relectura o revisionado. Lo pone la aplicacion comprobando si ya existia un registro anterior; no se deduce en la base de datos porque el usuario puede registrar sesiones antiguas en cualquier orden.';
COMMENT ON COLUMN DAT_REGISTRO.es_privado IS
    'Si true, el registro no aparece en el feed ni en el perfil publico. Independiente de perfil_publico del usuario, que es el interruptor general.';

-- El diario del usuario, en orden cronologico inverso.
CREATE INDEX idx_registro_usuario
    ON DAT_REGISTRO (usuario_id, fecha_fin DESC NULLS LAST);

-- "Quien ha visto esto ultimamente", en la ficha de la obra.
CREATE INDEX idx_registro_obra
    ON DAT_REGISTRO (obra_id, fecha_fin DESC NULLS LAST);


-- ---------------------------------------------------------------------
--  DAT_RESENA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_RESENA (
    id                    bigserial    PRIMARY KEY,
    usuario_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    registro_id           bigint       REFERENCES DAT_REGISTRO(id) ON DELETE SET NULL,
    texto                 text         NOT NULL,
    tiene_spoiler         boolean      NOT NULL DEFAULT false,
    es_privado            boolean      NOT NULL DEFAULT false,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_resena_texto CHECK (length(trim(texto)) > 0)
);

COMMENT ON TABLE DAT_RESENA IS
    'Texto que un usuario escribe sobre una obra. Se admiten VARIAS por usuario y obra: una por relectura, o sueltas. No lleva nota: la nota esta en DAT_VALORACION, porque es un hecho que se corrige y la resena un texto que se conserva.';

COMMENT ON COLUMN DAT_RESENA.registro_id IS
    'Sesion concreta del diario a la que corresponde la resena, si la hay. Es opcional: se puede resenar sin haber registrado la fecha. Al borrar el registro la resena sobrevive con este campo a nulo. La coherencia entre la obra de la resena y la del registro la garantiza la API: un CHECK no puede consultar otra tabla.';
COMMENT ON COLUMN DAT_RESENA.tiene_spoiler IS
    'Si true, el frontend oculta el texto tras un aviso. Lo marca quien escribe.';
COMMENT ON COLUMN DAT_RESENA.es_privado IS
    'Si true, la resena es solo para el autor: sirve de nota personal.';

-- Resenas de una obra, las mas recientes primero, saltando las privadas.
CREATE INDEX idx_resena_obra
    ON DAT_RESENA (obra_id, fecha_alta DESC)
    WHERE es_privado = false;

-- Resenas escritas por un usuario, para su perfil.
CREATE INDEX idx_resena_usuario
    ON DAT_RESENA (usuario_id, fecha_alta DESC);
