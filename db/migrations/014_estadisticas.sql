-- =====================================================================
--  014 — Agregados precalculados por obra
-- =====================================================================
--  Aqui se hace una excepcion a la regla de "los datos derivados no se
--  almacenan", y conviene entender por que.
--
--  Con el numero de temporadas la regla se mantiene: es un COUNT sobre
--  veinte filas, sale gratis y guardarlo solo crea una segunda verdad.
--
--  La nota media es distinta. Es un AVG sobre potencialmente millones
--  de valoraciones y se pinta en CADA tarjeta de CADA parrilla.
--  Calcularla al vuelo no escala.
--
--  La diferencia con lo que se rechazo: va en TABLA APARTE y no como
--  columna de DAT_OBRA. Asi queda explicito que es una cache, con su
--  fecha_calculo visible, y nadie la confunde con una propiedad de la
--  obra. Si esta desactualizada se nota, y se puede regenerar entera.
-- =====================================================================

CREATE TABLE DAT_ESTADISTICA_OBRA (
    obra_id               bigint       PRIMARY KEY REFERENCES DAT_OBRA(id) ON DELETE CASCADE,
    num_valoraciones      int          NOT NULL DEFAULT 0,
    nota_media            numeric(4,2),
    num_resenas           int          NOT NULL DEFAULT 0,
    num_registros         int          NOT NULL DEFAULT 0,
    num_pendientes        int          NOT NULL DEFAULT 0,
    fecha_calculo         timestamptz  NOT NULL DEFAULT now(),
    fecha_alta            timestamptz  NOT NULL DEFAULT now(),
    usuario_alta          varchar(60)  NOT NULL,
    fecha_modificacion    timestamptz,
    usuario_modificacion  varchar(60)
);

COMMENT ON TABLE DAT_ESTADISTICA_OBRA IS
    'Cache de agregados por obra. NO es fuente de verdad: la verdad esta en DAT_VALORACION, DAT_RESENA, DAT_REGISTRO y DAT_ESTADO_USUARIO_OBRA. Se puede borrar entera y reconstruir con fn_refrescar_estadisticas().';

COMMENT ON COLUMN DAT_ESTADISTICA_OBRA.num_valoraciones IS
    'Cuantos usuarios han puntuado la obra. Necesario ademas de la media: una obra con nota 10 y dos votos no debe competir con una de 8,5 y diez mil.';
COMMENT ON COLUMN DAT_ESTADISTICA_OBRA.nota_media IS
    'Media aritmetica de las notas, en la misma escala de 1 a 10 que DAT_VALORACION. Nula si nadie la ha votado. Para ordenar "las mejores" no basta con esta columna: hace falta exigir un minimo de votos, o usar una media ponderada bayesiana.';
COMMENT ON COLUMN DAT_ESTADISTICA_OBRA.num_pendientes IS
    'Cuantos usuarios la tienen en estado PENDIENTE. Es la medida de expectativa, util para obras aun no estrenadas.';
COMMENT ON COLUMN DAT_ESTADISTICA_OBRA.fecha_calculo IS
    'Cuando se recalculo por ultima vez. Expuesto a proposito: si la cifra se ve rara, lo primero es mirar aqui.';

-- Ordenaciones de descubrimiento: mejor valoradas, mas populares.
CREATE INDEX idx_estadistica_nota
    ON DAT_ESTADISTICA_OBRA (nota_media DESC NULLS LAST, num_valoraciones DESC);

CREATE INDEX idx_estadistica_popularidad
    ON DAT_ESTADISTICA_OBRA (num_registros DESC);


-- ---------------------------------------------------------------------
--  fn_refrescar_estadisticas — recalculo completo
-- ---------------------------------------------------------------------
--  Recorre todas las obras con actividad y reescribe sus agregados.
--
--  Pensado para ejecutarse periodicamente (cron, o un trabajo de la
--  API). NO es un trigger a proposito: un trigger por cada voto pondria
--  todas las escrituras de una obra popular a competir por la misma
--  fila, y la contencion seria peor que el ahorro.
--
--  Si algun dia se necesita en tiempo real, la via es refrescar solo la
--  obra afectada llamando a esta misma logica con un filtro.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_refrescar_estadisticas()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    filas integer;
BEGIN
    INSERT INTO DAT_ESTADISTICA_OBRA AS e (
        obra_id, num_valoraciones, nota_media, num_resenas,
        num_registros, num_pendientes, fecha_calculo, usuario_alta
    )
    SELECT o.id,
           coalesce(v.total, 0),
           v.media,
           coalesce(r.total, 0),
           coalesce(g.total, 0),
           coalesce(p.total, 0),
           now(),
           'SISTEMA'
    FROM   DAT_OBRA o
    LEFT   JOIN (SELECT obra_id, count(*) AS total, round(avg(nota), 2) AS media
                 FROM DAT_VALORACION GROUP BY obra_id) v ON v.obra_id = o.id
    LEFT   JOIN (SELECT obra_id, count(*) AS total
                 FROM DAT_RESENA WHERE es_privado = false GROUP BY obra_id) r ON r.obra_id = o.id
    LEFT   JOIN (SELECT obra_id, count(*) AS total
                 FROM DAT_REGISTRO WHERE es_privado = false GROUP BY obra_id) g ON g.obra_id = o.id
    LEFT   JOIN (SELECT eu.obra_id, count(*) AS total
                 FROM DAT_ESTADO_USUARIO_OBRA eu
                 JOIN CFG_ESTADO_USUARIO_OBRA ce ON ce.id = eu.estado_id
                 WHERE ce.codigo = 'PENDIENTE'
                 GROUP BY eu.obra_id) p ON p.obra_id = o.id
    ON CONFLICT (obra_id) DO UPDATE SET
        num_valoraciones     = EXCLUDED.num_valoraciones,
        nota_media           = EXCLUDED.nota_media,
        num_resenas          = EXCLUDED.num_resenas,
        num_registros        = EXCLUDED.num_registros,
        num_pendientes       = EXCLUDED.num_pendientes,
        fecha_calculo        = EXCLUDED.fecha_calculo,
        fecha_modificacion   = now(),
        usuario_modificacion = 'SISTEMA';

    GET DIAGNOSTICS filas = ROW_COUNT;
    RETURN filas;
END;
$$;

COMMENT ON FUNCTION fn_refrescar_estadisticas() IS
    'Recalcula DAT_ESTADISTICA_OBRA para todas las obras y devuelve cuantas filas ha escrito. Ejecutar periodicamente. Las resenas y registros privados no se cuentan.';
