package com.medialog.api.repository;

import com.medialog.api.model.Serie;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SerieRepository extends JpaRepository<Serie, Long> {

    @Query("""
            select s from Serie s
            join fetch s.obra o
            join fetch o.tipoObra
            where s.obraId = :id
            """)
    Optional<Serie> findDetalle(@Param("id") Long id);

    /**
     * Parrilla de series, opcionalmente filtrada por titulo.
     *
     * <p>NO toca el EAV: titulo y ano estan en dat_obra. Sobre
     * {@code titulo_normalizado} —columna generada, en minusculas y sin
     * acentos— hay un indice GIN con pg_trgm, asi que el LIKE por ambos lados
     * si se puede resolver por indice.
     *
     * <p>Sin filtro se pasa cadena vacia, NO null: el patron queda en '%%' y
     * casa con todo. Con null, el driver enviaria el parametro sin tipo y
     * PostgreSQL fallaria con "operator does not exist: text ~~ bytea", porque
     * una guarda {@code :texto is null} no evita la comprobacion de tipos.
     */
    @Query("""
            select s from Serie s
            join fetch s.obra o
            where o.tituloNormalizado like concat('%', :texto, '%')
            """)
    Page<Serie> buscar(@Param("texto") String texto, Pageable pageable);

    /**
     * Ids de TODAS las obras que cuelgan de una serie: ella, sus temporadas y
     * sus episodios. Necesario para poder borrarla sin dejar basura; ver la
     * nota en SerieService.eliminar.
     */
    @Query(value = """
            select o.id
            from   dat_obra o
            where  o.id = :serieId
               or  o.id in (select t.obra_id from dat_temporada t where t.serie_id = :serieId)
               or  o.id in (select e.obra_id from dat_episodio e
                            join dat_temporada t2 on t2.obra_id = e.temporada_id
                            where t2.serie_id = :serieId)
            """, nativeQuery = true)
    List<Long> findIdsObraDeLaJerarquia(@Param("serieId") Long serieId);
}
