package com.tarotplatform.admin;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.payment.CreateOrderRequest;
import com.tarotplatform.dto.payment.PaymentVerificationRequest;
import com.tarotplatform.enums.SessionType;
import com.tarotplatform.repository.ReadingServiceRepository;
import com.tarotplatform.repository.UserRepository;
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

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class AdminDashboardTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    @Autowired
    private UserRepository userRepository;

    private String adminToken;
    private String customerToken;
    private String readerToken;

    @BeforeEach
    void setUp() throws Exception {
        adminToken = obtainToken("admin@tarotplatform.com", "Password@123");
        customerToken = obtainToken("customer@tarotplatform.com", "Password@123");
        readerToken = obtainToken("reader@tarotplatform.com", "Password@123");
    }

    private String obtainToken(String email, String password) throws Exception {
        LoginRequest req = new LoginRequest(email, password);
        MvcResult res = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();

        return objectMapper.readTree(res.getResponse().getContentAsString())
                .get("accessToken").asText();
    }

    @Test
    @DisplayName("Admin can view dashboard overview metrics with revenue and booking counts")
    void testAdminGetDashboardSummary() throws Exception {
        // Create a booking and pay for it to have non-zero analytics
        Long serviceId = readingServiceRepository.findBySlug("detailed-love-reading").orElseThrow().getId();
        LocalDateTime slotStart = LocalDateTime.now().plusDays(2).withHour(10).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime slotEnd = slotStart.plusMinutes(45);

        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(serviceId)
                .scheduledStart(slotStart)
                .sessionType(SessionType.CHAT)
                .question("What is my future in love?")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        Long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        // Create order and verify payment
        MvcResult orderRes = mockMvc.perform(post("/api/v1/payments/create-order")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CreateOrderRequest(bookingId))))
                .andExpect(status().isOk())
                .andReturn();

        String txnId = objectMapper.readTree(orderRes.getResponse().getContentAsString()).get("transactionId").asText();
        String orderId = objectMapper.readTree(orderRes.getResponse().getContentAsString()).get("orderId").asText();

        PaymentVerificationRequest verifyReq = PaymentVerificationRequest.builder()
                .transactionId(txnId)
                .orderId(orderId)
                .paymentSignature("sig_mock_123")
                .simulateSuccess(true)
                .build();

        mockMvc.perform(post("/api/v1/payments/verify")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(verifyReq)))
                .andExpect(status().isOk());

        // Now test dashboard summary
        mockMvc.perform(get("/api/v1/admin/dashboard")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalRevenue", greaterThanOrEqualTo(65.00)))
                .andExpect(jsonPath("$.totalBookings", greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.confirmedBookings", greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.totalCustomers", greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.totalReaders", greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.recentBookings", not(empty())))
                .andExpect(jsonPath("$.popularServices", not(empty())));
    }

    @Test
    @DisplayName("Admin can view paginated customer directory")
    void testAdminGetCustomersDirectory() throws Exception {
        mockMvc.perform(get("/api/v1/admin/customers")
                        .header("Authorization", "Bearer " + adminToken)
                        .param("page", "0")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", not(empty())))
                .andExpect(jsonPath("$.content[0].email", equalTo("customer@tarotplatform.com")))
                .andExpect(jsonPath("$.totalElements", greaterThanOrEqualTo(1)));
    }

    @Test
    @DisplayName("Admin can view single customer details")
    void testAdminGetCustomerDetails() throws Exception {
        Long customerId = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow().getId();

        mockMvc.perform(get("/api/v1/admin/customers/" + customerId)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", equalTo(customerId.intValue())))
                .andExpect(jsonPath("$.email", equalTo("customer@tarotplatform.com")))
                .andExpect(jsonPath("$.name", equalTo("Seeker Priya")));
    }

    @Test
    @DisplayName("Customer is forbidden from accessing dashboard")
    void testCustomerForbiddenFromDashboard() throws Exception {
        mockMvc.perform(get("/api/v1/admin/dashboard")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/admin/customers")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Reader is forbidden from accessing admin dashboard metrics")
    void testReaderForbiddenFromDashboard() throws Exception {
        mockMvc.perform(get("/api/v1/admin/dashboard")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/admin/customers")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Unauthenticated request to admin dashboard returns 401")
    void testUnauthenticatedForbiddenFromDashboard() throws Exception {
        mockMvc.perform(get("/api/v1/admin/dashboard"))
                .andExpect(status().isUnauthorized());
    }
}
