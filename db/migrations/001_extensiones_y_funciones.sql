-- =====================================================================
--  001 — Extensiones, tipos y funciones comunes
-- =====================================================================
--  Ejecutar antes que cualquier otra migración.
--
--  NOTA SOBRE MAYÚSCULAS: los nombres se escriben en mayúsculas por
--  convención pero NO van entrecomillados. PostgreSQL los pliega a
--  minúsculas al guardarlos, y siguen siendo consultables en mayúsculas.
--  Entrecomillar uno obligaría a entrecomillarlos todos, para siempre.
-- =====================================================================

-- Búsqueda difusa de títulos: «interestelar» debe encontrar «Interstellar».
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Eliminación de acentos para normalizar títulos y nombres.
CREATE EXTENSION IF NOT EXISTS unaccent;


-- ---------------------------------------------------------------------
--  Tipo de dato de un atributo EAV
-- ---------------------------------------------------------------------
--  Cada valor determina en qué columna de DAT_DATO_* se guarda el dato:
--
--    TEXTO / TEXTO_LARGO -> valor_texto
--    ENTERO              -> valor_entero
--    DECIMAL             -> valor_decimal
--    FECHA               -> valor_fecha
--    BOOL                -> valor_bool
--    OPCION              -> valor_opcion_id  (CFG_OPCION_DATO_*)
--    IDIOMA              -> valor_idioma_id  (CFG_IDIOMA)
--    PAIS                -> valor_pais_id    (CFG_PAIS)
--
--  IDIOMA y PAIS son tipos propios en vez de opciones para no tener que
--  sembrar la lista ISO una vez por cada tipo de obra.
-- ---------------------------------------------------------------------
CREATE TYPE tipo_dato_enum AS ENUM (
    'TEXTO',
    'TEXTO_LARGO',
    'ENTERO',
    'DECIMAL',
    'FECHA',
    'BOOL',
    'OPCION',
    'IDIOMA',
    'PAIS'
);

COMMENT ON TYPE tipo_dato_enum IS
    'Tipo de un atributo EAV. Determina en qué columna valor_* de DAT_DATO_* se almacena.';


-- ---------------------------------------------------------------------
--  fn_normalizar — texto comparable para búsquedas
-- ---------------------------------------------------------------------
--  Pasa a minúsculas y elimina acentos, de forma que «El Padrino» y
--  «el padrino» sean el mismo texto de búsqueda.
--
--  Se declara IMMUTABLE a propósito: unaccent() es sólo STABLE porque
--  depende del diccionario activo, y una función STABLE no puede usarse
--  en una columna generada ni en un índice de expresión. Pasar el
--  diccionario explícitamente ('public.unaccent') elimina esa dependencia
--  y hace la inmutabilidad legítima.
--
--  CONSECUENCIA: si algún día se cambia el diccionario unaccent, hay que
--  reconstruir las columnas generadas y los índices que usen esta función.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_normalizar(txt text)
RETURNS text
LANGUAGE sql
IMMUTABLE
STRICT
PARALLEL SAFE
AS $$
    SELECT lower(public.unaccent('public.unaccent', txt))
$$;

COMMENT ON FUNCTION fn_normalizar(text) IS
    'Devuelve el texto en minúsculas y sin acentos, para búsqueda insensible a mayúsculas y tildes.';


-- ---------------------------------------------------------------------
--  fn_auditoria_modificacion — trigger de auditoría
-- ---------------------------------------------------------------------
--  Rellena fecha_modificacion en cada UPDATE.
--
--  NO toca usuario_modificacion: la base de datos no sabe qué usuario de
--  la aplicación hay detrás de la conexión. Ese campo lo pone la API.
--
--  Se engancha automáticamente a todas las tablas en 011_auditoria.sql.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_auditoria_modificacion()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.fecha_modificacion := now();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION fn_auditoria_modificacion() IS
    'Trigger BEFORE UPDATE: sella fecha_modificacion. usuario_modificacion lo aporta la aplicación.';
