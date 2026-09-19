package com.tarotplatform.mapper;

import com.tarotplatform.dto.payment.PaymentResponse;
import com.tarotplatform.entity.Payment;
import org.springframework.stereotype.Component;

@Component
public class PaymentMapper {

    public PaymentResponse toResponse(Payment payment) {
        if (payment == null) {
            return null;
        }
        return PaymentResponse.builder()
                .id(payment.getId())
                .bookingId(payment.getBooking() != null ? payment.getBooking().getId() : null)
                .bookingReference(payment.getBooking() != null ? payment.getBooking().getBookingReference() : null)
                .transactionId(payment.getTransactionId())
                .provider(payment.getProvider())
                .amount(payment.getAmount())
                .currency(payment.getCurrency())
                .status(payment.getStatus())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }
}
