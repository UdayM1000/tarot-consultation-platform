package com.tarotplatform.controller;

import com.tarotplatform.dto.service.CreateReadingServiceRequest;
import com.tarotplatform.dto.service.ReadingServiceResponse;
import com.tarotplatform.dto.service.ServiceStatusUpdateRequest;
import com.tarotplatform.dto.service.UpdateReadingServiceRequest;
import com.tarotplatform.service.ReadingServiceCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin/services")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin Services", description = "Administrator catalog management and pricing APIs")
public class AdminServiceController {

    private final ReadingServiceCatalogService catalogService;

    @PostMapping
    @Operation(summary = "Create new reading consultation service")
    public ResponseEntity<ReadingServiceResponse> createService(@Valid @RequestBody CreateReadingServiceRequest request) {
        ReadingServiceResponse response = catalogService.createService(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update reading consultation service details and price")
    public ResponseEntity<ReadingServiceResponse> updateService(
            @PathVariable Long id,
            @Valid @RequestBody UpdateReadingServiceRequest request) {
        ReadingServiceResponse response = catalogService.updateService(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Deactivate reading consultation service")
    public ResponseEntity<Map<String, String>> deleteService(@PathVariable Long id) {
        catalogService.deleteService(id);
        return ResponseEntity.ok(Map.of("message", "Service deactivated successfully"));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update active status of reading consultation service")
    public ResponseEntity<ReadingServiceResponse> updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody ServiceStatusUpdateRequest request) {
        ReadingServiceResponse response = catalogService.updateServiceStatus(id, request.getActive());
        return ResponseEntity.ok(response);
    }
}
