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
 * Episodio de una temporada.
 *
 * <p>Comparte clave primaria con {@link Obra}, asi que puntuarlo o marcarlo
 * como visto no necesita ninguna tabla adicional: es un registro mas sobre una
 * obra cualquiera.
 *
 * <p>El titulo NO esta aqui, esta en la obra. Los datos variables (sinopsis,
 * duracion, fecha de emision) estan en {@link DatoEpisodio}.
 */
@Entity
@Table(name = "dat_episodio")
public class Episodio extends Auditable {

    @Id
    @Column(name = "obra_id")
    private Long obraId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "obra_id")
    private Obra obra;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "temporada_id", nullable = false)
    private Temporada temporada;

    /** Numero dentro de su temporada. La numeracion continua de toda la serie
     *  va, si se necesita, en el dato EAV {@code numero_absoluto}. */
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

    public Temporada getTemporada() {
        return temporada;
    }

    public void setTemporada(Temporada temporada) {
        this.temporada = temporada;
    }

    public Short getNumero() {
        return numero;
    }

    public void setNumero(Short numero) {
        this.numero = numero;
    }
}
