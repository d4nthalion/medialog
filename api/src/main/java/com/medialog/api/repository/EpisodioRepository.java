package com.medialog.api.repository;

import com.medialog.api.model.Episodio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface EpisodioRepository extends JpaRepository<Episodio, Long> {

    /**
     * Episodio con su obra y su temporada en UNA consulta.
     *
     * <p>Sin el {@code join fetch}, las asociaciones son LAZY y al mapear el
     * DTO se dispararian dos consultas mas por episodio. Con {@code
     * open-in-view: false} ni siquiera funcionarian: la sesion ya estaria
     * cerrada.
     */
    @Query("""
            select e from Episodio e
            join fetch e.obra o
            join fetch o.tipoObra
            join fetch e.temporada
            where e.obraId = :id
            """)
    Optional<Episodio> findDetalle(@Param("id") Long id);

    /** Listado de una temporada. No toca la tabla de datos EAV. */
    @Query("""
            select e from Episodio e
            join fetch e.obra
            where e.temporada.obraId = :temporadaId
            order by e.numero
            """)
    List<Episodio> findByTemporada(@Param("temporadaId") Long temporadaId);
}
