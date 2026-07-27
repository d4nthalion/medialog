package com.medialog.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

/** Alta y modificacion de una temporada. */
public record TemporadaRequest(

        @NotNull(message = "la serie es obligatoria")
        Long serieId,

        @NotNull(message = "el numero de temporada es obligatorio")
        @PositiveOrZero(message = "el numero no puede ser negativo")
        Short numero,

        @NotBlank(message = "el titulo es obligatorio")
        @Size(max = 500)
        String titulo,

        @Min(value = 1000, message = "ano fuera de rango")
        @Max(value = 2200, message = "ano fuera de rango")
        Short anio,

        @Size(max = 2000)
        String portadaUrl) {
}
