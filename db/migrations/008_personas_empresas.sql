-- =====================================================================
--  008 — Personas y empresas
-- =====================================================================
--  Autores, directores, actores y guionistas NO son atributos EAV de
--  texto: son entidades con ficha propia.
--
--  La diferencia es practica. Con «Christopher Nolan» guardado como
--  texto, buscar sus peliculas es un LIKE sobre texto libre: lento,
--  sensible a erratas y sin pagina de perfil posible. Como entidad, es
--  un join indexado por clave ajena.
-- =====================================================================

-- ---------------------------------------------------------------------
--  DAT_PERSONA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_PERSONA (
    id                    bigserial    PRIMARY KEY,
    nombre                text         NOT NULL,
    nombre_normalizado    text         GENERATED ALWAYS AS (fn_normalizar(nombre)) STORED,
    fecha_nacimiento      date,
    fecha_fallecimiento   date,
    pais_id               int          REFERENCES CFG_PAIS(id),
    biografia             text,
    foto_url              text,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT ck_persona_fechas
        CHECK (fecha_fallecimiento IS NULL
               OR fecha_nacimiento IS NULL
               OR fecha_fallecimiento >= fecha_nacimiento)
);

COMMENT ON TABLE DAT_PERSONA IS
    'Personas que participan en cualquier obra. Es UNA SOLA tabla para los tres tipos, no una por tipo: Cormac McCarthy es autor y guionista, y esa dualidad no deberia obligar a duplicar la persona. El papel concreto se define en DAT_PERSONA_OBRA.';

COMMENT ON COLUMN DAT_PERSONA.nombre IS
    'Nombre tal y como se muestra, con acentos y mayusculas.';
COMMENT ON COLUMN DAT_PERSONA.nombre_normalizado IS
    'Columna GENERADA a partir de nombre: minusculas y sin acentos, para buscar sin depender de las tildes. No se escribe a mano.';
COMMENT ON COLUMN DAT_PERSONA.pais_id IS
    'Pais de nacimiento o nacionalidad principal.';
COMMENT ON COLUMN DAT_PERSONA.foto_url IS
    'URL de la fotografia. Se guarda la URL, no el binario.';

CREATE INDEX idx_persona_nombre_trgm
    ON DAT_PERSONA USING gin (nombre_normalizado gin_trgm_ops);


-- ---------------------------------------------------------------------
--  DAT_PERSONA_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_PERSONA_OBRA (
    id                    bigserial    PRIMARY KEY,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    persona_id            bigint       NOT NULL REFERENCES DAT_PERSONA(id) ON DELETE CASCADE,
    rol_id                int          NOT NULL REFERENCES CFG_ROL_PERSONA(id),
    personaje             text,
    orden                 smallint     NOT NULL DEFAULT 0,
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_PERSONA_OBRA IS
    'Participacion de una persona en una obra, con su papel. Existe como tabla propia porque hay datos que pertenecen a LA RELACION y no a ninguno de los dos extremos: en "Cillian Murphy actua en Oppenheimer COMO J. Robert Oppenheimer", ese "como" no es un dato de la persona ni de la pelicula.';

COMMENT ON COLUMN DAT_PERSONA_OBRA.obra_id IS
    'Obra en la que participa. Apunta al supertipo DAT_OBRA, de modo que la misma tabla sirve para libros, peliculas, series y episodios.';
COMMENT ON COLUMN DAT_PERSONA_OBRA.rol_id IS
    'Papel desempenado: autor, traductor, director, actor, guionista...';
COMMENT ON COLUMN DAT_PERSONA_OBRA.personaje IS
    'Nombre del personaje interpretado. Solo tiene sentido con rol de actor; nulo en el resto.';
COMMENT ON COLUMN DAT_PERSONA_OBRA.orden IS
    'Orden de aparicion en los creditos. Es lo que permite mostrar el reparto principal antes que los secundarios.';

-- Ficha de la obra: reparto y equipo, ya ordenados.
CREATE INDEX idx_persona_obra_por_obra
    ON DAT_PERSONA_OBRA (obra_id, rol_id, orden);

-- Ficha de la persona: su filmografia o bibliografia.
CREATE INDEX idx_persona_obra_por_persona
    ON DAT_PERSONA_OBRA (persona_id, rol_id);


-- ---------------------------------------------------------------------
--  DAT_EMPRESA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_EMPRESA (
    id                    bigserial    PRIMARY KEY,
    nombre                text         NOT NULL,
    nombre_normalizado    text         GENERATED ALWAYS AS (fn_normalizar(nombre)) STORED,
    pais_id               int          REFERENCES CFG_PAIS(id),
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_EMPRESA IS
    'Editoriales, estudios, distribuidoras, cadenas y plataformas. Una sola tabla para todas, igual que con las personas: Netflix es a la vez productora y plataforma. El papel concreto lo define DAT_EMPRESA_OBRA.';

COMMENT ON COLUMN DAT_EMPRESA.nombre_normalizado IS
    'Columna GENERADA a partir de nombre: minusculas y sin acentos. No se escribe a mano.';

CREATE INDEX idx_empresa_nombre_trgm
    ON DAT_EMPRESA USING gin (nombre_normalizado gin_trgm_ops);


-- ---------------------------------------------------------------------
--  DAT_EMPRESA_OBRA
-- ---------------------------------------------------------------------
CREATE TABLE DAT_EMPRESA_OBRA (
    id                    bigserial    PRIMARY KEY,
    obra_id               bigint       NOT NULL REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    empresa_id            bigint       NOT NULL REFERENCES DAT_EMPRESA(id) ON DELETE CASCADE,
    rol_id                int          NOT NULL REFERENCES CFG_ROL_EMPRESA(id),
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60),

    CONSTRAINT uq_empresa_obra UNIQUE (obra_id, empresa_id, rol_id)
);

COMMENT ON TABLE DAT_EMPRESA_OBRA IS
    'Participacion de una empresa en una obra, con su papel. La clave unica impide registrar dos veces que un mismo estudio produjo la misma pelicula.';

COMMENT ON COLUMN DAT_EMPRESA_OBRA.rol_id IS
    'Papel de la empresa: editorial, estudio, distribuidora, cadena, plataforma.';

CREATE INDEX idx_empresa_obra_por_empresa
    ON DAT_EMPRESA_OBRA (empresa_id, rol_id);
