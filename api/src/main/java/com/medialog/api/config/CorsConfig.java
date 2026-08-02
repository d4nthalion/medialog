package com.medialog.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

/**
 * Permite que el front en Vite hable con la API.
 *
 * <p>Sin esto el navegador bloquea toda peticion desde localhost:5175 y el
 * fetch falla sin codigo de estado, que es el sintoma mas confuso posible: la
 * API responde correctamente pero el front solo ve un error de red.
 *
 * <p>Los origenes son configurables para que produccion no herede los de
 * desarrollo. Nunca usar comodin junto a credenciales.
 */
@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter(
            @Value("${medialog.cors.origenes:http://localhost:5175}") List<String> origenes) {

        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(origenes);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);

        return new CorsFilter(source);
    }
}
