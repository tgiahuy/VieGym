package com.viegym.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    public static final String BEARER_AUTH = "bearerAuth";

    @Bean
    OpenAPI vieGymOpenApi() {
        SecurityScheme bearerScheme =
                new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT");

        return new OpenAPI()
                .info(
                        new Info()
                                .title("VieGym API")
                                .version("v1")
                                .description(
                                        "Backend API for VieGym workout, nutrition and AI coach")
                                .contact(new Contact().name("VieGym")))
                .servers(
                        List.of(
                                new Server()
                                        .url("http://localhost:8080/api/v1")
                                        .description("Local development API v1")))
                .components(new Components().addSecuritySchemes(BEARER_AUTH, bearerScheme));
    }
}
