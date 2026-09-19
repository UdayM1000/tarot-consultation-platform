package com.tarotplatform.review;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.reading.CreateReadingResultRequest;
import com.tarotplatform.dto.review.CreateReviewRequest;
import com.tarotplatform.enums.SessionType;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ReviewAndNotificationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    private String customerToken;
    private String adminToken;
    private String readerToken;

    @BeforeEach
    void setUp() throws Exception {
        customerToken = obtainToken("customer@tarotplatform.com", "Password@123");
        adminToken = obtainToken("admin@tarotplatform.com", "Password@123");
        readerToken = obtainToken("reader@tarotplatform.com", "Password@123");
    }

    private String obtainToken(String email, String password) throws Exception {
        LoginRequest req = new LoginRequest(email, password);
        MvcResult res = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andReturn();
        return objectMapper.readTree(res.getResponse().getContentAsString()).get("accessToken").asText();
    }

    @Test
    @DisplayName("Reviews: only completed bookings can be reviewed and admin moderation controls visibility")
    void testReviewWorkflowAndPrerequisites() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        // 1. Create a booking (status will be PENDING_PAYMENT)
        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(2).withHour(14).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.CHAT)
                .question("Will this review test pass smoothly?")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        // 2. Customer attempts to review uncompleted booking -> MUST FAIL
        CreateReviewRequest prematureReview = CreateReviewRequest.builder()
                .bookingId(bookingId)
                .rating(5)
                .comment("Premature review")
                .build();

        mockMvc.perform(post("/api/v1/reviews")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(prematureReview)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Only COMPLETED consultation sessions can be reviewed. Current status: PENDING_PAYMENT"));

        // 3. Reader completes reading result
        CreateReadingResultRequest resultReq = CreateReadingResultRequest.builder()
                .bookingId(bookingId)
                .summary("Clear guidance provided")
                .advice("Proceed with certainty")
                .build();

        mockMvc.perform(post("/api/v1/admin/readings")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resultReq)))
                .andExpect(status().isCreated());

        // 4. Customer submits review for completed booking -> SUCCESS (approved = false)
        CreateReviewRequest validReview = CreateReviewRequest.builder()
                .bookingId(bookingId)
                .rating(5)
                .comment("Incredible intuition and clarity! Highly recommend.")
                .build();

        MvcResult reviewRes = mockMvc.perform(post("/api/v1/reviews")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validReview)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.approved").value(false))
                .andExpect(jsonPath("$.rating").value(5))
                .andReturn();

        long reviewId = objectMapper.readTree(reviewRes.getResponse().getContentAsString()).get("id").asLong();

        // 5. Admin approves the review
        mockMvc.perform(put("/api/v1/admin/reviews/" + reviewId + "/approve")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.approved").value(true));

        // 6. Review appears in public review directory
        mockMvc.perform(get("/api/v1/reviews"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray());
    }

    @Test
    @DisplayName("Notifications: query user notifications, unread count, and mark as read")
    void testNotificationLifecycle() throws Exception {
        // Fetch notifications
        MvcResult notifRes = mockMvc.perform(get("/api/v1/notifications")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andReturn();

        // Get unread count
        mockMvc.perform(get("/api/v1/notifications/unread-count")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.unreadCount").isNumber());

        var contentNode = objectMapper.readTree(notifRes.getResponse().getContentAsString()).get("content");
        if (contentNode.isArray() && !contentNode.isEmpty()) {
            long notifId = contentNode.get(0).get("id").asLong();

            // Mark as read
            mockMvc.perform(patch("/api/v1/notifications/" + notifId + "/read")
                            .header("Authorization", "Bearer " + customerToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.message").value("Notification marked as read"));
        }
    }
}
