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

/**
 * Vocabulario cerrado de los datos de tipo {@code OPCION}.
 *
 * <p>Hoy esta vacia para episodios: ninguno de sus datos es de tipo OPCION. La
 * tabla existe para que el patron sea identico en los cuatro tipos de obra.
 */
@Entity
@Table(name = "cfg_opcion_dato_episodio")
public class OpcionDatoEpisodio extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_dato_id", nullable = false)
    private TipoDatoEpisodio tipoDato;

    @Column(nullable = false, length = 40)
    private String codigo;

    @Column(nullable = false, length = 80)
    private String etiqueta;

    @Column(nullable = false)
    private Short orden;

    public Integer getId() {
        return id;
    }

    public TipoDatoEpisodio getTipoDato() {
        return tipoDato;
    }

    public String getCodigo() {
        return codigo;
    }

    public String getEtiqueta() {
        return etiqueta;
    }

    public Short getOrden() {
        return orden;
    }
}
