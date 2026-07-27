package com.medialog.api.dto;

/**
 * Version ligera para listados.
 *
 * <p>No incluye los datos EAV a proposito: una lista de episodios de una
 * temporada se resuelve leyendo solo dat_episodio y dat_obra, sin tocar la
 * tabla de valores. Es lo que evita que el EAV penalice los listados.
 */
public record EpisodioResumenResponse(
        Long id,
        Short numero,
        String titulo) {
}
