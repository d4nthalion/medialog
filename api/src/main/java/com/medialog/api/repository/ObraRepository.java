package com.medialog.api.repository;

import com.medialog.api.model.Obra;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ObraRepository extends JpaRepository<Obra, Long> {
}
