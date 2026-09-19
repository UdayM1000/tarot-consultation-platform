package com.tarotplatform.controller;

import com.tarotplatform.dto.session.ChatMessageRequest;
import com.tarotplatform.dto.session.ChatMessageResponse;
import com.tarotplatform.service.ChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Consultation chat history and REST messaging APIs")
public class ChatController {

    private final ChatService chatService;

    @PostMapping("/messages")
    @Operation(summary = "Send chat message within consultation booking")
    public ResponseEntity<ChatMessageResponse> sendMessage(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody ChatMessageRequest request) {
        ChatMessageResponse response = chatService.sendMessage(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{bookingId}/messages")
    @Operation(summary = "Get paginated chat messages for consultation")
    public ResponseEntity<Page<ChatMessageResponse>> getMessages(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long bookingId,
            @PageableDefault(size = 30) Pageable pageable) {
        Page<ChatMessageResponse> messages = chatService.getBookingMessages(bookingId, userDetails.getUsername(), pageable);
        return ResponseEntity.ok(messages);
    }

    @PatchMapping("/{bookingId}/read")
    @Operation(summary = "Mark consultation chat messages as read")
    public ResponseEntity<Map<String, String>> markRead(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long bookingId) {
        chatService.markMessagesRead(bookingId, userDetails.getUsername());
        return ResponseEntity.ok(Map.of("message", "Messages marked as read"));
    }
}
