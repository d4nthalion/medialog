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
 * Vocabulario cerrado de los datos de tipo {@code OPCION} de serie: generos,
 * estado de emision, tipo de serie, clasificacion por edades.
 *
 * <p>A diferencia del de episodio, este SI esta poblado: ver
 * {@code db/seeds/002_tipos_dato.sql}.
 */
@Entity
@Table(name = "cfg_opcion_dato_serie")
public class OpcionDatoSerie extends Auditable implements OpcionEav {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_dato_id", nullable = false)
    private TipoDatoSerie tipoDato;

    @Column(nullable = false, length = 40)
    private String codigo;

    @Column(nullable = false, length = 80)
    private String etiqueta;

    @Column(nullable = false)
    private Short orden;

    public Integer getId() {
        return id;
    }

    public TipoDatoSerie getTipoDato() {
        return tipoDato;
    }

    @Override
    public String getCodigo() {
        return codigo;
    }

    @Override
    public String getEtiqueta() {
        return etiqueta;
    }

    public Short getOrden() {
        return orden;
    }
}
