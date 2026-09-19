package com.tarotplatform.controller;

import com.tarotplatform.dto.session.CreateSessionRequest;
import com.tarotplatform.dto.session.SessionResponse;
import com.tarotplatform.service.SessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/sessions")
@RequiredArgsConstructor
@Tag(name = "Sessions", description = "Consultation room initiation, credentials, and lifecycle APIs")
public class SessionController {

    private final SessionService sessionService;

    @PostMapping
    @Operation(summary = "Get or create active video/audio consultation session room")
    public ResponseEntity<SessionResponse> getOrCreateSession(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CreateSessionRequest request) {
        SessionResponse response = sessionService.getOrCreateSession(request.getBookingId(), userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{bookingId}")
    @Operation(summary = "Get consultation session status and room URL")
    public ResponseEntity<SessionResponse> getSession(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long bookingId) {
        SessionResponse response = sessionService.getSessionByBookingId(bookingId, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{bookingId}/start")
    @Operation(summary = "Start consultation session (sets status to ACTIVE)")
    public ResponseEntity<SessionResponse> startSession(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long bookingId) {
        SessionResponse response = sessionService.startSession(bookingId, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{bookingId}/end")
    @Operation(summary = "End consultation session (sets status to ENDED)")
    public ResponseEntity<SessionResponse> endSession(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long bookingId) {
        SessionResponse response = sessionService.endSession(bookingId, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }
}
