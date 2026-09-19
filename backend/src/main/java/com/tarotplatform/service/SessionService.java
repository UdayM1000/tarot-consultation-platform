package com.tarotplatform.service;

import com.tarotplatform.dto.session.SessionResponse;

public interface SessionService {

    SessionResponse getOrCreateSession(Long bookingId, String authEmail);

    SessionResponse startSession(Long bookingId, String authEmail);

    SessionResponse endSession(Long bookingId, String authEmail);

    SessionResponse getSessionByBookingId(Long bookingId, String authEmail);
}
