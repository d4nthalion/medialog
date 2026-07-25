-- =====================================================================
--  002 — Catálogos de configuración transversales
-- =====================================================================
--  Tablas CFG_* compartidas por los tres tipos de obra. Cambian poco y
--  se siembran desde db/seeds/.
-- =====================================================================

-- ---------------------------------------------------------------------
--  CFG_TIPO_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_TIPO_OBRA (
    id                    serial       PRIMARY KEY,
    codigo                varchar(20)  NOT NULL UNIQUE,
    nombre                varchar(50)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_TIPO_OBRA IS
    'Tipos de obra que maneja el sistema. Discrimina el subtipo de DAT_OBRA: cada fila de DAT_OBRA tiene su detalle en DAT_LIBRO, DAT_PELICULA, DAT_SERIE, DAT_TEMPORADA o DAT_EPISODIO segun este valor.';
COMMENT ON COLUMN CFG_TIPO_OBRA.codigo IS
    'Codigo estable usado por la API: LIBRO, PELICULA, SERIE, TEMPORADA, EPISODIO. No cambiar una vez en produccion.';
COMMENT ON COLUMN CFG_TIPO_OBRA.nombre IS
    'Denominacion legible para mostrar al usuario.';


-- ---------------------------------------------------------------------
--  CFG_IDIOMA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_IDIOMA (
    id                    serial       PRIMARY KEY,
    codigo_iso            varchar(3)   NOT NULL UNIQUE,
    nombre                varchar(80)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_IDIOMA IS
    'Catalogo unico de idiomas, compartido por los cuatro modelos EAV. Existe como tabla propia (y no como opciones repetidas en cada CFG_OPCION_DATO_*) para sembrar la lista ISO una sola vez y mantener una FK real.';
COMMENT ON COLUMN CFG_IDIOMA.codigo_iso IS
    'Codigo ISO 639-1 de dos letras, o 639-2 de tres cuando el idioma no tenga codigo de dos.';


-- ---------------------------------------------------------------------
--  CFG_PAIS
-- ---------------------------------------------------------------------
CREATE TABLE CFG_PAIS (
    id                    serial       PRIMARY KEY,
    codigo_iso            varchar(2)   NOT NULL UNIQUE,
    nombre                varchar(80)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_PAIS IS
    'Catalogo unico de paises, compartido por los cuatro modelos EAV. Mismo motivo que CFG_IDIOMA.';
COMMENT ON COLUMN CFG_PAIS.codigo_iso IS
    'Codigo ISO 3166-1 alpha-2.';


-- ---------------------------------------------------------------------
--  CFG_ROL_PERSONA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_ROL_PERSONA (
    id                    serial       PRIMARY KEY,
    codigo                varchar(30)  NOT NULL UNIQUE,
    nombre                varchar(60)  NOT NULL,
    ambito                varchar(20)  NOT NULL DEFAULT 'AMBOS',
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_rol_persona_ambito
        CHECK (ambito IN ('LIBRO', 'AUDIOVISUAL', 'AMBOS'))
);

COMMENT ON TABLE CFG_ROL_PERSONA IS
    'Papeles que una persona puede desempenar en una obra: autor, traductor, ilustrador, director, actor, guionista, showrunner. Se usa desde DAT_PERSONA_OBRA.';
COMMENT ON COLUMN CFG_ROL_PERSONA.ambito IS
    'Restringe en que tipos de obra tiene sentido el rol, solo para filtrar los desplegables del formulario. No es una restriccion de integridad: la base de datos no impide asignar un rol fuera de su ambito.';


-- ---------------------------------------------------------------------
--  CFG_ROL_EMPRESA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_ROL_EMPRESA (
    id                    serial       PRIMARY KEY,
    codigo                varchar(30)  NOT NULL UNIQUE,
    nombre                varchar(60)  NOT NULL,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_ROL_EMPRESA IS
    'Papeles que una empresa puede desempenar en una obra: editorial, estudio, distribuidora, cadena, plataforma. Se usa desde DAT_EMPRESA_OBRA.';


-- ---------------------------------------------------------------------
--  CFG_FUENTE_EXTERNA
-- ---------------------------------------------------------------------
CREATE TABLE CFG_FUENTE_EXTERNA (
    id                    serial       PRIMARY KEY,
    codigo                varchar(20)  NOT NULL UNIQUE,
    nombre                varchar(60)  NOT NULL,
    url_patron            text,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE CFG_FUENTE_EXTERNA IS
    'Origenes de datos externos de los que se importan obras: TMDB, IMDB, OPENLIBRARY, ISBN. Se usa desde DAT_ID_EXTERNO_OBRA.';
COMMENT ON COLUMN CFG_FUENTE_EXTERNA.url_patron IS
    'Plantilla para construir el enlace publico a la ficha original, con {id} como marcador. Ejemplo: https://www.themoviedb.org/movie/{id}';
