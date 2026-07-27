package com.medialog.api.controller;

import com.medialog.api.dto.SerieRequest;
import com.medialog.api.dto.SerieResponse;
import com.medialog.api.dto.SerieResumenResponse;
import com.medialog.api.dto.TemporadaResumenResponse;
import com.medialog.api.service.SerieService;
import com.medialog.api.service.TemporadaService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/series")
public class SerieController {

    private final SerieService servicio;
    private final TemporadaService temporadaService;

    public SerieController(SerieService servicio, TemporadaService temporadaService) {
        this.servicio = servicio;
        this.temporadaService = temporadaService;
    }

    /** {@code ?q=texto&page=0&size=20}. Sin filtro devuelve todas, paginadas. */
    @GetMapping
    public Page<SerieResumenResponse> buscar(
            @RequestParam(required = false) String q,
            @PageableDefault(size = 20, sort = "obra.titulo", direction = Sort.Direction.ASC)
            Pageable pageable) {
        return servicio.buscar(q, pageable);
    }

    @GetMapping("/{id}")
    public SerieResponse obtener(@PathVariable Long id) {
        return servicio.buscarPorId(id);
    }

    /** Anidado: las temporadas no existen fuera de una serie. */
    @GetMapping("/{id}/temporadas")
    public List<TemporadaResumenResponse> temporadas(@PathVariable Long id) {
        return temporadaService.listarPorSerie(id);
    }

    @PostMapping
    public ResponseEntity<SerieResponse> crear(@Valid @RequestBody SerieRequest peticion,
                                               UriComponentsBuilder uri) {
        SerieResponse creada = servicio.crear(peticion);
        return ResponseEntity
                .created(uri.path("/api/series/{id}").buildAndExpand(creada.id()).toUri())
                .body(creada);
    }

    @PutMapping("/{id}")
    public SerieResponse actualizar(@PathVariable Long id,
                                    @Valid @RequestBody SerieRequest peticion) {
        return servicio.actualizar(id, peticion);
    }

    /** Arrastra temporadas y episodios; ver la nota en SerieService.eliminar. */
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
    }
}
