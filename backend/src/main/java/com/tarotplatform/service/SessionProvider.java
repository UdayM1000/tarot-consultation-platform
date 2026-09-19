package com.tarotplatform.service;

import com.tarotplatform.dto.session.SessionResponse;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Session;

public interface SessionProvider {

    String getProviderName();

    SessionResponse createSession(Booking booking);

    void endSession(Session session);
}
