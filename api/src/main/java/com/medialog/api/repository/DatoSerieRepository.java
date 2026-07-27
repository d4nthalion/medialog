package com.medialog.api.repository;

import com.medialog.api.model.DatoSerie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DatoSerieRepository extends JpaRepository<DatoSerie, Long> {

    /**
     * Todos los datos de una serie en UNA consulta.
     *
     * <p>Los cuatro {@code left join fetch} son la diferencia entre una
     * consulta y N+1. En serie importa mas que en episodio: aqui el vocabulario
     * de opciones esta poblado de verdad (generos, estado, clasificacion) y
     * cada fila resolveria su propia referencia.
     */
    @Query("""
            select d from DatoSerie d
            join fetch d.tipoDato t
            left join fetch d.valorOpcion
            left join fetch d.valorIdioma
            left join fetch d.valorPais
            where d.serie.obraId = :serieId
            order by t.orden, d.posicion
            """)
    List<DatoSerie> findBySerie(@Param("serieId") Long serieId);
}
