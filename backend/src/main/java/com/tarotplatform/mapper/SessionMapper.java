package com.tarotplatform.mapper;

import com.tarotplatform.dto.session.SessionResponse;
import com.tarotplatform.entity.Session;
import org.springframework.stereotype.Component;

@Component
public class SessionMapper {

    public SessionResponse toResponse(Session session) {
        if (session == null) {
            return null;
        }
        return SessionResponse.builder()
                .id(session.getId())
                .bookingId(session.getBooking() != null ? session.getBooking().getId() : null)
                .bookingReference(session.getBooking() != null ? session.getBooking().getBookingReference() : null)
                .sessionType(session.getSessionType())
                .provider(session.getProvider())
                .externalSessionId(session.getExternalSessionId())
                .joinUrl(session.getJoinUrl())
                .startedAt(session.getStartedAt())
                .endedAt(session.getEndedAt())
                .status(session.getStatus())
                .createdAt(session.getCreatedAt())
                .build();
    }
}
