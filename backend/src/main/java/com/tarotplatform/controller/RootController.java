package com.tarotplatform.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@Tag(name = "Root", description = "System Status and Welcome APIs")
public class RootController {

    @GetMapping("/")
    @Operation(summary = "Root welcome & system health status")
    public ResponseEntity<Map<String, Object>> root() {
        return ResponseEntity.ok(Map.of(
                "status", "ONLINE",
                "message", "🔮 Tarot & Rune Consultation Platform Backend is operational",
                "version", "1.0.0",
                "swaggerDocumentation", "/swagger-ui/index.html",
                "healthCheck", "/actuator/health",
                "apiBase", "/api/v1"
        ));
    }
}
