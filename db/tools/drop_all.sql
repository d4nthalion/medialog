-- =====================================================================
--  HERRAMIENTA — Borrado completo del esquema
-- =====================================================================
--  DESTRUCTIVO. Elimina las 45 tablas, el tipo enumerado y las tres
--  funciones, con TODOS los datos que contengan: catalogo, cuentas de
--  usuario, resenas y diarios. No hay vuelta atras salvo restaurando
--  un volcado.
--
--  Esta FUERA de db/migrations/ a proposito: esa carpeta se ejecuta
--  entera en bucle, y un fichero de borrado alli dentro arrasaria la
--  base de datos en cada montaje.
--
--  USO NORMAL:
--      npm run db:drop -- --confirmar=BORRAR
--
--  CON psql, si algun dia se instala:
--      psql -d medialog --single-transaction \
--           -c "SET medialog.confirmar='BORRAR'" -f db/tools/drop_all.sql
--
--  Este fichero es SQL puro, sin metacomandos de psql (\set, \if,
--  \echo): el ejecutor de Node no los entenderia. El cerrojo se hace
--  con un parametro de sesion, que funciona igual en los dos.
--
--  No abre transaccion propia: la abre quien lo ejecuta. El ejecutor
--  de Node envuelve cada fichero, y psql lo hace con --single-transaction.
-- =====================================================================

-- ---------------------------------------------------------------------
--  Cerrojo
-- ---------------------------------------------------------------------
--  Aborta si la sesion no trae medialog.confirmar = 'BORRAR'. El
--  segundo argumento de current_setting evita que el parametro
--  inexistente sea un error en si mismo.
-- ---------------------------------------------------------------------
DO $$
BEGIN
    IF current_setting('medialog.confirmar', true) IS DISTINCT FROM 'BORRAR' THEN
        RAISE EXCEPTION
            'ABORTADO: este script borra TODAS las tablas y TODOS los datos. Ejecutar con  npm run db:drop -- --confirmar=BORRAR';
    END IF;
END;
$$;


-- ---------------------------------------------------------------------
--  Borrado
-- ---------------------------------------------------------------------
--  El orden va de las tablas hijas a las padres. Con CASCADE no seria
--  estrictamente necesario, pero deja el fichero legible como inverso
--  exacto de las migraciones, y CASCADE sigue estando por si en el
--  futuro hay vistas colgando de estas tablas.
-- ---------------------------------------------------------------------

-- 014 — Agregados
DROP TABLE IF EXISTS DAT_ESTADISTICA_OBRA    CASCADE;

-- 013 — Listas e interaccion social
DROP TABLE IF EXISTS DAT_COMENTARIO_RESENA   CASCADE;
DROP TABLE IF EXISTS DAT_ME_GUSTA_LISTA      CASCADE;
DROP TABLE IF EXISTS DAT_ME_GUSTA_RESENA     CASCADE;
DROP TABLE IF EXISTS DAT_LISTA_OBRA          CASCADE;
DROP TABLE IF EXISTS DAT_LISTA               CASCADE;

-- 012 — Interaccion con las obras
DROP TABLE IF EXISTS DAT_RESENA              CASCADE;
DROP TABLE IF EXISTS DAT_REGISTRO            CASCADE;
DROP TABLE IF EXISTS DAT_VALORACION          CASCADE;
DROP TABLE IF EXISTS DAT_ESTADO_USUARIO_OBRA CASCADE;
DROP TABLE IF EXISTS CFG_ESTADO_USUARIO_OBRA CASCADE;

-- 011 — Usuarios y grafo social
DROP TABLE IF EXISTS DAT_SEGUIMIENTO         CASCADE;
DROP TABLE IF EXISTS DAT_USUARIO             CASCADE;
DROP TABLE IF EXISTS CFG_ROL_USUARIO         CASCADE;

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
DROP TABLE IF EXISTS DAT_DATO_EPISODIO        CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_EPISODIO CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_EPISODIO   CASCADE;

-- 006 — EAV de serie
DROP TABLE IF EXISTS DAT_DATO_SERIE          CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_SERIE   CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_SERIE     CASCADE;

-- 005 — EAV de pelicula
DROP TABLE IF EXISTS DAT_DATO_PELICULA        CASCADE;
DROP TABLE IF EXISTS CFG_OPCION_DATO_PELICULA CASCADE;
DROP TABLE IF EXISTS CFG_TIPO_DATO_PELICULA   CASCADE;

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

-- 001 — Funciones y tipo enumerado
--  Los triggers de auditoria caen con sus tablas; las funciones que
--  invocan hay que quitarlas aparte.
DROP FUNCTION IF EXISTS fn_refrescar_estadisticas() CASCADE;
DROP FUNCTION IF EXISTS fn_auditoria_modificacion() CASCADE;
DROP FUNCTION IF EXISTS fn_normalizar(text)         CASCADE;
DROP TYPE     IF EXISTS tipo_dato_enum              CASCADE;


-- ---------------------------------------------------------------------
--  Extensiones — NO se borran
-- ---------------------------------------------------------------------
--  pg_trgm y unaccent se instalan a nivel de base de datos, no de
--  esquema, y pueden estar en uso por otras cosas. Se dejan puestas:
--  volver a montar el esquema no las duplica, porque 001 las crea con
--  IF NOT EXISTS.
--
--  Ademas, en Neon y en cualquier Postgres gestionado, reinstalar una
--  extension puede requerir permisos que el usuario de la aplicacion
--  no tiene.
--
--  Si de verdad se quiere una base de datos virgen:
--      DROP EXTENSION IF EXISTS pg_trgm;
--      DROP EXTENSION IF EXISTS unaccent;
-- ---------------------------------------------------------------------
