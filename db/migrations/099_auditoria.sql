-- =====================================================================
--  010 — Auditoria: triggers y comentarios comunes
-- =====================================================================
--  Ultima migracion. Recorre las tablas ya creadas y les engancha el
--  trigger de auditoria y los comentarios de sus cuatro columnas de
--  auditoria.
--
--  Se hace en bucle y no tabla a tabla por dos motivos: son 31 tablas
--  con el mismo tratamiento, y asi una tabla nueva solo necesita volver
--  a ejecutar este fichero (es idempotente) para quedar cubierta.
-- =====================================================================

-- ---------------------------------------------------------------------
--  Trigger de sellado de fecha_modificacion
-- ---------------------------------------------------------------------
DO $$
DECLARE
    tabla text;
BEGIN
    FOR tabla IN
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND column_name  = 'fecha_modificacion'
        ORDER BY table_name
    LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_%1$s_auditoria ON %1$I', tabla
        );
        EXECUTE format(
            'CREATE TRIGGER trg_%1$s_auditoria
                 BEFORE UPDATE ON %1$I
                 FOR EACH ROW
                 EXECUTE FUNCTION fn_auditoria_modificacion()', tabla
        );
    END LOOP;
END;
$$;


-- ---------------------------------------------------------------------
--  Comentarios de las columnas de auditoria
-- ---------------------------------------------------------------------
--  Los mismos cuatro comentarios en 31 tablas. Escritos a mano serian
--  124 lineas repetidas que nadie mantendria al dia.
-- ---------------------------------------------------------------------
DO $$
DECLARE
    tabla text;
BEGIN
    FOR tabla IN
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND column_name  = 'usuario_alta'
        ORDER BY table_name
    LOOP
        EXECUTE format('COMMENT ON COLUMN %I.fecha_alta IS %L', tabla,
            'Auditoria: instante de creacion del registro. Lo pone la base de datos por defecto.');

        EXECUTE format('COMMENT ON COLUMN %I.usuario_alta IS %L', tabla,
            'Auditoria: quien creo el registro. Es texto libre y no una FK a la tabla de usuarios a proposito, porque buena parte de las altas las haran procesos automaticos (SISTEMA, IMPORT_TMDB) y una FK obligaria a inventarles usuarios ficticios.');

        EXECUTE format('COMMENT ON COLUMN %I.fecha_modificacion IS %L', tabla,
            'Auditoria: instante de la ultima modificacion. Lo sella el trigger trg_<tabla>_auditoria en cada UPDATE. Nulo mientras el registro no se haya modificado nunca.');

        EXECUTE format('COMMENT ON COLUMN %I.usuario_modificacion IS %L', tabla,
            'Auditoria: quien modifico el registro por ultima vez. Lo escribe la aplicacion, no el trigger: la base de datos no sabe que usuario de la aplicacion hay detras de la conexion.');
    END LOOP;
END;
$$;


-- ---------------------------------------------------------------------
--  Comprobacion
-- ---------------------------------------------------------------------
--  Debe devolver 31 tablas, todas con auditoria y trigger.
--
--    SELECT c.table_name,
--           t.tgname IS NOT NULL AS tiene_trigger
--    FROM   information_schema.columns c
--    LEFT   JOIN pg_trigger t
--           ON t.tgrelid = to_regclass('public.' || c.table_name)
--          AND t.tgname  = 'trg_' || c.table_name || '_auditoria'
--    WHERE  c.table_schema = 'public'
--      AND  c.column_name  = 'usuario_alta'
--    ORDER  BY 1;
-- ---------------------------------------------------------------------
