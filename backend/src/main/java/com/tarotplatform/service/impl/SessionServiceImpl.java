package com.tarotplatform.service.impl;

import com.tarotplatform.dto.session.SessionResponse;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Session;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.Role;
import com.tarotplatform.enums.SessionStatus;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.SessionMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.SessionRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.SessionProvider;
import com.tarotplatform.service.SessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class SessionServiceImpl implements SessionService {

    private final SessionRepository sessionRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final AuditLogRepository auditLogRepository;
    private final SessionProvider sessionProvider;
    private final SessionMapper mapper;

    @Override
    @Transactional
    public SessionResponse getOrCreateSession(Long bookingId, String authEmail) {
        Booking booking = verifyParticipantAndGetBooking(bookingId, authEmail);

        Session session = sessionRepository.findByBookingId(bookingId).orElseGet(() -> {
            SessionResponse created = sessionProvider.createSession(booking);
            Session entity = Session.builder()
                    .booking(booking)
                    .sessionType(booking.getSessionType())
                    .provider(created.getProvider())
                    .externalSessionId(created.getExternalSessionId())
                    .joinUrl(created.getJoinUrl())
                    .status(SessionStatus.SCHEDULED)
                    .build();
            return sessionRepository.save(entity);
        });

        return mapper.toResponse(session);
    }

    @Override
    @Transactional
    public SessionResponse startSession(Long bookingId, String authEmail) {
        Booking booking = verifyParticipantAndGetBooking(bookingId, authEmail);

        Session session = sessionRepository.findByBookingId(bookingId).orElseGet(() -> {
            SessionResponse created = sessionProvider.createSession(booking);
            Session entity = Session.builder()
                    .booking(booking)
                    .sessionType(booking.getSessionType())
                    .provider(created.getProvider())
                    .externalSessionId(created.getExternalSessionId())
                    .joinUrl(created.getJoinUrl())
                    .status(SessionStatus.SCHEDULED)
                    .build();
            return sessionRepository.save(entity);
        });

        session.setStatus(SessionStatus.ACTIVE);
        session.setStartedAt(LocalDateTime.now());
        Session updated = sessionRepository.save(session);

        auditLogRepository.save(AuditLog.builder()
                .action("SESSION_STARTED")
                .details("Session started for booking " + booking.getBookingReference())
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional
    public SessionResponse endSession(Long bookingId, String authEmail) {
        verifyParticipantAndGetBooking(bookingId, authEmail);

        Session session = sessionRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found for booking ID: " + bookingId));

        session.setStatus(SessionStatus.ENDED);
        session.setEndedAt(LocalDateTime.now());
        sessionProvider.endSession(session);

        Session updated = sessionRepository.save(session);

        auditLogRepository.save(AuditLog.builder()
                .action("SESSION_ENDED")
                .details("Session ended for booking ID: " + bookingId)
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public SessionResponse getSessionByBookingId(Long bookingId, String authEmail) {
        verifyParticipantAndGetBooking(bookingId, authEmail);

        Session session = sessionRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found for booking ID: " + bookingId));

        return mapper.toResponse(session);
    }

    private Booking verifyParticipantAndGetBooking(Long bookingId, String authEmail) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + bookingId));

        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        boolean isAuthorized = user.getRoles().contains(Role.ADMIN)
                || user.getRoles().contains(Role.READER)
                || booking.getCustomer().getId().equals(user.getId());

        if (!isAuthorized) {
            throw new ForbiddenException("You are not a participant in this consultation session.");
        }

        return booking;
    }
}
