package com.tarotplatform.service.impl;

import com.tarotplatform.dto.payment.PaymentOrderResponse;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.service.PaymentGatewayProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Slf4j
@Component("mockPaymentGateway")
public class MockPaymentGatewayProvider implements PaymentGatewayProvider {

    @Override
    public String getProviderName() {
        return "MOCK";
    }

    @Override
    public PaymentOrderResponse createOrder(Booking booking) {
        String orderId = "order_mock_" + UUID.randomUUID().toString().substring(0, 12);
        String txnId = "txn_mock_" + UUID.randomUUID().toString().substring(0, 12);

        log.info("Mock payment gateway created order {} for booking {}", orderId, booking.getBookingReference());

        return PaymentOrderResponse.builder()
                .orderId(orderId)
                .transactionId(txnId)
                .amount(booking.getPriceAtBooking())
                .currency("INR")
                .provider(getProviderName())
                .bookingReference(booking.getBookingReference())
                .bookingId(booking.getId())
                .build();
    }

    @Override
    public boolean verifyPayment(PaymentVerificationRequest request, Booking booking) {
        // In mock mode, if simulateSuccess is true and transactionId is present, verification succeeds
        boolean success = request.isSimulateSuccess() && request.getTransactionId() != null;
        log.info("Mock payment verification for transaction {} result: {}", request.getTransactionId(), success);
        return success;
    }

    @Override
    public void processWebhook(String payload, String signature) {
        log.info("Mock payment webhook received: {}", payload);
    }
}
