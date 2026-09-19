package com.tarotplatform.dto.booking;

import com.tarotplatform.enums.SessionType;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateBookingRequest {

    @NotNull(message = "Reading service ID is required")
    private Long serviceId;

    @NotNull(message = "Scheduled start time is required")
    @Future(message = "Scheduled consultation time must be in the future")
    private LocalDateTime scheduledStart;

    @NotNull(message = "Session type is required (VIDEO, AUDIO, CHAT, IN_PERSON)")
    private SessionType sessionType;

    @Size(max = 2000, message = "Question must not exceed 2000 characters")
    private String question;

    @Size(max = 2000, message = "Additional information must not exceed 2000 characters")
    private String additionalInformation;

    @NotNull(message = "Platform disclaimer acceptance is required")
    private Boolean disclaimerAccepted;
}
