package com.medialog.api.exception;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

/**
 * Traduce excepciones a respuestas HTTP en formato ProblemDetail (RFC 9457).
 *
 * <p>Centralizarlo aqui evita que cada controlador repita el mismo try/catch.
 */
@RestControllerAdvice
public class ManejadorGlobalErrores {

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ProblemDetail noEncontrado(RecursoNoEncontradoException ex) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
        p.setTitle("Recurso no encontrado");
        return p;
    }

    /** Fallos de @Valid: se devuelve el detalle campo a campo. */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ProblemDetail validacion(MethodArgumentNotValidException ex) {
        Map<String, String> errores = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
                .forEach(e -> errores.put(e.getField(), e.getDefaultMessage()));

        ProblemDetail p = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        p.setTitle("Datos invalidos");
        p.setProperty("errores", errores);
        return p;
    }

    /**
     * Restricciones de la base de datos. La mas probable aqui es el UNIQUE
     * (temporada_id, numero): dos episodios con el mismo numero en la misma
     * temporada. 409 y no 400 porque la peticion es valida en si misma; lo que
     * choca es el estado actual de los datos.
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public ProblemDetail integridad(DataIntegrityViolationException ex) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(
                HttpStatus.CONFLICT,
                "La operacion viola una restriccion de integridad. "
                        + "Comprueba que no exista ya un episodio con ese numero en la temporada.");
        p.setTitle("Conflicto de integridad");
        return p;
    }
}
