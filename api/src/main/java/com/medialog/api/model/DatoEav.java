package com.medialog.api.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Valor EAV, comun a las tablas {@code DAT_DATO_*}.
 *
 * <p>Las entidades concretas la implementan sin cambiar ni un metodo: sus
 * getters ya devuelven subtipos de los declarados aqui, y Java admite el
 * retorno covariante. El unico coste de esta abstraccion es el {@code
 * implements}.
 */
public interface DatoEav {

    TipoDatoEav getTipoDato();

    String getValorTexto();

    Long getValorEntero();

    BigDecimal getValorDecimal();

    LocalDate getValorFecha();

    Boolean getValorBool();

    OpcionEav getValorOpcion();

    Idioma getValorIdioma();

    Pais getValorPais();

    Short getPosicion();
}
