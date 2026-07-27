package com.medialog.api.controller;

import com.medialog.api.dto.EpisodioRequest;
import com.medialog.api.dto.EpisodioResponse;
import com.medialog.api.dto.EpisodioResumenResponse;
import com.medialog.api.service.EpisodioService;
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

import java.util.List;

@RestController
@RequestMapping("/api")
public class EpisodioController {

    private final EpisodioService servicio;

    public EpisodioController(EpisodioService servicio) {
        this.servicio = servicio;
    }

    @GetMapping("/episodios/{id}")
    public EpisodioResponse obtener(@PathVariable Long id) {
        return servicio.buscarPorId(id);
    }

    /** Anidado bajo la temporada: un episodio no existe fuera de una. */
    @GetMapping("/temporadas/{temporadaId}/episodios")
    public List<EpisodioResumenResponse> listar(@PathVariable Long temporadaId) {
        return servicio.listarPorTemporada(temporadaId);
    }

    @PostMapping("/episodios")
    public ResponseEntity<EpisodioResponse> crear(@Valid @RequestBody EpisodioRequest peticion,
                                                  UriComponentsBuilder uri) {
        EpisodioResponse creado = servicio.crear(peticion);
        return ResponseEntity
                .created(uri.path("/api/episodios/{id}").buildAndExpand(creado.id()).toUri())
                .body(creado);
    }

    @PutMapping("/episodios/{id}")
    public EpisodioResponse actualizar(@PathVariable Long id,
                                       @Valid @RequestBody EpisodioRequest peticion) {
        return servicio.actualizar(id, peticion);
    }

    @DeleteMapping("/episodios/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void eliminar(@PathVariable Long id) {
        servicio.eliminar(id);
    }
}
