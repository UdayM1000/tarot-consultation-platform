package com.tarotplatform.service;

import com.tarotplatform.dto.session.ChatMessageRequest;
import com.tarotplatform.dto.session.ChatMessageResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ChatService {

    ChatMessageResponse sendMessage(ChatMessageRequest request, String senderEmail);

    Page<ChatMessageResponse> getBookingMessages(Long bookingId, String authEmail, Pageable pageable);

    void markMessagesRead(Long bookingId, String authEmail);
}
