package com.medialog.api.model;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;

import java.time.OffsetDateTime;

/**
 * Las cuatro columnas de auditoria que llevan las 45 tablas del esquema.
 *
 * <p>{@code fechaAlta} y {@code fechaModificacion} son de solo lectura: la
 * primera la pone el DEFAULT de la tabla y la segunda un trigger. Marcarlas
 * {@code insertable=false} evita que Hibernate intente escribirlas y pise el
 * valor del servidor.
 *
 * <p>{@code usuarioModificacion} si lo escribe la aplicacion: la base de datos
 * no sabe que usuario hay detras de la conexion.
 */
@MappedSuperclass
public abstract class Auditable {

    @Column(name = "fecha_alta", insertable = false, updatable = false)
    private OffsetDateTime fechaAlta;

    @Column(name = "usuario_alta", nullable = false, updatable = false, length = 60)
    private String usuarioAlta;

    @Column(name = "fecha_modificacion", insertable = false, updatable = false)
    private OffsetDateTime fechaModificacion;

    @Column(name = "usuario_modificacion", length = 60)
    private String usuarioModificacion;

    public OffsetDateTime getFechaAlta() {
        return fechaAlta;
    }

    public String getUsuarioAlta() {
        return usuarioAlta;
    }

    public void setUsuarioAlta(String usuarioAlta) {
        this.usuarioAlta = usuarioAlta;
    }

    public OffsetDateTime getFechaModificacion() {
        return fechaModificacion;
    }

    public String getUsuarioModificacion() {
        return usuarioModificacion;
    }

    public void setUsuarioModificacion(String usuarioModificacion) {
        this.usuarioModificacion = usuarioModificacion;
    }
}
