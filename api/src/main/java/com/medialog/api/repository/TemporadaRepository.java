package com.medialog.api.repository;

import com.medialog.api.model.Temporada;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface TemporadaRepository extends JpaRepository<Temporada, Long> {

    @Query("""
            select t from Temporada t
            join fetch t.obra
            join fetch t.serie s
            join fetch s.obra
            where t.obraId = :id
            """)
    Optional<Temporada> findDetalle(@Param("id") Long id);

    @Query("""
            select t from Temporada t
            join fetch t.obra
            where t.serie.obraId = :serieId
            order by t.numero
            """)
    List<Temporada> findBySerie(@Param("serieId") Long serieId);
}
