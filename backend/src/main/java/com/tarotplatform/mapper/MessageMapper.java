package com.tarotplatform.mapper;

import com.tarotplatform.dto.session.ChatMessageResponse;
import com.tarotplatform.entity.Message;
import org.springframework.stereotype.Component;

@Component
public class MessageMapper {

    public ChatMessageResponse toResponse(Message message) {
        if (message == null) {
            return null;
        }
        return ChatMessageResponse.builder()
                .id(message.getId())
                .bookingId(message.getBooking() != null ? message.getBooking().getId() : null)
                .senderId(message.getSender() != null ? message.getSender().getId() : null)
                .senderName(message.getSender() != null ? message.getSender().getName() : null)
                .message(message.getMessage())
                .messageType(message.getMessageType())
                .sentAt(message.getSentAt())
                .readAt(message.getReadAt())
                .build();
    }
}
