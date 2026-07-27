package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

/**
 * Temporada de una serie. Es tambien una fila de {@link Obra}, de modo que se
 * puede puntuar y resenar por separado.
 *
 * <p>No tiene modelo EAV a proposito: sus campos son fijos y no varian.
 */
@Entity
@Table(name = "dat_temporada")
public class Temporada extends Auditable {

    @Id
    @Column(name = "obra_id")
    private Long obraId;

    /**
     * Clave primaria compartida con {@link Obra}: {@code @MapsId} hace que
     * {@code obraId} tome el valor del id de la obra asociada. Es el patron
     * correcto para el class table inheritance del esquema.
     */
    @MapsId
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "obra_id")
    private Obra obra;

    /**
     * Serie a la que pertenece. Se mapea como identificador y no como
     * asociacion porque la entidad Serie todavia no existe; cuando se cree,
     * esto pasa a un {@code @ManyToOne}.
     */
    @Column(name = "serie_id", nullable = false)
    private Long serieId;

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

    public Long getSerieId() {
        return serieId;
    }

    public void setSerieId(Long serieId) {
        this.serieId = serieId;
    }

    public Short getNumero() {
        return numero;
    }

    public void setNumero(Short numero) {
        this.numero = numero;
    }
}
