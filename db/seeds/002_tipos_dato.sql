-- =====================================================================
--  SEED 002 — Catalogo de datos de cada tipo de obra
-- =====================================================================
--  Este fichero es el modelo de datos real del dominio. El diagrama ER
--  muestra las cajas del EAV, pero QUE tiene un libro y QUE tiene una
--  pelicula esta aqui, en filas.
--
--  Documentado en docs/catalogo-datos.md.
--  Idempotente: se puede reejecutar sin duplicar filas.
--
--  NO estan aqui, a proposito:
--    titulo, anio, portada  -> DAT_OBRA
--    autor, director, reparto -> DAT_PERSONA_OBRA
--    isbn, id de TMDB       -> DAT_ID_EXTERNO_OBRA
--    saga, numero de volumen -> DAT_COLECCION
--    nº de temporadas, nota media -> derivados, se calculan
-- =====================================================================


-- =====================================================================
--  LIBRO
-- =====================================================================
INSERT INTO CFG_TIPO_DATO_LIBRO
    (codigo, nombre, tipo_dato, es_multiple, obligatorio, unidad, grupo, orden, usuario_alta)
VALUES
    ('sinopsis',           'Sinopsis',            'TEXTO_LARGO', false, false, NULL,      'General',       1,  'SISTEMA'),
    ('titulo_original',    'Titulo original',     'TEXTO',       false, false, NULL,      'General',       2,  'SISTEMA'),
    ('genero',             'Genero',              'OPCION',      true,  false, NULL,      'Clasificacion', 3,  'SISTEMA'),
    ('tipo_narrativo',     'Tipo de obra',        'OPCION',      false, false, NULL,      'Clasificacion', 4,  'SISTEMA'),
    ('es_ficcion',         'Es ficcion',          'BOOL',        false, false, NULL,      'Clasificacion', 5,  'SISTEMA'),
    ('publico',            'Publico objetivo',    'OPCION',      false, false, NULL,      'Clasificacion', 6,  'SISTEMA'),
    ('contenido_sensible', 'Contenido sensible',  'OPCION',      true,  false, NULL,      'Clasificacion', 7,  'SISTEMA'),
    ('idioma_original',    'Idioma original',     'IDIOMA',      false, true,  NULL,      'Publicacion',   8,  'SISTEMA'),
    ('pais_publicacion',   'Pais de publicacion', 'PAIS',        false, false, NULL,      'Publicacion',   9,  'SISTEMA'),
    ('fecha_publicacion',  'Primera publicacion', 'FECHA',       false, false, NULL,      'Publicacion',   10, 'SISTEMA'),
    ('num_paginas',        'Numero de paginas',   'ENTERO',      false, false, 'paginas', 'Publicacion',   11, 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;

-- Generos de libro
INSERT INTO CFG_OPCION_DATO_LIBRO (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_LIBRO td
CROSS JOIN (VALUES
    ('FANTASIA',        'Fantasia',         1),
    ('CIENCIA_FICCION', 'Ciencia ficcion',  2),
    ('MISTERIO',        'Misterio',         3),
    ('THRILLER',        'Thriller',         4),
    ('TERROR',          'Terror',           5),
    ('ROMANCE',         'Romance',          6),
    ('HISTORICA',       'Historica',        7),
    ('CONTEMPORANEA',   'Contemporanea',    8),
    ('BIOGRAFIA',       'Biografia',        9),
    ('ENSAYO',          'Ensayo',          10),
    ('AUTOAYUDA',       'Autoayuda',       11),
    ('DIVULGACION',     'Divulgacion',     12),
    ('POESIA',          'Poesia',          13),
    ('INFANTIL',        'Infantil',        14)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'genero'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Tipo narrativo
INSERT INTO CFG_OPCION_DATO_LIBRO (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_LIBRO td
CROSS JOIN (VALUES
    ('NOVELA', 'Novela',  1),
    ('RELATO', 'Relatos', 2),
    ('ENSAYO', 'Ensayo',  3),
    ('POESIA', 'Poesia',  4),
    ('COMIC',  'Comic',   5),
    ('MANGA',  'Manga',   6),
    ('TEATRO', 'Teatro',  7)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'tipo_narrativo'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Publico objetivo
INSERT INTO CFG_OPCION_DATO_LIBRO (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_LIBRO td
CROSS JOIN (VALUES
    ('INFANTIL', 'Infantil', 1),
    ('JUVENIL',  'Juvenil',  2),
    ('ADULTO',   'Adulto',   3)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'publico'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Contenido sensible
INSERT INTO CFG_OPCION_DATO_LIBRO (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_LIBRO td
CROSS JOIN (VALUES
    ('VIOLENCIA',      'Violencia',              1),
    ('VIOLENCIA_SEX',  'Violencia sexual',       2),
    ('SUICIDIO',       'Suicidio y autolesion',  3),
    ('ADICCIONES',     'Adicciones',             4),
    ('MALTRATO',       'Maltrato',               5),
    ('DUELO',          'Duelo y perdida',        6)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'contenido_sensible'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;


-- =====================================================================
--  PELICULA
-- =====================================================================
INSERT INTO CFG_TIPO_DATO_PELICULA
    (codigo, nombre, tipo_dato, es_multiple, obligatorio, unidad, grupo, orden, usuario_alta)
VALUES
    ('sinopsis',           'Sinopsis',             'TEXTO_LARGO', false, false, NULL,      'General',       1,  'SISTEMA'),
    ('titulo_original',    'Titulo original',      'TEXTO',       false, false, NULL,      'General',       2,  'SISTEMA'),
    ('eslogan',            'Eslogan',              'TEXTO',       false, false, NULL,      'General',       3,  'SISTEMA'),
    ('genero',             'Genero',               'OPCION',      true,  false, NULL,      'Clasificacion', 4,  'SISTEMA'),
    ('clasificacion_edad', 'Clasificacion',        'OPCION',      false, false, NULL,      'Clasificacion', 5,  'SISTEMA'),
    ('color',              'Color',                'OPCION',      false, false, NULL,      'Clasificacion', 6,  'SISTEMA'),
    ('idioma_original',    'Idioma original',      'IDIOMA',      false, true,  NULL,      'Produccion',    7,  'SISTEMA'),
    ('pais_produccion',    'Pais de produccion',   'PAIS',        true,  false, NULL,      'Produccion',    8,  'SISTEMA'),
    ('fecha_estreno',      'Fecha de estreno',     'FECHA',       false, false, NULL,      'Produccion',    9,  'SISTEMA'),
    ('duracion',           'Duracion',             'ENTERO',      false, false, 'minutos', 'Produccion',    10, 'SISTEMA'),
    ('presupuesto',        'Presupuesto',          'DECIMAL',     false, false, 'USD',     'Taquilla',      11, 'SISTEMA'),
    ('recaudacion',        'Recaudacion',          'DECIMAL',     false, false, 'USD',     'Taquilla',      12, 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;

-- Generos audiovisuales
INSERT INTO CFG_OPCION_DATO_PELICULA (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_PELICULA td
CROSS JOIN (VALUES
    ('ACCION',          'Accion',           1),
    ('AVENTURA',        'Aventura',         2),
    ('ANIMACION',       'Animacion',        3),
    ('COMEDIA',         'Comedia',          4),
    ('CRIMEN',          'Crimen',           5),
    ('DOCUMENTAL',      'Documental',       6),
    ('DRAMA',           'Drama',            7),
    ('FAMILIAR',        'Familiar',         8),
    ('FANTASIA',        'Fantasia',         9),
    ('TERROR',          'Terror',          10),
    ('MUSICAL',         'Musical',         11),
    ('MISTERIO',        'Misterio',        12),
    ('ROMANCE',         'Romance',         13),
    ('CIENCIA_FICCION', 'Ciencia ficcion', 14),
    ('THRILLER',        'Thriller',        15),
    ('BELICA',          'Belica',          16),
    ('WESTERN',         'Western',         17)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'genero'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Clasificacion por edades
--  Valor normalizado propio. Replicar PEGI, MPAA e ICAA por separado no
--  compensa: son incompatibles entre si y ninguna cubre todo el catalogo.
INSERT INTO CFG_OPCION_DATO_PELICULA (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_PELICULA td
CROSS JOIN (VALUES
    ('TP',  'Todos los publicos', 1),
    ('+7',  '+7',                 2),
    ('+12', '+12',                3),
    ('+16', '+16',                4),
    ('+18', '+18',                5)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'clasificacion_edad'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Color
INSERT INTO CFG_OPCION_DATO_PELICULA (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_PELICULA td
CROSS JOIN (VALUES
    ('COLOR', 'Color',          1),
    ('BN',    'Blanco y negro', 2),
    ('MIXTO', 'Mixto',          3)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'color'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;


-- =====================================================================
--  SERIE
-- =====================================================================
INSERT INTO CFG_TIPO_DATO_SERIE
    (codigo, nombre, tipo_dato, es_multiple, obligatorio, unidad, grupo, orden, usuario_alta)
VALUES
    ('sinopsis',           'Sinopsis',            'TEXTO_LARGO', false, false, NULL,      'General',       1,  'SISTEMA'),
    ('titulo_original',    'Titulo original',     'TEXTO',       false, false, NULL,      'General',       2,  'SISTEMA'),
    ('genero',             'Genero',              'OPCION',      true,  false, NULL,      'Clasificacion', 3,  'SISTEMA'),
    ('tipo_serie',         'Tipo de serie',       'OPCION',      false, false, NULL,      'Clasificacion', 4,  'SISTEMA'),
    ('clasificacion_edad', 'Clasificacion',       'OPCION',      false, false, NULL,      'Clasificacion', 5,  'SISTEMA'),
    ('estado',             'Estado',              'OPCION',      false, true,  NULL,      'Emision',       6,  'SISTEMA'),
    ('fecha_inicio',       'Inicio de emision',   'FECHA',       false, false, NULL,      'Emision',       7,  'SISTEMA'),
    ('fecha_fin',          'Fin de emision',      'FECHA',       false, false, NULL,      'Emision',       8,  'SISTEMA'),
    ('duracion_media',     'Duracion por episodio','ENTERO',     false, false, 'minutos', 'Emision',       9,  'SISTEMA'),
    ('idioma_original',    'Idioma original',     'IDIOMA',      false, true,  NULL,      'Produccion',    10, 'SISTEMA'),
    ('pais_produccion',    'Pais de produccion',  'PAIS',        true,  false, NULL,      'Produccion',    11, 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;

-- Generos audiovisuales (mismos codigos que en PELICULA, a proposito)
INSERT INTO CFG_OPCION_DATO_SERIE (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_SERIE td
CROSS JOIN (VALUES
    ('ACCION',          'Accion',           1),
    ('AVENTURA',        'Aventura',         2),
    ('ANIMACION',       'Animacion',        3),
    ('COMEDIA',         'Comedia',          4),
    ('CRIMEN',          'Crimen',           5),
    ('DOCUMENTAL',      'Documental',       6),
    ('DRAMA',           'Drama',            7),
    ('FAMILIAR',        'Familiar',         8),
    ('FANTASIA',        'Fantasia',         9),
    ('TERROR',          'Terror',          10),
    ('MUSICAL',         'Musical',         11),
    ('MISTERIO',        'Misterio',        12),
    ('ROMANCE',         'Romance',         13),
    ('CIENCIA_FICCION', 'Ciencia ficcion', 14),
    ('THRILLER',        'Thriller',        15),
    ('BELICA',          'Belica',          16),
    ('WESTERN',         'Western',         17)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'genero'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Estado de emision
--  Es el dato que permite avisar de episodios nuevos a quien sigue la
--  serie. Sus codigos no deberian cambiarse una vez en produccion.
INSERT INTO CFG_OPCION_DATO_SERIE (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_SERIE td
CROSS JOIN (VALUES
    ('EN_EMISION', 'En emision', 1),
    ('EN_PAUSA',   'En pausa',   2),
    ('FINALIZADA', 'Finalizada', 3),
    ('CANCELADA',  'Cancelada',  4)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'estado'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Tipo de serie
INSERT INTO CFG_OPCION_DATO_SERIE (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_SERIE td
CROSS JOIN (VALUES
    ('SERIE',      'Serie',      1),
    ('MINISERIE',  'Miniserie',  2),
    ('ANTOLOGIA',  'Antologia',  3),
    ('DOCUSERIE',  'Docuserie',  4)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'tipo_serie'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;

-- Clasificacion por edades (mismos codigos que en PELICULA)
INSERT INTO CFG_OPCION_DATO_SERIE (tipo_dato_id, codigo, etiqueta, orden, usuario_alta)
SELECT td.id, v.codigo, v.etiqueta, v.orden, 'SISTEMA'
FROM CFG_TIPO_DATO_SERIE td
CROSS JOIN (VALUES
    ('TP',  'Todos los publicos', 1),
    ('+7',  '+7',                 2),
    ('+12', '+12',                3),
    ('+16', '+16',                4),
    ('+18', '+18',                5)
) AS v(codigo, etiqueta, orden)
WHERE td.codigo = 'clasificacion_edad'
ON CONFLICT (tipo_dato_id, codigo) DO NOTHING;


-- =====================================================================
--  EPISODIO
-- =====================================================================
INSERT INTO CFG_TIPO_DATO_EPISODIO
    (codigo, nombre, tipo_dato, es_multiple, obligatorio, unidad, grupo, orden, usuario_alta)
VALUES
    ('sinopsis',        'Sinopsis',          'TEXTO_LARGO', false, false, NULL,      'General', 1, 'SISTEMA'),
    ('duracion',        'Duracion',          'ENTERO',      false, false, 'minutos', 'General', 2, 'SISTEMA'),
    ('fecha_emision',   'Fecha de emision',  'FECHA',       false, false, NULL,      'General', 3, 'SISTEMA'),
    ('numero_absoluto', 'Numero absoluto',   'ENTERO',      false, false, NULL,      'General', 4, 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;
