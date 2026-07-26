-- =====================================================================
--  011 — Usuarios y grafo social
-- =====================================================================
--  Empieza el dominio social. A partir de aqui NO hay EAV: el esquema
--  es fijo, conocido y de alto volumen de escritura. Meter esto en EAV
--  destruiria el rendimiento sin dar nada a cambio.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_ROL_USUARIO
-- ---------------------------------------------------------------------
CREATE TABLE CFG_ROL_USUARIO (
    id                    serial       PRIMARY KEY,
    codigo                varchar(20)  NOT NULL UNIQUE,
    nombre                varchar(50)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_ROL_USUARIO IS
    'Nivel de permisos de un usuario: USUARIO, MODERADOR, ADMIN. En un catalogo colaborativo hace falta desde el primer dia: alguien tiene que poder corregir metadatos ajenos y fusionar obras duplicadas.';


-- ---------------------------------------------------------------------
--  DAT_USUARIO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_USUARIO (
    id                    bigserial    PRIMARY KEY,
    login                 varchar(30)  NOT NULL UNIQUE,
    email                 varchar(254) NOT NULL UNIQUE,
    hash_password         text         NOT NULL,
    nombre_visible        varchar(80),
    biografia             text,
    avatar_url            text,
    rol_id                int          NOT NULL REFERENCES CFG_ROL_USUARIO(id),
    idioma_id             int          REFERENCES CFG_IDIOMA(id),
    perfil_publico        boolean      NOT NULL DEFAULT true,
    activo                boolean      NOT NULL DEFAULT true,
    fecha_ultimo_acceso   timestamptz,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_usuario_login  CHECK (login ~ '^[a-z0-9_]{3,30}$'),
    CONSTRAINT ck_usuario_email  CHECK (email = lower(email) AND email LIKE '%_@_%._%')
);

COMMENT ON TABLE DAT_USUARIO IS
    'Cuenta de una persona. Las bajas son LOGICAS (activo = false) y no borrados en cascada: si un usuario desapareciera arrastrando sus resenas, se llevaria por delante los hilos de comentarios de otros. Al darse de baja se anonimizan login, email y biografia, y su contenido queda como "usuario eliminado".';

COMMENT ON COLUMN DAT_USUARIO.login IS
    'Nombre de usuario publico, en minusculas, alfanumerico y guion bajo. Es el que aparece en la URL del perfil.';
COMMENT ON COLUMN DAT_USUARIO.email IS
    'Correo, normalizado a minusculas por el CHECK para que la unicidad sea real: sin eso, Juan@x.com y juan@x.com serian dos cuentas distintas.';
COMMENT ON COLUMN DAT_USUARIO.hash_password IS
    'Hash de la contrasena, nunca la contrasena. Algoritmo previsto: argon2id. La columna es text y no varchar porque la longitud del hash depende de los parametros y puede cambiar al rotarlos.';
COMMENT ON COLUMN DAT_USUARIO.nombre_visible IS
    'Nombre que se muestra en lugar del login. Opcional.';
COMMENT ON COLUMN DAT_USUARIO.idioma_id IS
    'Idioma preferido para la interfaz y para elegir sinopsis cuando haya varias.';
COMMENT ON COLUMN DAT_USUARIO.perfil_publico IS
    'Si false, solo los seguidores aprobados ven su actividad. Es el interruptor general; registros, resenas y listas tienen ademas su propia marca de privacidad.';
COMMENT ON COLUMN DAT_USUARIO.activo IS
    'Baja logica. Un usuario inactivo no puede iniciar sesion, pero su contenido sigue existiendo para no romper conversaciones ajenas.';
COMMENT ON COLUMN DAT_USUARIO.fecha_ultimo_acceso IS
    'Ultimo inicio de sesion. Sirve para limpiar cuentas abandonadas y para el "activo hace X".';

-- Login y email ya tienen indice por su UNIQUE. Este cubre el listado
-- de usuarios activos, que es lo que consulta la administracion.
CREATE INDEX idx_usuario_activo
    ON DAT_USUARIO (activo, fecha_alta DESC);


-- ---------------------------------------------------------------------
--  DAT_SEGUIMIENTO
-- ---------------------------------------------------------------------
CREATE TABLE DAT_SEGUIMIENTO (
    id                    bigserial    PRIMARY KEY,
    seguidor_id           bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    seguido_id            bigint       NOT NULL REFERENCES DAT_USUARIO(id) ON DELETE CASCADE,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_seguimiento UNIQUE (seguidor_id, seguido_id),
    CONSTRAINT ck_seguimiento_no_propio CHECK (seguidor_id <> seguido_id)
);

COMMENT ON TABLE DAT_SEGUIMIENTO IS
    'Relacion "A sigue a B". Es dirigida y no reciproca: que A siga a B no implica lo contrario. Es la tabla que alimenta el feed de actividad.';

COMMENT ON COLUMN DAT_SEGUIMIENTO.seguidor_id IS
    'Quien sigue.';
COMMENT ON COLUMN DAT_SEGUIMIENTO.seguido_id IS
    'A quien se sigue.';

-- "A quien sigo": punto de partida del feed.
CREATE INDEX idx_seguimiento_seguidor
    ON DAT_SEGUIMIENTO (seguidor_id);

-- "Quien me sigue": la consulta inversa necesita su propio indice,
-- porque el UNIQUE solo sirve empezando por seguidor_id.
CREATE INDEX idx_seguimiento_seguido
    ON DAT_SEGUIMIENTO (seguido_id);
