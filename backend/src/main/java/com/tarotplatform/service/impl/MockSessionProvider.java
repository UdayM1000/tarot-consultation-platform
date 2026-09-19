package com.tarotplatform.service.impl;

import com.tarotplatform.dto.session.SessionResponse;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Session;
import com.tarotplatform.enums.SessionStatus;
import com.tarotplatform.service.SessionProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Slf4j
@Component("mockSessionProvider")
public class MockSessionProvider implements SessionProvider {

    @Override
    public String getProviderName() {
        return "MOCK_VIDEO_PROVIDER";
    }

    @Override
    public SessionResponse createSession(Booking booking) {
        String roomId = "room_" + UUID.randomUUID().toString().substring(0, 8);
        String joinUrl = "https://consult.tarotplatform.com/rooms/" + roomId;

        log.info("Mock session created for booking {}: {}", booking.getBookingReference(), joinUrl);

        return SessionResponse.builder()
                .bookingId(booking.getId())
                .bookingReference(booking.getBookingReference())
                .sessionType(booking.getSessionType())
                .provider(getProviderName())
                .externalSessionId(roomId)
                .joinUrl(joinUrl)
                .status(SessionStatus.SCHEDULED)
                .build();
    }

    @Override
    public void endSession(Session session) {
        log.info("Mock session ended for room {}", session.getExternalSessionId());
    }
}
