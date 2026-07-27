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
 * Supertipo de toda obra catalogable: libro, pelicula, serie, temporada o
 * episodio.
 *
 * <p>Los subtipos ({@link Episodio}, {@link Temporada}, y los que falten)
 * COMPARTEN su clave primaria con esta tabla. Por eso una resena, un rating o
 * un elemento de lista pueden tener una unica FK hacia "cualquier obra".
 */
@Entity
@Table(name = "dat_obra")
public class Obra extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tipo_obra_id", nullable = false)
    private TipoObra tipoObra;

    @Column(nullable = false)
    private String titulo;

    /**
     * Columna GENERADA en la base de datos a partir del titulo. Solo lectura:
     * escribirla desde aqui provocaria un error de PostgreSQL.
     */
    @Column(name = "titulo_normalizado", insertable = false, updatable = false)
    private String tituloNormalizado;

    private Short anio;

    @Column(name = "portada_url")
    private String portadaUrl;

    public Long getId() {
        return id;
    }

    public TipoObra getTipoObra() {
        return tipoObra;
    }

    public void setTipoObra(TipoObra tipoObra) {
        this.tipoObra = tipoObra;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getTituloNormalizado() {
        return tituloNormalizado;
    }

    public Short getAnio() {
        return anio;
    }

    public void setAnio(Short anio) {
        this.anio = anio;
    }

    public String getPortadaUrl() {
        return portadaUrl;
    }

    public void setPortadaUrl(String portadaUrl) {
        this.portadaUrl = portadaUrl;
    }
}
