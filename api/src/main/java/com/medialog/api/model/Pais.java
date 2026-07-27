package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** Catalogo ISO 3166, compartido por los cuatro modelos EAV. */
@Entity
@Table(name = "cfg_pais")
public class Pais extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "codigo_iso", nullable = false, length = 2)
    private String codigoIso;

    @Column(nullable = false, length = 80)
    private String nombre;

    public Integer getId() {
        return id;
    }

    public String getCodigoIso() {
        return codigoIso;
    }

    public String getNombre() {
        return nombre;
    }
}
