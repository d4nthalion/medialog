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

/**
 * Define QUE datos puede tener un episodio: es el esquema del EAV.
 *
 * <p>La API construye los formularios leyendo esta tabla, en lugar de tenerlos
 * escritos en el codigo. Anadir un dato nuevo al catalogo no deberia obligar a
 * tocar Java.
 */
@Entity
@Table(name = "cfg_tipo_dato_episodio")
public class TipoDatoEpisodio extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 40)
    private String codigo;

    @Column(nullable = false, length = 80)
    private String nombre;

    /**
     * {@code NAMED_ENUM} es lo que hace que Hibernate trate la columna como el
     * tipo enumerado nativo {@code tipo_dato_enum} de PostgreSQL. Sin esto
     * intentaria enviarla como varchar y el servidor rechazaria el tipo.
     */
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

    public String getCodigo() {
        return codigo;
    }

    public String getNombre() {
        return nombre;
    }

    public TipoDatoValor getTipoDato() {
        return tipoDato;
    }

    public boolean isEsMultiple() {
        return esMultiple;
    }

    public boolean isObligatorio() {
        return obligatorio;
    }

    public String getUnidad() {
        return unidad;
    }

    public String getGrupo() {
        return grupo;
    }

    public Short getOrden() {
        return orden;
    }
}
