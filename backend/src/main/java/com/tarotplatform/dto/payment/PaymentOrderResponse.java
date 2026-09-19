package com.tarotplatform.dto.payment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentOrderResponse {
    private String orderId;
    private String transactionId;
    private BigDecimal amount;
    private String currency;
    private String provider;
    private String bookingReference;
    private Long bookingId;
}
