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
 * Valor concreto de un dato de un episodio: la V del EAV.
 *
 * <p>Exactamente UNA de las columnas {@code valor*} esta informada, y cual de
 * ellas lo indica el {@link TipoDatoValor} de su {@link TipoDatoEpisodio}. Un
 * CHECK en la base de datos garantiza esa regla; aqui no se puede expresar.
 *
 * <p>Estan tipadas y no todas en texto por una razon concreta: asi ordenar y
 * filtrar por rango es numerico. En texto, 9 iria despues de 120.
 */
@Entity
@Table(name = "dat_dato_episodio")
public class DatoEpisodio extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "episodio_id", nullable = false)
    private Episodio episodio;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_dato_id", nullable = false)
    private TipoDatoEpisodio tipoDato;

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
    private OpcionDatoEpisodio valorOpcion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "valor_idioma_id")
    private Idioma valorIdioma;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "valor_pais_id")
    private Pais valorPais;

    /** Orden del valor cuando el dato admite varios; 0 cuando es unico. */
    @Column(nullable = false)
    private Short posicion = 0;

    public Long getId() {
        return id;
    }

    public Episodio getEpisodio() {
        return episodio;
    }

    public void setEpisodio(Episodio episodio) {
        this.episodio = episodio;
    }

    public TipoDatoEpisodio getTipoDato() {
        return tipoDato;
    }

    public void setTipoDato(TipoDatoEpisodio tipoDato) {
        this.tipoDato = tipoDato;
    }

    public String getValorTexto() {
        return valorTexto;
    }

    public void setValorTexto(String valorTexto) {
        this.valorTexto = valorTexto;
    }

    public Long getValorEntero() {
        return valorEntero;
    }

    public void setValorEntero(Long valorEntero) {
        this.valorEntero = valorEntero;
    }

    public BigDecimal getValorDecimal() {
        return valorDecimal;
    }

    public void setValorDecimal(BigDecimal valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    public LocalDate getValorFecha() {
        return valorFecha;
    }

    public void setValorFecha(LocalDate valorFecha) {
        this.valorFecha = valorFecha;
    }

    public Boolean getValorBool() {
        return valorBool;
    }

    public void setValorBool(Boolean valorBool) {
        this.valorBool = valorBool;
    }

    public OpcionDatoEpisodio getValorOpcion() {
        return valorOpcion;
    }

    public void setValorOpcion(OpcionDatoEpisodio valorOpcion) {
        this.valorOpcion = valorOpcion;
    }

    public Idioma getValorIdioma() {
        return valorIdioma;
    }

    public void setValorIdioma(Idioma valorIdioma) {
        this.valorIdioma = valorIdioma;
    }

    public Pais getValorPais() {
        return valorPais;
    }

    public void setValorPais(Pais valorPais) {
        this.valorPais = valorPais;
    }

    public Short getPosicion() {
        return posicion;
    }

    public void setPosicion(Short posicion) {
        this.posicion = posicion;
    }
}
