package com.tarotplatform.dto.session;

import com.tarotplatform.enums.MessageType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageResponse {
    private Long id;
    private Long bookingId;
    private Long senderId;
    private String senderName;
    private String message;
    private MessageType messageType;
    private LocalDateTime sentAt;
    private LocalDateTime readAt;
}
