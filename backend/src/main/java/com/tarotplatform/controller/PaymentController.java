package com.tarotplatform.controller;

import com.tarotplatform.dto.payment.CreateOrderRequest;
import com.tarotplatform.dto.payment.PaymentOrderResponse;
import com.tarotplatform.dto.payment.PaymentResponse;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Consultation payment order creation, verification, and webhooks")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/create-order")
    @Operation(summary = "Initiate payment order using server-side locked price")
    public ResponseEntity<PaymentOrderResponse> createOrder(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CreateOrderRequest request) {
        PaymentOrderResponse response = paymentService.createOrder(request.getBookingId(), userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify")
    @Operation(summary = "Verify payment signature / transaction and confirm booking")
    public ResponseEntity<PaymentResponse> verifyPayment(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody PaymentVerificationRequest request) {
        PaymentResponse response = paymentService.verifyPayment(request, userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/webhook")
    @Operation(summary = "Payment gateway provider webhook endpoint")
    public ResponseEntity<Map<String, String>> webhook(
            @RequestBody String payload,
            @RequestHeader(value = "X-Razorpay-Signature", required = false) String razorpaySignature,
            @RequestHeader(value = "X-Mock-Signature", required = false) String mockSignature) {
        String signature = razorpaySignature != null ? razorpaySignature : mockSignature;
        paymentService.handleWebhook(payload, signature);
        return ResponseEntity.ok(Map.of("status", "RECEIVED"));
    }
}
