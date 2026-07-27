package com.medialog.api.dto;

import java.util.List;

/**
 * Ficha completa de una serie: campos fijos, datos EAV y sus temporadas.
 *
 * <p>{@code numTemporadas} se cuenta, no se almacena. Es el ejemplo de dato
 * derivado que el esquema decide no guardar: un COUNT sobre veinte filas es
 * gratis, y una columna desnormalizada acabaria desincronizandose.
 */
public record SerieResponse(
        Long id,
        String titulo,
        Short anio,
        String portadaUrl,
        int numTemporadas,
        List<DatoResponse> datos,
        List<TemporadaResumenResponse> temporadas) {
}
