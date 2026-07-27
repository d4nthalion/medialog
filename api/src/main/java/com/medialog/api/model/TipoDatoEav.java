package com.medialog.api.model;

/**
 * Metadato de un dato EAV, comun a los cuatro tipos de obra.
 *
 * <p>Las tablas {@code CFG_TIPO_DATO_*} son una por tipo de obra —esa fue la
 * decision del esquema— pero su forma es identica. Esta interfaz permite que
 * exista UN solo mapeador de datos en vez de cuatro copias del mismo switch.
 */
public interface TipoDatoEav {

    String getCodigo();

    String getNombre();

    String getGrupo();

    String getUnidad();

    TipoDatoValor getTipoDato();

    Short getOrden();
}
