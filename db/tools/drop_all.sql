-- =====================================================================
--  HERRAMIENTA — Borrado completo del esquema
-- =====================================================================
--  DESTRUCTIVO. Elimina las 31 tablas, el tipo enumerado y las dos
--  funciones comunes, con TODOS los datos que contengan. No hay
--  vuelta atras salvo restaurando un volcado.
--
--  Esta FUERA de db/migrations/ a proposito: el README ejecuta esa
--  carpeta entera en bucle, y un fichero de borrado alli dentro
--  arrasaria la base de datos en cada montaje.
--
--  USO:
--      psql -d medialog -v confirmar=BORRAR -f db/tools/drop_all.sql
--
--  Sin -v confirmar=BORRAR el script no hace nada y avisa.
--
--  Para volver a montar la base de datos despues:
--      db/migrations/*.sql  y luego  db/seeds/*.sql
-- =====================================================================

\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------
--  Cerrojo
-- ---------------------------------------------------------------------
--  Si la variable no viene definida se le da un valor que nunca
--  coincidira, para que la comprobacion de abajo aborte con un mensaje
--  claro en vez de fallar por interpolacion.
-- ---------------------------------------------------------------------
\if :{?confirmar}
\else
    \set confirmar SIN_CONFIRMAR
\endif

SELECT :'confirmar' = 'BORRAR' AS confirmado \gset

\if :confirmado
    \echo '>> Borrando el esquema completo de medialog...'
\else
    \echo ''
    \echo '  ABORTADO. Este script borra TODAS las tablas y TODOS los datos.'
    \echo ''
    \echo '  Para ejecutarlo de verdad:'
    \echo '      psql -d medialog -v confirmar=BORRAR -f db/tools/drop_all.sql'
    \echo ''
    \quit
\endif


-- ---------------------------------------------------------------------
--  Borrado
-- ---------------------------------------------------------------------
--  Todo dentro de una transaccion: PostgreSQL soporta DDL transaccional,
--  asi que si algo falla a mitad no queda un esquema medio borrado.
--
--  El orden va de las tablas hijas a las padres. Con CASCADE no seria
--  estrictamente necesario, pero deja el fichero legible como inverso
--  exacto de las migraciones, y CASCADE sigue estando por si en el
--  futuro hay vistas o vistas materializadas colgando de estas tablas.
-- ---------------------------------------------------------------------
BEGIN;

-- 009 — Identificadores externos y colecciones
DROP TABLE IF EXISTS DAT_OBRA_COLECCION      CASCADE;
DROP TABLE IF EXISTS DAT_COLECCION           CASCADE;
DROP TABLE IF EXISTS DAT_ID_EXTERNO_OBRA     CASCADE;

-- 008 — Personas y empresas
DROP TABLE IF EXISTS DAT_EMPRESA_OBRA        CASCADE;
DROP TABLE IF EXISTS DAT_EMPRESA             CASCADE;
DROP TABLE IF EXISTS DAT_PERSONA_OBRA        CASCADE;
DROP TABLE IF EXISTS DAT_PERSONA             CASCADE;

-- 007 — EAV de episodio
DROP TABLE IF EXISTS DAT_DATO_EPISODIO       CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_EPISODIO CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_EPISODIO  CASCADE;

-- 006 — EAV de serie
DROP TABLE IF EXISTS DAT_DATO_SERIE          CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_SERIE   CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_SERIE     CASCADE;

-- 005 — EAV de pelicula
DROP TABLE IF EXISTS DAT_DATO_PELICULA       CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_PELICULA CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_PELICULA  CASCADE;

-- 004 — EAV de libro
DROP TABLE IF EXISTS DAT_DATO_LIBRO          CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_LIBRO   CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_LIBRO     CASCADE;

-- 003 — Nucleo de obra
DROP TABLE IF EXISTS DAT_EPISODIO            CASCADE;
DROP TABLE IF EXISTS DAT_TEMPORADA           CASCADE;
DROP TABLE IF EXISTS DAT_SERIE               CASCADE;
DROP TABLE IF EXISTS DAT_PELICULA            CASCADE;
DROP TABLE IF EXISTS DAT_LIBRO               CASCADE;
DROP TABLE IF EXISTS DAT_OBRA                CASCADE;

-- 002 — Catalogos de configuracion
DROP TABLE IF EXISTS CFG_FUENTE_EXTERNA      CASCADE;
DROP TABLE IF EXISTS CFG_ROL_EMPRESA         CASCADE;
DROP TABLE IF EXISTS CFG_ROL_PERSONA         CASCADE;
DROP TABLE IF EXISTS CFG_PAIS                CASCADE;
DROP TABLE IF EXISTS CFG_IDIOMA              CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_OBRA           CASCADE;

-- 001 — Tipo enumerado y funciones
--  Los triggers de auditoria caen con sus tablas; la funcion que
--  invocan hay que quitarla aparte.
DROP FUNCTION IF EXISTS fn_auditoria_modificacion() CASCADE;
DROP FUNCTION IF EXISTS fn_normalizar(text)         CASCADE;
DROP TYPE     IF EXISTS tipo_dato_enum              CASCADE;

COMMIT;


-- ---------------------------------------------------------------------
--  Extensiones — NO se borran
-- ---------------------------------------------------------------------
--  pg_trgm y unaccent se instalan a nivel de base de datos, no de
--  esquema, y pueden estar en uso por otras cosas. Se dejan puestas:
--  volver a montar el esquema no las duplica, porque 001 las crea con
--  IF NOT EXISTS.
--
--  Si de verdad se quiere una base de datos virgen, descomentar:
--
--  DROP EXTENSION IF EXISTS pg_trgm;
--  DROP EXTENSION IF EXISTS unaccent;
-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------
--  Comprobacion
-- ---------------------------------------------------------------------
--  Debe devolver cero filas. Si aparece alguna tabla, es que se creo
--  fuera de las migraciones y este script no la conoce.
-- ---------------------------------------------------------------------
SELECT table_name AS tablas_que_quedan
FROM   information_schema.tables
WHERE  table_schema = 'public'
  AND  table_type   = 'BASE TABLE'
ORDER  BY 1;

\echo '>> Esquema borrado. Para volver a montarlo: db/migrations/*.sql y db/seeds/*.sql'
