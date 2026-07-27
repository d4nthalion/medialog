package com.medialog.api.dto;

import java.util.List;

/** Ficha completa de un episodio: sus campos fijos mas sus datos EAV. */
public record EpisodioResponse(
        Long id,
        Long temporadaId,
        Short temporadaNumero,
        Short numero,
        String titulo,
        Short anio,
        String portadaUrl,
        List<DatoResponse> datos) {
}
