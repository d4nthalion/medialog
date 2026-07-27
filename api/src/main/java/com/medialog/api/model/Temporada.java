package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

/**
 * Temporada de una serie. Es tambien una fila de {@link Obra}, de modo que se
 * puede puntuar y resenar por separado sin ningun mecanismo adicional.
 *
 * <p>No tiene modelo EAV a proposito: sus campos son fijos y no varian entre
 * series.
 */
@Entity
@Table(name = "dat_temporada")
public class Temporada extends Auditable {

    @Id
    @Column(name = "obra_id")
    private Long obraId;

    /**
     * Clave primaria compartida con {@link Obra}: {@code @MapsId} hace que
     * {@code obraId} tome el valor del id de la obra asociada. Es el patron del
     * class table inheritance del esquema.
     */
    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "obra_id")
    private Obra obra;

    /**
     * Apunta a {@link Serie} y no a {@link Obra} a proposito: asi es imposible
     * colgar una temporada de un libro.
     */
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "serie_id", nullable = false)
    private Serie serie;

    /** Se admite 0 para las temporadas de especiales, que es como las numera TMDB. */
    @Column(nullable = false)
    private Short numero;

    public Long getObraId() {
        return obraId;
    }

    public Obra getObra() {
        return obra;
    }

    public void setObra(Obra obra) {
        this.obra = obra;
    }

    public Serie getSerie() {
        return serie;
    }

    public void setSerie(Serie serie) {
        this.serie = serie;
    }

    public Short getNumero() {
        return numero;
    }

    public void setNumero(Short numero) {
        this.numero = numero;
    }
}
