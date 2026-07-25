-- =====================================================================
--  SEED 001 — Catalogos de configuracion transversales
-- =====================================================================
--  Idempotente: se puede reejecutar sin duplicar filas.
--  Todas las altas quedan marcadas como usuario SISTEMA.
-- =====================================================================

-- ---------------------------------------------------------------------
--  Tipos de obra
-- ---------------------------------------------------------------------
INSERT INTO CFG_TIPO_OBRA (codigo, nombre, usuario_alta) VALUES
    ('LIBRO',     'Libro',     'SISTEMA'),
    ('PELICULA',  'Pelicula',  'SISTEMA'),
    ('SERIE',     'Serie',     'SISTEMA'),
    ('TEMPORADA', 'Temporada', 'SISTEMA'),
    ('EPISODIO',  'Episodio',  'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;


-- ---------------------------------------------------------------------
--  Idiomas — subconjunto inicial
-- ---------------------------------------------------------------------
--  Cargar la lista ISO 639-1 completa cuando haga falta; estos cubren
--  la practica totalidad del catalogo occidental.
-- ---------------------------------------------------------------------
INSERT INTO CFG_IDIOMA (codigo_iso, nombre, usuario_alta) VALUES
    ('es', 'Espanol',    'SISTEMA'),
    ('en', 'Ingles',     'SISTEMA'),
    ('fr', 'Frances',    'SISTEMA'),
    ('de', 'Aleman',     'SISTEMA'),
    ('it', 'Italiano',   'SISTEMA'),
    ('pt', 'Portugues',  'SISTEMA'),
    ('ca', 'Catalan',    'SISTEMA'),
    ('eu', 'Euskera',    'SISTEMA'),
    ('gl', 'Gallego',    'SISTEMA'),
    ('ja', 'Japones',    'SISTEMA'),
    ('ko', 'Coreano',    'SISTEMA'),
    ('zh', 'Chino',      'SISTEMA'),
    ('ru', 'Ruso',       'SISTEMA'),
    ('sv', 'Sueco',      'SISTEMA'),
    ('da', 'Danes',      'SISTEMA'),
    ('no', 'Noruego',    'SISTEMA'),
    ('nl', 'Neerlandes', 'SISTEMA'),
    ('pl', 'Polaco',     'SISTEMA'),
    ('ar', 'Arabe',      'SISTEMA'),
    ('hi', 'Hindi',      'SISTEMA')
ON CONFLICT (codigo_iso) DO NOTHING;


-- ---------------------------------------------------------------------
--  Paises — subconjunto inicial
-- ---------------------------------------------------------------------
INSERT INTO CFG_PAIS (codigo_iso, nombre, usuario_alta) VALUES
    ('ES', 'Espana',           'SISTEMA'),
    ('US', 'Estados Unidos',   'SISTEMA'),
    ('GB', 'Reino Unido',      'SISTEMA'),
    ('FR', 'Francia',          'SISTEMA'),
    ('DE', 'Alemania',         'SISTEMA'),
    ('IT', 'Italia',           'SISTEMA'),
    ('PT', 'Portugal',         'SISTEMA'),
    ('MX', 'Mexico',           'SISTEMA'),
    ('AR', 'Argentina',        'SISTEMA'),
    ('BR', 'Brasil',           'SISTEMA'),
    ('CL', 'Chile',            'SISTEMA'),
    ('CO', 'Colombia',         'SISTEMA'),
    ('JP', 'Japon',            'SISTEMA'),
    ('KR', 'Corea del Sur',    'SISTEMA'),
    ('CN', 'China',            'SISTEMA'),
    ('IN', 'India',            'SISTEMA'),
    ('CA', 'Canada',           'SISTEMA'),
    ('AU', 'Australia',        'SISTEMA'),
    ('SE', 'Suecia',           'SISTEMA'),
    ('DK', 'Dinamarca',        'SISTEMA'),
    ('NO', 'Noruega',          'SISTEMA'),
    ('NL', 'Paises Bajos',     'SISTEMA'),
    ('IE', 'Irlanda',          'SISTEMA'),
    ('RU', 'Rusia',            'SISTEMA')
ON CONFLICT (codigo_iso) DO NOTHING;


-- ---------------------------------------------------------------------
--  Roles de persona
-- ---------------------------------------------------------------------
INSERT INTO CFG_ROL_PERSONA (codigo, nombre, ambito, usuario_alta) VALUES
    ('AUTOR',        'Autor',              'LIBRO',       'SISTEMA'),
    ('TRADUCTOR',    'Traductor',          'LIBRO',       'SISTEMA'),
    ('ILUSTRADOR',   'Ilustrador',         'LIBRO',       'SISTEMA'),
    ('PROLOGUISTA',  'Prologuista',        'LIBRO',       'SISTEMA'),
    ('DIRECTOR',     'Director',           'AUDIOVISUAL', 'SISTEMA'),
    ('ACTOR',        'Actor',              'AUDIOVISUAL', 'SISTEMA'),
    ('GUIONISTA',    'Guionista',          'AMBOS',       'SISTEMA'),
    ('PRODUCTOR',    'Productor',          'AUDIOVISUAL', 'SISTEMA'),
    ('COMPOSITOR',   'Compositor',         'AUDIOVISUAL', 'SISTEMA'),
    ('FOTOGRAFIA',   'Director de fotografia', 'AUDIOVISUAL', 'SISTEMA'),
    ('MONTAJE',      'Montaje',            'AUDIOVISUAL', 'SISTEMA'),
    ('SHOWRUNNER',   'Showrunner',         'AUDIOVISUAL', 'SISTEMA'),
    ('CREADOR',      'Creador',            'AUDIOVISUAL', 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;


-- ---------------------------------------------------------------------
--  Roles de empresa
-- ---------------------------------------------------------------------
INSERT INTO CFG_ROL_EMPRESA (codigo, nombre, usuario_alta) VALUES
    ('EDITORIAL',     'Editorial',     'SISTEMA'),
    ('ESTUDIO',       'Estudio',       'SISTEMA'),
    ('DISTRIBUIDORA', 'Distribuidora', 'SISTEMA'),
    ('CADENA',        'Cadena',        'SISTEMA'),
    ('PLATAFORMA',    'Plataforma',    'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;


-- ---------------------------------------------------------------------
--  Fuentes externas
-- ---------------------------------------------------------------------
INSERT INTO CFG_FUENTE_EXTERNA (codigo, nombre, url_patron, usuario_alta) VALUES
    ('TMDB',        'The Movie Database', 'https://www.themoviedb.org/movie/{id}', 'SISTEMA'),
    ('TMDB_TV',     'The Movie Database (TV)', 'https://www.themoviedb.org/tv/{id}', 'SISTEMA'),
    ('IMDB',        'IMDb',               'https://www.imdb.com/title/{id}',       'SISTEMA'),
    ('OPENLIBRARY', 'Open Library',       'https://openlibrary.org/works/{id}',    'SISTEMA'),
    ('ISBN',        'ISBN',               NULL,                                    'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;
