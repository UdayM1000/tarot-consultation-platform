package com.tarotplatform.dto.payment;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentVerificationRequest {

    @NotBlank(message = "Transaction ID is required")
    private String transactionId;

    private String orderId;

    private String paymentSignature;

    @Builder.Default
    private boolean simulateSuccess = true;
}
