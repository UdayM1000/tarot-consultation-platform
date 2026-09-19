package com.tarotplatform.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    public static final String SECURITY_SCHEME_NAME = "Bearer Authentication";

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Tarot & Rune Consultation Platform API")
                        .version("1.0.0")
                        .description("Scalable backend REST API for Tarot & Rune consultation, bookings, live sessions, and payments.")
                        .contact(new Contact().name("Tarot Platform Engineering").email("support@tarotplatform.com"))
                        .license(new License().name("Proprietary")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .schemaRequirement(SECURITY_SCHEME_NAME, new SecurityScheme()
                        .name(SECURITY_SCHEME_NAME)
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT"));
    }

    @Bean
    public org.springdoc.core.models.GroupedOpenApi allApis() {
        return org.springdoc.core.models.GroupedOpenApi.builder()
                .group("0-all-endpoints")
                .pathsToMatch("/api/v1/**")
                .build();
    }

    @Bean
    public org.springdoc.core.models.GroupedOpenApi publicApis() {
        return org.springdoc.core.models.GroupedOpenApi.builder()
                .group("1-public-services-catalog")
                .pathsToMatch("/api/v1/auth/**", "/api/v1/services/**", "/api/v1/availability/**", "/api/v1/reviews")
                .build();
    }

    @Bean
    public org.springdoc.core.models.GroupedOpenApi customerApis() {
        return org.springdoc.core.models.GroupedOpenApi.builder()
                .group("2-seeker-and-customer")
                .pathsToMatch("/api/v1/users/**", "/api/v1/bookings/**", "/api/v1/payments/**", "/api/v1/readings/**", "/api/v1/sessions/**", "/api/v1/chat/**", "/api/v1/notifications/**")
                .build();
    }

    @Bean
    public org.springdoc.core.models.GroupedOpenApi adminApis() {
        return org.springdoc.core.models.GroupedOpenApi.builder()
                .group("3-reader-and-admin")
                .pathsToMatch("/api/v1/admin/**")
                .build();
    }
}
