package com.tarotplatform.session;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.session.ChatMessageRequest;
import com.tarotplatform.dto.session.CreateSessionRequest;
import com.tarotplatform.enums.MessageType;
import com.tarotplatform.enums.SessionStatus;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class SessionAndChatTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    private String customerToken;
    private String readerToken;

    @BeforeEach
    void setUp() throws Exception {
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
        return objectMapper.readTree(res.getResponse().getContentAsString()).get("accessToken").asText();
    }

    @Test
    @DisplayName("Session & Chat: lifecycle of consultation room and real-time chat messages")
    void testSessionAndChatLifecycle() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(2).withHour(15).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.VIDEO)
                .question("Will this session test pass?")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        // 1. Get or create session
        CreateSessionRequest sessionReq = new CreateSessionRequest(bookingId, null);

        mockMvc.perform(post("/api/v1/sessions")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(sessionReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.joinUrl").isNotEmpty())
                .andExpect(jsonPath("$.externalSessionId").isNotEmpty())
                .andExpect(jsonPath("$.status").value(SessionStatus.SCHEDULED.name()));

        // 2. Start session
        mockMvc.perform(put("/api/v1/sessions/" + bookingId + "/start")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value(SessionStatus.ACTIVE.name()))
                .andExpect(jsonPath("$.startedAt").isNotEmpty());

        // 3. Customer sends chat message
        ChatMessageRequest chatReq = ChatMessageRequest.builder()
                .bookingId(bookingId)
                .message("Hello Astrid, I have joined the video room.")
                .messageType(MessageType.TEXT)
                .build();

        mockMvc.perform(post("/api/v1/chat/messages")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(chatReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Hello Astrid, I have joined the video room."));

        // 4. Reader sends response message
        ChatMessageRequest readerChatReq = ChatMessageRequest.builder()
                .bookingId(bookingId)
                .message("Welcome Priya, beginning your spread now.")
                .messageType(MessageType.TEXT)
                .build();

        mockMvc.perform(post("/api/v1/chat/messages")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(readerChatReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Welcome Priya, beginning your spread now."));

        // 5. Query chat history
        mockMvc.perform(get("/api/v1/chat/" + bookingId + "/messages")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content.length()").value(2));

        // 6. End session
        mockMvc.perform(put("/api/v1/sessions/" + bookingId + "/end")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value(SessionStatus.ENDED.name()))
                .andExpect(jsonPath("$.endedAt").isNotEmpty());
    }
}
