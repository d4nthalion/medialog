package com.medialog.api.mapper;

import com.medialog.api.dto.EpisodioResponse;
import com.medialog.api.dto.EpisodioResumenResponse;
import com.medialog.api.model.DatoEpisodio;
import com.medialog.api.model.Episodio;
import com.medialog.api.model.Obra;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class EpisodioMapper {

    private final DatoMapper datoMapper;

    public EpisodioMapper(DatoMapper datoMapper) {
        this.datoMapper = datoMapper;
    }

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
                datoMapper.aDtos(datos));
    }
}
