package com.tarotplatform.controller;

import com.tarotplatform.dto.service.CategoryResponse;
import com.tarotplatform.dto.service.ReadingServiceResponse;
import com.tarotplatform.service.ReadingServiceCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/services")
@RequiredArgsConstructor
@Tag(name = "Services", description = "Public reading service catalog and categories")
public class ReadingServiceController {

    private final ReadingServiceCatalogService catalogService;

    @GetMapping
    @Operation(summary = "Get paginated active reading services with optional category filter")
    public ResponseEntity<Page<ReadingServiceResponse>> getServices(
            @RequestParam(required = false) Long categoryId,
            @PageableDefault(size = 20, sort = "price") Pageable pageable) {
        Page<ReadingServiceResponse> services = catalogService.getActiveServices(categoryId, pageable);
        return ResponseEntity.ok(services);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get reading service by ID with server-side price")
    public ResponseEntity<ReadingServiceResponse> getServiceById(@PathVariable Long id) {
        ReadingServiceResponse service = catalogService.getServiceById(id);
        return ResponseEntity.ok(service);
    }

    @GetMapping("/slug/{slug}")
    @Operation(summary = "Get reading service by slug")
    public ResponseEntity<ReadingServiceResponse> getServiceBySlug(@PathVariable String slug) {
        ReadingServiceResponse service = catalogService.getServiceBySlug(slug);
        return ResponseEntity.ok(service);
    }

    @GetMapping("/categories")
    @Operation(summary = "Get list of active service categories")
    public ResponseEntity<List<CategoryResponse>> getCategories() {
        List<CategoryResponse> categories = catalogService.getAllCategories();
        return ResponseEntity.ok(categories);
    }
}
