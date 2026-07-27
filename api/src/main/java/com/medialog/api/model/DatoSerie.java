package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Valor concreto de un dato de una serie: la V del EAV.
 *
 * <p>Exactamente UNA de las columnas {@code valor*} esta informada, y cual lo
 * dice el {@link TipoDatoValor} de su {@link TipoDatoSerie}. Un CHECK en la
 * base de datos garantiza esa regla.
 */
@Entity
@Table(name = "dat_dato_serie")
public class DatoSerie extends Auditable implements DatoEav {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_id", nullable = false)
    private Serie serie;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_dato_id", nullable = false)
    private TipoDatoSerie tipoDato;

    @Column(name = "valor_texto")
    private String valorTexto;

    @Column(name = "valor_entero")
    private Long valorEntero;

    @Column(name = "valor_decimal")
    private BigDecimal valorDecimal;

    @Column(name = "valor_fecha")
    private LocalDate valorFecha;

    @Column(name = "valor_bool")
    private Boolean valorBool;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "valor_opcion_id")
    private OpcionDatoSerie valorOpcion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "valor_idioma_id")
    private Idioma valorIdioma;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "valor_pais_id")
    private Pais valorPais;

    @Column(nullable = false)
    private Short posicion = 0;

    public Long getId() {
        return id;
    }

    public Serie getSerie() {
        return serie;
    }

    public void setSerie(Serie serie) {
        this.serie = serie;
    }

    @Override
    public TipoDatoSerie getTipoDato() {
        return tipoDato;
    }

    public void setTipoDato(TipoDatoSerie tipoDato) {
        this.tipoDato = tipoDato;
    }

    @Override
    public String getValorTexto() {
        return valorTexto;
    }

    public void setValorTexto(String valorTexto) {
        this.valorTexto = valorTexto;
    }

    @Override
    public Long getValorEntero() {
        return valorEntero;
    }

    public void setValorEntero(Long valorEntero) {
        this.valorEntero = valorEntero;
    }

    @Override
    public BigDecimal getValorDecimal() {
        return valorDecimal;
    }

    public void setValorDecimal(BigDecimal valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    @Override
    public LocalDate getValorFecha() {
        return valorFecha;
    }

    public void setValorFecha(LocalDate valorFecha) {
        this.valorFecha = valorFecha;
    }

    @Override
    public Boolean getValorBool() {
        return valorBool;
    }

    public void setValorBool(Boolean valorBool) {
        this.valorBool = valorBool;
    }

    @Override
    public OpcionDatoSerie getValorOpcion() {
        return valorOpcion;
    }

    public void setValorOpcion(OpcionDatoSerie valorOpcion) {
        this.valorOpcion = valorOpcion;
    }

    @Override
    public Idioma getValorIdioma() {
        return valorIdioma;
    }

    public void setValorIdioma(Idioma valorIdioma) {
        this.valorIdioma = valorIdioma;
    }

    @Override
    public Pais getValorPais() {
        return valorPais;
    }

    public void setValorPais(Pais valorPais) {
        this.valorPais = valorPais;
    }

    @Override
    public Short getPosicion() {
        return posicion;
    }

    public void setPosicion(Short posicion) {
        this.posicion = posicion;
    }
}
