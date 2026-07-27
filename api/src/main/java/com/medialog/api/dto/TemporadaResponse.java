package com.medialog.api.dto;

import java.util.List;

/** Ficha de una temporada, con sus episodios. */
public record TemporadaResponse(
        Long id,
        Long serieId,
        String serieTitulo,
        Short numero,
        String titulo,
        Short anio,
        String portadaUrl,
        List<EpisodioResumenResponse> episodios) {
}
