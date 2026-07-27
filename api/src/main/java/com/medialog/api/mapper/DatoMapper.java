package com.medialog.api.mapper;

import com.medialog.api.dto.DatoResponse;
import com.medialog.api.model.DatoEav;
import com.medialog.api.model.TipoDatoEav;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Convierte valores EAV a DTO, para CUALQUIER tipo de obra.
 *
 * <p>Es la unica pieza del proyecto que sabe que columna {@code valor_*} lleva
 * cada tipo de dato. Sin esta abstraccion habria cuatro copias del mismo
 * switch, y anadir un tipo al enumerado obligaria a tocar las cuatro.
 */
@Component
public class DatoMapper {

    public List<DatoResponse> aDtos(List<? extends DatoEav> datos) {
        return datos.stream().map(this::aDto).toList();
    }

    public DatoResponse aDto(DatoEav dato) {
        TipoDatoEav tipo = dato.getTipoDato();
        return new DatoResponse(
                tipo.getCodigo(),
                tipo.getNombre(),
                tipo.getGrupo(),
                tipo.getUnidad(),
                tipo.getTipoDato(),
                extraerValor(dato),
                extraerEtiqueta(dato),
                dato.getPosicion());
    }

    /**
     * Devuelve el contenido de la unica columna {@code valor_*} informada.
     *
     * <p>Es la traduccion del CHECK que la base de datos ya impone. Sin rama
     * {@code default} a proposito: si se anade un tipo al enumerado, el
     * compilador obliga a tratarlo aqui en vez de devolver null en produccion.
     */
    private Object extraerValor(DatoEav d) {
        return switch (d.getTipoDato().getTipoDato()) {
            case TEXTO, TEXTO_LARGO -> d.getValorTexto();
            case ENTERO -> d.getValorEntero();
            case DECIMAL -> d.getValorDecimal();
            case FECHA -> d.getValorFecha();
            case BOOL -> d.getValorBool();
            case OPCION -> d.getValorOpcion() == null ? null : d.getValorOpcion().getCodigo();
            case IDIOMA -> d.getValorIdioma() == null ? null : d.getValorIdioma().getCodigoIso();
            case PAIS -> d.getValorPais() == null ? null : d.getValorPais().getCodigoIso();
        };
    }

    /** Texto legible cuando el valor es una referencia; null en el resto. */
    private String extraerEtiqueta(DatoEav d) {
        return switch (d.getTipoDato().getTipoDato()) {
            case OPCION -> d.getValorOpcion() == null ? null : d.getValorOpcion().getEtiqueta();
            case IDIOMA -> d.getValorIdioma() == null ? null : d.getValorIdioma().getNombre();
            case PAIS -> d.getValorPais() == null ? null : d.getValorPais().getNombre();
            default -> null;
        };
    }
}
