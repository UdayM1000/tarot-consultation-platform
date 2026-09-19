package com.tarotplatform.service;

import com.tarotplatform.dto.payment.PaymentOrderResponse;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.entity.Booking;

public interface PaymentGatewayProvider {

    String getProviderName();

    PaymentOrderResponse createOrder(Booking booking);

    boolean verifyPayment(PaymentVerificationRequest request, Booking booking);

    void processWebhook(String payload, String signature);
}
