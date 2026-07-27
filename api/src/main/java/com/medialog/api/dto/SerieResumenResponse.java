package com.medialog.api.dto;

/**
 * Version ligera para parrillas y buscadores.
 *
 * <p>No toca la tabla de datos EAV: titulo, ano y portada estan desnormalizados
 * en DAT_OBRA justo para esto. Es lo que hace que un listado no pague el precio
 * del modelo EAV.
 */
public record SerieResumenResponse(
        Long id,
        String titulo,
        Short anio,
        String portadaUrl) {
}
