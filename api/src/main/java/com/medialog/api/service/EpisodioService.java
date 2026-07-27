package com.medialog.api.service;

import com.medialog.api.dto.EpisodioRequest;
import com.medialog.api.dto.EpisodioResponse;
import com.medialog.api.dto.EpisodioResumenResponse;
import com.medialog.api.exception.RecursoNoEncontradoException;
import com.medialog.api.mapper.EpisodioMapper;
import com.medialog.api.model.Episodio;
import com.medialog.api.model.Obra;
import com.medialog.api.model.Temporada;
import com.medialog.api.model.TipoObra;
import com.medialog.api.repository.DatoEpisodioRepository;
import com.medialog.api.repository.EpisodioRepository;
import com.medialog.api.repository.ObraRepository;
import com.medialog.api.repository.TemporadaRepository;
import com.medialog.api.repository.TipoObraRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class EpisodioService {

    /**
     * Valor provisional para las columnas de auditoria.
     *
     * <p>Cuando exista autenticacion, esto sale del usuario de la sesion. Hasta
     * entonces queda constante y localizado en un unico sitio.
     */
    private static final String USUARIO_API = "API";

    private final EpisodioRepository episodioRepository;
    private final DatoEpisodioRepository datoEpisodioRepository;
    private final ObraRepository obraRepository;
    private final TemporadaRepository temporadaRepository;
    private final TipoObraRepository tipoObraRepository;
    private final EpisodioMapper mapper;

    public EpisodioService(EpisodioRepository episodioRepository,
                           DatoEpisodioRepository datoEpisodioRepository,
                           ObraRepository obraRepository,
                           TemporadaRepository temporadaRepository,
                           TipoObraRepository tipoObraRepository,
                           EpisodioMapper mapper) {
        this.episodioRepository = episodioRepository;
        this.datoEpisodioRepository = datoEpisodioRepository;
        this.obraRepository = obraRepository;
        this.temporadaRepository = temporadaRepository;
        this.tipoObraRepository = tipoObraRepository;
        this.mapper = mapper;
    }

    /** Ficha completa: dos consultas, una para el episodio y otra para sus datos. */
    @Transactional(readOnly = true)
    public EpisodioResponse buscarPorId(Long id) {
        Episodio episodio = episodioRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("episodio", id));

        return mapper.aDetalle(episodio, datoEpisodioRepository.findByEpisodio(id));
    }

    @Transactional(readOnly = true)
    public List<EpisodioResumenResponse> listarPorTemporada(Long temporadaId) {
        if (!temporadaRepository.existsById(temporadaId)) {
            throw RecursoNoEncontradoException.de("temporada", temporadaId);
        }
        return episodioRepository.findByTemporada(temporadaId).stream()
                .map(mapper::aResumen)
                .toList();
    }

    /**
     * Alta de un episodio.
     *
     * <p>Son DOS inserciones: primero la fila de {@code dat_obra} —el
     * supertipo— y despues la de {@code dat_episodio}, que comparte con ella la
     * clave primaria. La transaccion es lo que impide que quede una obra
     * huerfana si la segunda falla.
     */
    @Transactional
    public EpisodioResponse crear(EpisodioRequest peticion) {
        Temporada temporada = temporadaRepository.findById(peticion.temporadaId())
                .orElseThrow(() -> RecursoNoEncontradoException.de("temporada", peticion.temporadaId()));

        TipoObra tipoEpisodio = tipoObraRepository.findByCodigo(TipoObra.EPISODIO)
                .orElseThrow(() -> new IllegalStateException(
                        "Falta el tipo de obra EPISODIO. Ejecuta db/seeds/001_configuracion.sql"));

        Obra obra = new Obra();
        obra.setTipoObra(tipoEpisodio);
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioAlta(USUARIO_API);
        obraRepository.save(obra);

        Episodio episodio = new Episodio();
        episodio.setObra(obra);
        episodio.setTemporada(temporada);
        episodio.setNumero(peticion.numero());
        episodio.setUsuarioAlta(USUARIO_API);
        episodioRepository.save(episodio);

        return mapper.aDetalle(episodio, List.of());
    }

    @Transactional
    public EpisodioResponse actualizar(Long id, EpisodioRequest peticion) {
        Episodio episodio = episodioRepository.findDetalle(id)
                .orElseThrow(() -> RecursoNoEncontradoException.de("episodio", id));

        if (!episodio.getTemporada().getObraId().equals(peticion.temporadaId())) {
            Temporada nueva = temporadaRepository.findById(peticion.temporadaId())
                    .orElseThrow(() -> RecursoNoEncontradoException.de("temporada", peticion.temporadaId()));
            episodio.setTemporada(nueva);
        }

        episodio.setNumero(peticion.numero());
        episodio.setUsuarioModificacion(USUARIO_API);

        Obra obra = episodio.getObra();
        obra.setTitulo(peticion.titulo());
        obra.setAnio(peticion.anio());
        obra.setPortadaUrl(peticion.portadaUrl());
        obra.setUsuarioModificacion(USUARIO_API);

        // Sin save(): las entidades estan gestionadas y el commit vuelca los cambios.
        return mapper.aDetalle(episodio, datoEpisodioRepository.findByEpisodio(id));
    }

    /**
     * Baja de un episodio.
     *
     * <p>Se borra la OBRA, no el episodio: el ON DELETE CASCADE del esquema se
     * lleva por delante la fila de dat_episodio y sus datos EAV. Borrar solo el
     * episodio dejaria la obra huerfana.
     */
    @Transactional
    public void eliminar(Long id) {
        if (!episodioRepository.existsById(id)) {
            throw RecursoNoEncontradoException.de("episodio", id);
        }
        obraRepository.deleteById(id);
    }
}
