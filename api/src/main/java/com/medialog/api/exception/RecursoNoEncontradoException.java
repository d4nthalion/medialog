package com.medialog.api.exception;

/** Lanzada cuando se pide un recurso que no existe. El handler la traduce a 404. */
public class RecursoNoEncontradoException extends RuntimeException {

    public RecursoNoEncontradoException(String mensaje) {
        super(mensaje);
    }

    public static RecursoNoEncontradoException de(String recurso, Object id) {
        return new RecursoNoEncontradoException("No existe %s con id %s".formatted(recurso, id));
    }
}
