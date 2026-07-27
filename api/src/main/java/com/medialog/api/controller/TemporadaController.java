package com.medialog.api.controller;

import com.medialog.api.dto.TemporadaRequest;
import com.medialog.api.dto.TemporadaResponse;
import com.medialog.api.service.TemporadaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

@RestController
@RequestMapping("/api/temporadas")
public class TemporadaController {

    private final TemporadaService servicio;

    public TemporadaController(TemporadaService servicio) {
        this.servicio = servicio;
    }

    @GetMapping("/{id}")
    public TemporadaResponse obtener(@PathVariable Long id) {
        return servicio.buscarPorId(id);
    }

    @PostMapping
    public ResponseEntity<TemporadaResponse> crear(@Valid @RequestBody TemporadaRequest peticion,
                                                   UriComponentsBuilder uri) {
        TemporadaResponse creada = servicio.crear(peticion);
        return ResponseEntity
                .created(uri.path("/api/temporadas/{id}").buildAndExpand(creada.id()).toUri())
                .body(creada);
    }

    @PutMapping("/{id}")
    public TemporadaResponse actualizar(@PathVariable Long id,
                                        @Valid @RequestBody TemporadaRequest peticion) {
        return servicio.actualizar(id, peticion);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
    }
}
