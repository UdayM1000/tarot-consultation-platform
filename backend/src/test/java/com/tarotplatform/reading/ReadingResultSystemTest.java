package com.tarotplatform.reading;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.auth.RegisterRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.reading.CreateReadingResultRequest;
import com.tarotplatform.dto.reading.RuneDto;
import com.tarotplatform.dto.reading.TarotCardDto;
import com.tarotplatform.dto.reading.UpdateReadingResultRequest;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.SessionType;
import com.tarotplatform.repository.BookingRepository;
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
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class ReadingResultSystemTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    @Autowired
    private BookingRepository bookingRepository;

    private String customerToken;
    private String readerToken;
    private String otherCustomerToken;

    @BeforeEach
    void setUp() throws Exception {
        customerToken = obtainToken("customer@tarotplatform.com", "Password@123");
        readerToken = obtainToken("reader@tarotplatform.com", "Password@123");

        // Register second customer for access control tests
        RegisterRequest otherReq = RegisterRequest.builder()
                .name("Second Customer")
                .email("other.seeker@example.com")
                .password("Password@123")
                .build();

        MvcResult otherRes = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(otherReq)))
                .andExpect(status().isCreated())
                .andReturn();
        otherCustomerToken = objectMapper.readTree(otherRes.getResponse().getContentAsString())
                .get("accessToken").asText();
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
    @DisplayName("Readings: Reader can publish result with cards/runes and mark booking completed")
    void testPublishReadingResult() throws Exception {
        var service = readingServiceRepository.findBySlug("tarot-rune-confirmation").orElseThrow();

        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(2).withHour(11).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.VIDEO)
                .question("Clarity on career shift")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        TarotCardDto card1 = TarotCardDto.builder()
                .cardName("Ace of Pentacles")
                .position("Foundation")
                .interpretation("Grounded new financial venture opening up.")
                .build();

        RuneDto rune1 = RuneDto.builder()
                .runeName("Ansuz")
                .position("Spiritual Confirmation")
                .interpretation("Divine guidance and inspired message.")
                .build();

        CreateReadingResultRequest resultReq = CreateReadingResultRequest.builder()
                .bookingId(bookingId)
                .summary("A major professional renaissance is dawning.")
                .advice("Take calculated, steady steps.")
                .outcome("Long-term prosperity.")
                .tarotCards(List.of(card1))
                .runeReadings(List.of(rune1))
                .build();

        // 1. Reader publishes reading result
        MvcResult publishRes = mockMvc.perform(post("/api/v1/admin/readings")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resultReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.summary").value("A major professional renaissance is dawning."))
                .andExpect(jsonPath("$.tarotCards[0].cardName").value("Ace of Pentacles"))
                .andExpect(jsonPath("$.runeReadings[0].runeName").value("Ansuz"))
                .andReturn();

        long readingResultId = objectMapper.readTree(publishRes.getResponse().getContentAsString()).get("id").asLong();

        // 2. Booking status must automatically be COMPLETED
        var booking = bookingRepository.findById(bookingId).orElseThrow();
        assertThat(booking.getStatus()).isEqualTo(BookingStatus.COMPLETED);

        // 3. Customer views their reading result
        mockMvc.perform(get("/api/v1/readings/" + readingResultId)
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tarotCards[0].position").value("Foundation"));

        // 4. ANOTHER customer cannot view this reading (Strict Access Control)
        mockMvc.perform(get("/api/v1/readings/" + readingResultId)
                        .header("Authorization", "Bearer " + otherCustomerToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("You do not have permission to view another customer's reading result."));
    }

    @Test
    @DisplayName("Readings: Reader can update existing reading outcome")
    void testUpdateReadingResult() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        CreateBookingRequest bookingReq = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(LocalDateTime.now().plusDays(3).withHour(10).withMinute(0).withSecond(0).withNano(0))
                .sessionType(SessionType.CHAT)
                .question("Yes or No answer needed")
                .disclaimerAccepted(true)
                .build();

        MvcResult bookingRes = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(bookingReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(bookingRes.getResponse().getContentAsString()).get("id").asLong();

        CreateReadingResultRequest resultReq = CreateReadingResultRequest.builder()
                .bookingId(bookingId)
                .summary("Clear Yes")
                .advice("Act quickly")
                .build();

        MvcResult publishRes = mockMvc.perform(post("/api/v1/admin/readings")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(resultReq)))
                .andExpect(status().isCreated())
                .andReturn();

        long readingId = objectMapper.readTree(publishRes.getResponse().getContentAsString()).get("id").asLong();

        UpdateReadingResultRequest updateReq = UpdateReadingResultRequest.builder()
                .summary("Resounding Yes with clarity")
                .advice("Trust the auspicious momentum")
                .build();

        mockMvc.perform(put("/api/v1/admin/readings/" + readingId)
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.summary").value("Resounding Yes with clarity"));
    }
}
