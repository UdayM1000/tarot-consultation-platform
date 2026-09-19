package com.tarotplatform.controller;

import com.tarotplatform.dto.reading.ReadingResultResponse;
import com.tarotplatform.service.ReadingResultService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/readings")
@RequiredArgsConstructor
@Tag(name = "Readings", description = "Customer consultation results and card/rune spreads")
public class ReadingResultController {

    private final ReadingResultService readingResultService;

    @GetMapping
    @Operation(summary = "Get paginated consultation results for current authenticated customer")
    public ResponseEntity<Page<ReadingResultResponse>> getCustomerReadings(
            @AuthenticationPrincipal UserDetails userDetails,
            @PageableDefault(size = 10, sort = "createdAt") Pageable pageable) {
        Page<ReadingResultResponse> readings = readingResultService.getCustomerReadings(userDetails.getUsername(), pageable);
        return ResponseEntity.ok(readings);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get specific reading result (restricted to booking customer)")
    public ResponseEntity<ReadingResultResponse> getReadingById(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id) {
        ReadingResultResponse response = readingResultService.getReadingByIdForCustomer(id, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }
}
