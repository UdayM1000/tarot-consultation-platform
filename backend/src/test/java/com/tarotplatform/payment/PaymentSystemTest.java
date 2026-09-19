package com.tarotplatform.payment;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.payment.CreateOrderRequest;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.PaymentStatus;
import com.tarotplatform.enums.SessionType;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.PaymentRepository;
import com.tarotplatform.repository.ReadingServiceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class PaymentSystemTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    private String customerToken;

    @BeforeEach
    void setUp() throws Exception {
        LoginRequest req = new LoginRequest("customer@tarotplatform.com", "Password@123");
        MvcResult res = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();
        customerToken = objectMapper.readTree(res.getResponse().getContentAsString()).get("accessToken").asText();
    }

    @Test
    @DisplayName("Payment: should create order with server-locked price and verify payment to confirm booking")
    void testCreateOrderAndVerifyPayment() throws Exception {
        var service = readingServiceRepository.findBySlug("general-guidance").orElseThrow();

        // 1. Create a booking
        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(2).withHour(12).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.VIDEO)
                .question("Seeking general life direction")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        // 2. Create payment order
        CreateOrderRequest orderReq = new CreateOrderRequest(bookingId);

        MvcResult orderRes = mockMvc.perform(post("/api/v1/payments/create-order")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(orderReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.orderId").isNotEmpty())
                .andExpect(jsonPath("$.transactionId").isNotEmpty())
                .andExpect(jsonPath("$.amount").value(50.00))
                .andExpect(jsonPath("$.currency").value("INR"))
                .andExpect(jsonPath("$.provider").value("MOCK"))
                .andReturn();

        String txnId = objectMapper.readTree(orderRes.getResponse().getContentAsString()).get("transactionId").asText();

        // Check payment record in DB
        var payment = paymentRepository.findByTransactionId(txnId).orElseThrow();
        assertThat(payment.getStatus()).isEqualTo(PaymentStatus.INITIATED);

        // 3. Verify payment
        PaymentVerificationRequest verifyReq = PaymentVerificationRequest.builder()
                .transactionId(txnId)
                .orderId(objectMapper.readTree(orderRes.getResponse().getContentAsString()).get("orderId").asText())
                .paymentSignature("mock_valid_signature_123")
                .simulateSuccess(true)
                .build();

        mockMvc.perform(post("/api/v1/payments/verify")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(verifyReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SUCCESS"))
                .andExpect(jsonPath("$.amount").value(50.00));

        // 4. Assert booking status updated to CONFIRMED
        var updatedBooking = bookingRepository.findById(bookingId).orElseThrow();
        assertThat(updatedBooking.getStatus()).isEqualTo(BookingStatus.CONFIRMED);
    }

    @Test
    @DisplayName("Payment: should handle failed payment verification")
    void testFailedPaymentVerification() throws Exception {
        var service = readingServiceRepository.findBySlug("love-messages").orElseThrow();

        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(3).withHour(13).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.AUDIO)
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        CreateOrderRequest orderReq = new CreateOrderRequest(bookingId);
        MvcResult orderRes = mockMvc.perform(post("/api/v1/payments/create-order")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(orderReq)))
                .andExpect(status().isOk())
                .andReturn();

        String txnId = objectMapper.readTree(orderRes.getResponse().getContentAsString()).get("transactionId").asText();

        PaymentVerificationRequest failedVerifyReq = PaymentVerificationRequest.builder()
                .transactionId(txnId)
                .simulateSuccess(false)
                .build();

        mockMvc.perform(post("/api/v1/payments/verify")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(failedVerifyReq)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Bad Request"));

        var payment = paymentRepository.findByTransactionId(txnId).orElseThrow();
        assertThat(payment.getStatus()).isEqualTo(PaymentStatus.FAILED);
    }

    @Test
    @DisplayName("Webhook: public webhook receiver accepts payload")
    void testPaymentWebhook() throws Exception {
        String payload = "{\"event\": \"payment.authorized\", \"entity\": {\"id\": \"pay_test_001\"}}";

        mockMvc.perform(post("/api/v1/payments/webhook")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload)
                        .header("X-Mock-Signature", "sig_test_123"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("RECEIVED"));
    }
}
