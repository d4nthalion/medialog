package com.medialog.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Alta y modificacion de un episodio.
 *
 * <p>Solo los campos fijos. Los datos EAV (sinopsis, duracion, fecha de
 * emision) se gestionan por su propio endpoint, porque su validacion depende
 * de CFG_TIPO_DATO_EPISODIO y no de anotaciones.
 */
public record EpisodioRequest(
        @NotNull(message = "la temporada es obligatoria")
        Long temporadaId,

        @NotNull(message = "el numero de episodio es obligatorio")
        @Min(value = 1, message = "el numero debe ser mayor que cero")
        Short numero,

        @NotBlank(message = "el titulo es obligatorio")
        @Size(max = 500)
        String titulo,

        Short anio,

        @Size(max = 2000)
        String portadaUrl) {
}
