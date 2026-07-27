package com.medialog.api.dto;

import com.medialog.api.model.TipoDatoValor;

/**
 * Un dato EAV ya resuelto, listo para pintar.
 *
 * <p>Esta es la forma generica de la API: el consumidor recibe una LISTA de
 * datos con su metadato, no campos con nombre fijo. Es lo que permite anadir un
 * atributo al catalogo sin tocar ni una linea de Java ni de frontend, que es la
 * razon de ser del modelo EAV.
 *
 * @param valor    valor en bruto, ya tipado: String, Long, BigDecimal,
 *                 LocalDate, Boolean, o el codigo cuando es una referencia
 * @param etiqueta texto legible cuando el valor es una referencia (opcion,
 *                 idioma o pais); null en el resto de casos
 */
public record DatoResponse(
        String codigo,
        String nombre,
        String grupo,
        String unidad,
        TipoDatoValor tipo,
        Object valor,
        String etiqueta,
        Short posicion) {
}
