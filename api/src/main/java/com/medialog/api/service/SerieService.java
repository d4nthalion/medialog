package com.medialog.api.service;

import com.medialog.api.dto.SerieRequest;
import com.medialog.api.dto.SerieResponse;
import com.medialog.api.dto.SerieResumenResponse;
import com.medialog.api.exception.RecursoNoEncontradoException;
import com.medialog.api.mapper.SerieMapper;
import com.medialog.api.model.Obra;
import com.medialog.api.model.Serie;
import com.medialog.api.model.TipoObra;
import com.medialog.api.repository.DatoSerieRepository;
import com.medialog.api.repository.ObraRepository;
import com.medialog.api.repository.SerieRepository;
import com.medialog.api.repository.TemporadaRepository;
import com.medialog.api.repository.TipoObraRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;

@Service
public class SerieService {

    /** Provisional hasta que exista autenticacion; ver EpisodioService. */
    private static final String USUARIO_API = "API";

    private final SerieRepository serieRepository;
    private final DatoSerieRepository datoSerieRepository;
    private final TemporadaRepository temporadaRepository;
    private final ObraRepository obraRepository;
    private final TipoObraRepository tipoObraRepository;
    private final SerieMapper mapper;

    public SerieService(SerieRepository serieRepository,
                        DatoSerieRepository datoSerieRepository,
                        TemporadaRepository temporadaRepository,
                        ObraRepository obraRepository,
                        TipoObraRepository tipoObraRepository,
                        SerieMapper mapper) {
        this.serieRepository = serieRepository;
        this.datoSerieRepository = datoSerieRepository;
        this.temporadaRepository = temporadaRepository;
        this.obraRepository = obraRepository;
        this.tipoObraRepository = tipoObraRepository;
        this.mapper = mapper;
    }

    /** Ficha completa: la serie, sus datos EAV y sus temporadas. */
    @Transactional(readOnly = true)
    public SerieResponse buscarPorId(Long id) {
        Serie serie = serieRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("serie", id));

        return mapper.aDetalle(
                serie,
                datoSerieRepository.findBySerie(id),
                temporadaRepository.findBySerie(id));
    }

    /**
     * Parrilla paginada. El texto se normaliza aqui igual que lo hace
     * fn_normalizar en la base de datos —minusculas y sin acentos— para que la
     * comparacion contra titulo_normalizado cuadre.
     */
    @Transactional(readOnly = true)
    public Page<SerieResumenResponse> buscar(String texto, Pageable pageable) {
        return serieRepository.buscar(normalizar(texto), pageable).map(mapper::aResumen);
    }

    @Transactional
    public SerieResponse crear(SerieRequest peticion) {
        TipoObra tipoSerie = tipoObraRepository.findByCodigo(TipoObra.SERIE)
                .orElseThrow(() -> new IllegalStateException(
                        "Falta el tipo de obra SERIE. Ejecuta db/seeds/001_configuracion.sql"));

        Obra obra = new Obra();
        obra.setTipoObra(tipoSerie);
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioAlta(USUARIO_API);
        obraRepository.save(obra);

        Serie serie = new Serie();
        serie.setObra(obra);
        serie.setUsuarioAlta(USUARIO_API);
        serieRepository.save(serie);

        return mapper.aDetalle(serie, List.of(), List.of());
    }

    @Transactional
    public SerieResponse actualizar(Long id, SerieRequest peticion) {
        Serie serie = serieRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("serie", id));

        Obra obra = serie.getObra();
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioModificacion(USUARIO_API);
        serie.setUsuarioModificacion(USUARIO_API);

        return mapper.aDetalle(
                serie,
                datoSerieRepository.findBySerie(id),
                temporadaRepository.findBySerie(id));
    }

    /**
     * Baja de una serie con toda su jerarquia.
     *
     * <p>OJO: borrar la obra de la serie NO basta. El CASCADE del esquema
     * elimina las filas de dat_serie, dat_temporada y dat_episodio, pero las
     * filas de DAT_OBRA de esas temporadas y episodios quedarian huerfanas: son
     * hermanas, no descendientes, de la obra de la serie.
     *
     * <p>Por eso se recogen antes todos los ids de la jerarquia y se borran de
     * una vez, dentro de la misma transaccion.
     */
    @Transactional
    public void eliminar(Long id) {
        if (!serieRepository.existsById(id)) {
            throw RecursoNoEncontradoException.de("serie", id);
        }
        obraRepository.deleteAllByIdInBatch(serieRepository.findIdsObraDeLaJerarquia(id));
    }

    /** Equivalente en Java de fn_normalizar: minusculas y sin acentos. */
    private String normalizar(String texto) {
        if (texto == null || texto.isBlank()) {
            return null;
        }
        return Normalizer.normalize(texto.trim().toLowerCase(), Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    }
}
