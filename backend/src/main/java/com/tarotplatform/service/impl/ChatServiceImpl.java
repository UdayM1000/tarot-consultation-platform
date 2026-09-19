package com.tarotplatform.service.impl;

import com.tarotplatform.dto.session.ChatMessageRequest;
import com.tarotplatform.dto.session.ChatMessageResponse;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Message;
import com.tarotplatform.entity.Notification;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.NotificationType;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.MessageMapper;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.MessageRepository;
import com.tarotplatform.repository.NotificationRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final MessageRepository messageRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;
    private final MessageMapper mapper;

    @Override
    @Transactional
    public ChatMessageResponse sendMessage(ChatMessageRequest request, String senderEmail) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + request.getBookingId()));

        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Sender not found"));

        boolean isParticipant = sender.getRoles().contains(Role.ADMIN)
                || sender.getRoles().contains(Role.READER)
                || booking.getCustomer().getId().equals(sender.getId());

        if (!isParticipant) {
            throw new ForbiddenException("You cannot send messages in this consultation session.");
        }

        Message message = Message.builder()
                .booking(booking)
                .sender(sender)
                .message(request.getMessage().trim())
                .messageType(request.getMessageType())
                .build();

        Message saved = messageRepository.save(message);

        // Notify recipient if sender is reader/admin, notify customer
        if (sender.getRoles().contains(Role.READER) || sender.getRoles().contains(Role.ADMIN)) {
            notificationRepository.save(Notification.builder()
                    .user(booking.getCustomer())
                    .title("New Consultation Message")
                    .message("You received a message regarding booking " + booking.getBookingReference() + ".")
                    .type(NotificationType.NEW_MESSAGE)
                    .isRead(false)
                    .build());
        }

        return mapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ChatMessageResponse> getBookingMessages(Long bookingId, String authEmail, Pageable pageable) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + bookingId));

        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        boolean isAuthorized = user.getRoles().contains(Role.ADMIN)
                || user.getRoles().contains(Role.READER)
                || booking.getCustomer().getId().equals(user.getId());

        if (!isAuthorized) {
            throw new ForbiddenException("You cannot view messages for this consultation.");
        }

        return messageRepository.findByBookingIdOrderBySentAtDesc(bookingId, pageable)
                .map(mapper::toResponse);
    }

    @Override
    @Transactional
    public void markMessagesRead(Long bookingId, String authEmail) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + bookingId));

        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        List<Message> messages = messageRepository.findByBookingIdOrderBySentAtAsc(bookingId);
        LocalDateTime now = LocalDateTime.now();

        for (Message msg : messages) {
            if (!msg.getSender().getId().equals(user.getId()) && msg.getReadAt() == null) {
                msg.setReadAt(now);
                messageRepository.save(msg);
            }
        }
    }
}
