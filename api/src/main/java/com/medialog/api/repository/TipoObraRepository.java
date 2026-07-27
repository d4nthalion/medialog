package com.medialog.api.repository;

import com.medialog.api.model.TipoObra;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TipoObraRepository extends JpaRepository<TipoObra, Integer> {

    /** Se busca por codigo y no por id: los ids de los catalogos no son estables entre entornos. */
    Optional<TipoObra> findByCodigo(String codigo);
}
