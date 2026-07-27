package com.medialog.api.mapper;

import com.medialog.api.dto.DatoResponse;
import com.medialog.api.dto.EpisodioResponse;
import com.medialog.api.dto.EpisodioResumenResponse;
import com.medialog.api.model.DatoEpisodio;
import com.medialog.api.model.Episodio;
import com.medialog.api.model.Obra;
import com.medialog.api.model.TipoDatoEpisodio;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Conversion de entidades a DTOs.
 *
 * <p>A mano y no con MapStruct a proposito: la pieza interesante es
 * {@link #extraerValor}, que no es un mapeo campo a campo sino la resolucion de
 * cual de las ocho columnas {@code valor_*} lleva el dato. Un generador no
 * ayuda ahi.
 */
@Component
public class EpisodioMapper {

    public EpisodioResumenResponse aResumen(Episodio episodio) {
        return new EpisodioResumenResponse(
                episodio.getObraId(),
                episodio.getNumero(),
                episodio.getObra().getTitulo());
    }

    public EpisodioResponse aDetalle(Episodio episodio, List<DatoEpisodio> datos) {
        Obra obra = episodio.getObra();
        return new EpisodioResponse(
                episodio.getObraId(),
                episodio.getTemporada().getObraId(),
                episodio.getTemporada().getNumero(),
                episodio.getNumero(),
                obra.getTitulo(),
                obra.getAnio(),
                obra.getPortadaUrl(),
                datos.stream().map(this::aDato).toList());
    }

    public DatoResponse aDato(DatoEpisodio dato) {
        TipoDatoEpisodio tipo = dato.getTipoDato();
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
     * <p>El {@code switch} sobre el tipo del catalogo es la traduccion del
     * CHECK que la base de datos ya impone. Si algun dia se anade un tipo nuevo
     * al enumerado, el compilador obligara a tratarlo aqui: por eso el switch
     * no tiene rama {@code default}.
     */
    private Object extraerValor(DatoEpisodio d) {
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
    private String extraerEtiqueta(DatoEpisodio d) {
        return switch (d.getTipoDato().getTipoDato()) {
            case OPCION -> d.getValorOpcion() == null ? null : d.getValorOpcion().getEtiqueta();
            case IDIOMA -> d.getValorIdioma() == null ? null : d.getValorIdioma().getNombre();
            case PAIS -> d.getValorPais() == null ? null : d.getValorPais().getNombre();
            default -> null;
        };
    }
}
