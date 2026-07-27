package com.medialog.api.mapper;

import com.medialog.api.dto.EpisodioResumenResponse;
import com.medialog.api.dto.TemporadaResponse;
import com.medialog.api.model.Episodio;
import com.medialog.api.model.Obra;
import com.medialog.api.model.Temporada;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class TemporadaMapper {

    private final EpisodioMapper episodioMapper;

    public TemporadaMapper(EpisodioMapper episodioMapper) {
        this.episodioMapper = episodioMapper;
    }

    public TemporadaResponse aDetalle(Temporada temporada, List<Episodio> episodios) {
        Obra obra = temporada.getObra();
        return new TemporadaResponse(
                temporada.getObraId(),
                temporada.getSerie().getObraId(),
                temporada.getSerie().getObra().getTitulo(),
                temporada.getNumero(),
                obra.getTitulo(),
                obra.getAnio(),
                obra.getPortadaUrl(),
                episodios.stream().map(episodioMapper::aResumen).toList());
    }

    public List<EpisodioResumenResponse> aResumenEpisodios(List<Episodio> episodios) {
        return episodios.stream().map(episodioMapper::aResumen).toList();
    }
}
