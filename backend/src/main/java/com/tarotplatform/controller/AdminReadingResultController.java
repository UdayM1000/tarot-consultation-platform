package com.tarotplatform.controller;

import com.tarotplatform.dto.reading.CreateReadingResultRequest;
import com.tarotplatform.dto.reading.ReadingResultResponse;
import com.tarotplatform.dto.reading.UpdateReadingResultRequest;
import com.tarotplatform.service.ReadingResultService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/readings")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('READER', 'ADMIN')")
@Tag(name = "Admin Readings", description = "Reader and Admin consultation results entry and modification")
public class AdminReadingResultController {

    private final ReadingResultService readingResultService;

    @PostMapping
    @Operation(summary = "Publish consultation reading result with Tarot and Rune spreads")
    public ResponseEntity<ReadingResultResponse> createReading(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CreateReadingResultRequest request) {
        ReadingResultResponse response = readingResultService.createReadingResult(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get reading result by ID (Admin/Reader)")
    public ResponseEntity<ReadingResultResponse> getReadingById(@PathVariable Long id) {
        ReadingResultResponse response = readingResultService.getReadingByIdForAdmin(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update reading result and card/rune spreads")
    public ResponseEntity<ReadingResultResponse> updateReading(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id,
            @Valid @RequestBody UpdateReadingResultRequest request) {
        ReadingResultResponse response = readingResultService.updateReadingResult(id, request, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }
}
