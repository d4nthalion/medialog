package com.medialog.api.repository;

import com.medialog.api.model.DatoEpisodio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DatoEpisodioRepository extends JpaRepository<DatoEpisodio, Long> {

    /**
     * Todos los datos de un episodio, resueltos en UNA sola consulta.
     *
     * <p>Los cuatro {@code left join fetch} son la diferencia entre una
     * consulta y N+1. En un EAV cada obra tiene varias filas de datos, y cada
     * una puede referenciar una opcion, un idioma o un pais: sin el fetch, una
     * ficha con doce datos lanzaria mas de treinta consultas.
     *
     * <p>El orden lo marca el catalogo, no el id: asi el formulario y la ficha
     * salen siempre igual aunque los datos se hayan grabado en desorden.
     */
    @Query("""
            select d from DatoEpisodio d
            join fetch d.tipoDato t
            left join fetch d.valorOpcion
            left join fetch d.valorIdioma
            left join fetch d.valorPais
            where d.episodio.obraId = :episodioId
            order by t.orden, d.posicion
            """)
    List<DatoEpisodio> findByEpisodio(@Param("episodioId") Long episodioId);
}
