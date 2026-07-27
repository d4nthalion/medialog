package com.medialog.api.dto;

/** Version ligera, usada dentro de la ficha de una serie. */
public record TemporadaResumenResponse(
        Long id,
        Short numero,
        String titulo) {
}
