package com.tarotplatform.dto.admin;

import com.tarotplatform.enums.BookingStatus;
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
public class RecentBookingResponse {
    private Long id;
    private String bookingReference;
    private String customerName;
    private String customerEmail;
    private String serviceName;
    private LocalDateTime scheduledStart;
    private LocalDateTime scheduledEnd;
    private BookingStatus status;
    private BigDecimal price;
    private LocalDateTime createdAt;
}
