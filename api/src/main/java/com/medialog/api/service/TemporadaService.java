package com.medialog.api.service;

import com.medialog.api.dto.TemporadaRequest;
import com.medialog.api.dto.TemporadaResponse;
import com.medialog.api.dto.TemporadaResumenResponse;
import com.medialog.api.exception.RecursoNoEncontradoException;
import com.medialog.api.mapper.SerieMapper;
import com.medialog.api.mapper.TemporadaMapper;
import com.medialog.api.model.Obra;
import com.medialog.api.model.Serie;
import com.medialog.api.model.Temporada;
import com.medialog.api.model.TipoObra;
import com.medialog.api.repository.EpisodioRepository;
import com.medialog.api.repository.ObraRepository;
import com.medialog.api.repository.SerieRepository;
import com.medialog.api.repository.TemporadaRepository;
import com.medialog.api.repository.TipoObraRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TemporadaService {

    private static final String USUARIO_API = "API";

    private final TemporadaRepository temporadaRepository;
    private final EpisodioRepository episodioRepository;
    private final SerieRepository serieRepository;
    private final ObraRepository obraRepository;
    private final TipoObraRepository tipoObraRepository;
    private final TemporadaMapper mapper;
    private final SerieMapper serieMapper;

    public TemporadaService(TemporadaRepository temporadaRepository,
                            EpisodioRepository episodioRepository,
                            SerieRepository serieRepository,
                            ObraRepository obraRepository,
                            TipoObraRepository tipoObraRepository,
                            TemporadaMapper mapper,
                            SerieMapper serieMapper) {
        this.temporadaRepository = temporadaRepository;
        this.episodioRepository = episodioRepository;
        this.serieRepository = serieRepository;
        this.obraRepository = obraRepository;
        this.tipoObraRepository = tipoObraRepository;
        this.mapper = mapper;
        this.serieMapper = serieMapper;
    }

    @Transactional(readOnly = true)
    public TemporadaResponse buscarPorId(Long id) {
        Temporada temporada = temporadaRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("temporada", id));

        return mapper.aDetalle(temporada, episodioRepository.findByTemporada(id));
    }

    @Transactional(readOnly = true)
    public List<TemporadaResumenResponse> listarPorSerie(Long serieId) {
        if (!serieRepository.existsById(serieId)) {
            throw RecursoNoEncontradoException.de("serie", serieId);
        }
        return temporadaRepository.findBySerie(serieId).stream()
                .map(serieMapper::aTemporadaResumen)
                .toList();
    }

    /** Dos inserciones en una transaccion: la obra y su subtipo. */
    @Transactional
    public TemporadaResponse crear(TemporadaRequest peticion) {
        Serie serie = serieRepository.findById(peticion.serieId())
                .orElseThrow(() -> RecursoNoEncontradoException.de("serie", peticion.serieId()));

        TipoObra tipoTemporada = tipoObraRepository.findByCodigo(TipoObra.TEMPORADA)
                .orElseThrow(() -> new IllegalStateException(
                        "Falta el tipo de obra TEMPORADA. Ejecuta db/seeds/001_configuracion.sql"));

        Obra obra = new Obra();
        obra.setTipoObra(tipoTemporada);
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioAlta(USUARIO_API);
        obraRepository.save(obra);

        Temporada temporada = new Temporada();
        temporada.setObra(obra);
        temporada.setSerie(serie);
        temporada.setNumero(peticion.numero());
        temporada.setUsuarioAlta(USUARIO_API);
        temporadaRepository.save(temporada);

        return mapper.aDetalle(temporada, List.of());
    }

    @Transactional
    public TemporadaResponse actualizar(Long id, TemporadaRequest peticion) {
        Temporada temporada = temporadaRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("temporada", id));

        if (!temporada.getSerie().getObraId().equals(peticion.serieId())) {
            Serie nueva = serieRepository.findById(peticion.serieId())
                    .orElseThrow(() -> RecursoNoEncontradoException.de("serie", peticion.serieId()));
            temporada.setSerie(nueva);
        }

        temporada.setNumero(peticion.numero());
        temporada.setUsuarioModificacion(USUARIO_API);

        Obra obra = temporada.getObra();
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioModificacion(USUARIO_API);

        return mapper.aDetalle(temporada, episodioRepository.findByTemporada(id));
    }

    /**
     * Borra la temporada y sus episodios.
     *
     * <p>Mismo cuidado que en SerieService: hay que quitar tambien las obras de
     * los episodios, que el CASCADE no alcanza porque no descienden de la obra
     * de la temporada.
     */
    @Transactional
    public void eliminar(Long id) {
        if (!temporadaRepository.existsById(id)) {
            throw RecursoNoEncontradoException.de("temporada", id);
        }
        List<Long> obras = new java.util.ArrayList<>(
                episodioRepository.findByTemporada(id).stream().map(e -> e.getObraId()).toList());
        obras.add(id);
        obraRepository.deleteAllByIdInBatch(obras);
    }
}
