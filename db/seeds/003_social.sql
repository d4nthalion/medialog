-- =====================================================================
--  SEED 003 — Catalogos del dominio social
-- =====================================================================
--  Idempotente: se puede reejecutar sin duplicar filas.
-- =====================================================================

-- ---------------------------------------------------------------------
--  Roles de usuario
-- ---------------------------------------------------------------------
INSERT INTO CFG_ROL_USUARIO (codigo, nombre, usuario_alta) VALUES
    ('USUARIO',   'Usuario',   'SISTEMA'),
    ('MODERADOR', 'Moderador', 'SISTEMA'),
    ('ADMIN',     'Administrador', 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;


-- ---------------------------------------------------------------------
--  Estados de una obra para un usuario
-- ---------------------------------------------------------------------
--  SIGUIENDO es especifico de series: distingue "la veo semana a
--  semana" de "la tengo empezada y parada". Sin ese matiz no se puede
--  avisar de episodios nuevos solo a quien lo espera.
-- ---------------------------------------------------------------------
INSERT INTO CFG_ESTADO_USUARIO_OBRA (codigo, nombre, orden, usuario_alta) VALUES
    ('PENDIENTE',  'Pendiente',  1, 'SISTEMA'),
    ('EN_CURSO',   'En curso',   2, 'SISTEMA'),
    ('SIGUIENDO',  'Siguiendo',  3, 'SISTEMA'),
    ('COMPLETADA', 'Completada', 4, 'SISTEMA'),
    ('ABANDONADA', 'Abandonada', 5, 'SISTEMA')
ON CONFLICT (codigo) DO NOTHING;
