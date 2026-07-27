package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/** Define QUE datos puede tener una serie: es el esquema de su EAV. */
@Entity
@Table(name = "cfg_tipo_dato_serie")
public class TipoDatoSerie extends Auditable implements TipoDatoEav {

    /** Dato que decide si hay que avisar de episodios nuevos a quien la sigue. */
    public static final String ESTADO = "estado";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 40)
    private String codigo;

    @Column(nullable = false, length = 80)
    private String nombre;

    /** Enumerado nativo de PostgreSQL; ver la nota en {@link TipoDatoEpisodio}. */
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "tipo_dato", nullable = false)
    private TipoDatoValor tipoDato;

    @Column(name = "es_multiple", nullable = false)
    private boolean esMultiple;

    @Column(nullable = false)
    private boolean obligatorio;

    @Column(length = 20)
    private String unidad;

    @Column(length = 40)
    private String grupo;

    @Column(nullable = false)
    private Short orden;

    public Integer getId() {
        return id;
    }

    @Override
    public String getCodigo() {
        return codigo;
    }

    @Override
    public String getNombre() {
        return nombre;
    }

    @Override
    public TipoDatoValor getTipoDato() {
        return tipoDato;
    }

    public boolean isEsMultiple() {
        return esMultiple;
    }

    public boolean isObligatorio() {
        return obligatorio;
    }

    @Override
    public String getUnidad() {
        return unidad;
    }

    @Override
    public String getGrupo() {
        return grupo;
    }

    @Override
    public Short getOrden() {
        return orden;
    }
}
