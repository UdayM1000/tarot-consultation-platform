package com.tarotplatform.service;

import com.tarotplatform.dto.payment.PaymentOrderResponse;
import com.tarotplatform.dto.payment.PaymentResponse;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;

public interface PaymentService {

    PaymentOrderResponse createOrder(Long bookingId, String customerEmail);

    PaymentResponse verifyPayment(PaymentVerificationRequest request, String customerEmail);

    void handleWebhook(String payload, String signature);
}
