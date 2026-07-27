package com.medialog.api.model;

/**
 * Espejo del tipo enumerado {@code tipo_dato_enum} de PostgreSQL.
 *
 * <p>Indica cual de las columnas {@code valor_*} de {@code DAT_DATO_*} lleva
 * el dato. Las constantes deben llamarse igual que en la base de datos.
 */
public enum TipoDatoValor {
    TEXTO,
    TEXTO_LARGO,
    ENTERO,
    DECIMAL,
    FECHA,
    BOOL,
    OPCION,
    IDIOMA,
    PAIS
}
