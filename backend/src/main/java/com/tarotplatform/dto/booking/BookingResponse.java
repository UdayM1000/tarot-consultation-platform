package com.tarotplatform.dto.booking;

import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.SessionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Long id;
    private String bookingReference;
    private Long customerId;
    private String customerName;
    private String customerEmail;
    private Long serviceId;
    private String serviceName;
    private String serviceSlug;
    private Integer durationMinutes;
    private LocalDateTime scheduledStart;
    private LocalDateTime scheduledEnd;
    private SessionType sessionType;
    private String question;
    private String additionalInformation;
    private BigDecimal priceAtBooking;
    private BookingStatus status;
    private Boolean disclaimerAccepted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
