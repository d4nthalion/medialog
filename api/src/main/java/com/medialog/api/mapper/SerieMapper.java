package com.medialog.api.mapper;

import com.medialog.api.dto.SerieResponse;
import com.medialog.api.dto.SerieResumenResponse;
import com.medialog.api.dto.TemporadaResumenResponse;
import com.medialog.api.model.DatoSerie;
import com.medialog.api.model.Obra;
import com.medialog.api.model.Serie;
import com.medialog.api.model.Temporada;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class SerieMapper {

    private final DatoMapper datoMapper;

    public SerieMapper(DatoMapper datoMapper) {
        this.datoMapper = datoMapper;
    }

    public SerieResumenResponse aResumen(Serie serie) {
        Obra obra = serie.getObra();
        return new SerieResumenResponse(
                serie.getObraId(), obra.getTitulo(), obra.getAnio(), obra.getPortadaUrl());
    }

    public SerieResponse aDetalle(Serie serie, List<DatoSerie> datos, List<Temporada> temporadas) {
        Obra obra = serie.getObra();
        return new SerieResponse(
                serie.getObraId(),
                obra.getTitulo(),
                obra.getAnio(),
                obra.getPortadaUrl(),
                temporadas.size(),
                datoMapper.aDtos(datos),
                temporadas.stream().map(this::aTemporadaResumen).toList());
    }

    public TemporadaResumenResponse aTemporadaResumen(Temporada temporada) {
        return new TemporadaResumenResponse(
                temporada.getObraId(), temporada.getNumero(), temporada.getObra().getTitulo());
    }
}
