package com.medialog.api.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Alta y modificacion de una serie: solo sus campos fijos.
 *
 * <p>Estado, generos, paises y fechas son datos EAV y se gestionan por su
 * propio endpoint, porque su validacion depende de CFG_TIPO_DATO_SERIE y no de
 * anotaciones.
 */
public record SerieRequest(

        @NotBlank(message = "el titulo es obligatorio")
        @Size(max = 500)
        String titulo,

        @Min(value = 1000, message = "ano fuera de rango")
        @Max(value = 2200, message = "ano fuera de rango")
        Short anio,

        @Size(max = 2000)
        String portadaUrl) {
}
