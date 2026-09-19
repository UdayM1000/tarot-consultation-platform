package com.tarotplatform.controller;

import com.tarotplatform.dto.booking.*;
import com.tarotplatform.service.AvailabilityService;
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

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('READER', 'ADMIN')")
@Tag(name = "Admin Availability", description = "Reader schedule and blackout management APIs")
public class AdminAvailabilityController {

    private final AvailabilityService availabilityService;

    @PostMapping("/availability")
    @Operation(summary = "Add recurring reader availability slot")
    public ResponseEntity<ReaderAvailabilityResponse> addAvailability(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody ReaderAvailabilityRequest request) {
        ReaderAvailabilityResponse response = availabilityService.addAvailability(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/availability")
    @Operation(summary = "List reader availability slots")
    public ResponseEntity<List<ReaderAvailabilityResponse>> getAvailabilities(
            @RequestParam(required = false) Long readerId) {
        List<ReaderAvailabilityResponse> list = availabilityService.getAvailabilities(readerId);
        return ResponseEntity.ok(list);
    }

    @PutMapping("/availability/{id}")
    @Operation(summary = "Update reader availability slot")
    public ResponseEntity<ReaderAvailabilityResponse> updateAvailability(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id,
            @Valid @RequestBody ReaderAvailabilityRequest request) {
        ReaderAvailabilityResponse response = availabilityService.updateAvailability(id, request, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/availability/{id}")
    @Operation(summary = "Delete reader availability slot")
    public ResponseEntity<Map<String, String>> deleteAvailability(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id) {
        availabilityService.deleteAvailability(id, userDetails.getUsername());
        return ResponseEntity.ok(Map.of("message", "Availability deleted successfully"));
    }

    @PostMapping("/blocked-dates")
    @Operation(summary = "Add reader blocked date / holiday")
    public ResponseEntity<BlockedDateResponse> addBlockedDate(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody BlockedDateRequest request) {
        BlockedDateResponse response = availabilityService.addBlockedDate(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/blocked-dates")
    @Operation(summary = "List reader blocked dates")
    public ResponseEntity<List<BlockedDateResponse>> getBlockedDates(
            @RequestParam(required = false) Long readerId) {
        List<BlockedDateResponse> list = availabilityService.getBlockedDates(readerId);
        return ResponseEntity.ok(list);
    }

    @DeleteMapping("/blocked-dates/{id}")
    @Operation(summary = "Delete reader blocked date")
    public ResponseEntity<Map<String, String>> deleteBlockedDate(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long id) {
        availabilityService.deleteBlockedDate(id, userDetails.getUsername());
        return ResponseEntity.ok(Map.of("message", "Blocked date removed successfully"));
    }
}
