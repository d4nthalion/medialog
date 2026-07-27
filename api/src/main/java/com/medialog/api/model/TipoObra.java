package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/** LIBRO, PELICULA, SERIE, TEMPORADA o EPISODIO. Discrimina el subtipo de {@link Obra}. */
@Entity
@Table(name = "cfg_tipo_obra")
public class TipoObra extends Auditable {

    /** Codigos estables, usados para localizar la fila sin depender del id. */
    public static final String SERIE = "SERIE";
    public static final String TEMPORADA = "TEMPORADA";
    public static final String EPISODIO = "EPISODIO";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 20)
    private String codigo;

    @Column(nullable = false, length = 50)
    private String nombre;

    public Integer getId() {
        return id;
    }

    public String getCodigo() {
        return codigo;
    }

    public String getNombre() {
        return nombre;
    }
}
