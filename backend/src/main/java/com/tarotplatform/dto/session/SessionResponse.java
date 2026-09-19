package com.tarotplatform.dto.session;

import com.tarotplatform.enums.SessionStatus;
import com.tarotplatform.enums.SessionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionResponse {
    private Long id;
    private Long bookingId;
    private String bookingReference;
    private SessionType sessionType;
    private String provider;
    private String externalSessionId;
    private String joinUrl;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private SessionStatus status;
    private LocalDateTime createdAt;
}
