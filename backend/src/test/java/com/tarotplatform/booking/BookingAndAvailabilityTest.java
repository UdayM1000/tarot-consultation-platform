package com.tarotplatform.booking;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tarotplatform.dto.auth.LoginRequest;
import com.tarotplatform.dto.booking.BlockedDateRequest;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.dto.booking.ReaderAvailabilityRequest;
import com.tarotplatform.enums.BookingStatus;
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

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class BookingAndAvailabilityTest {

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
    @DisplayName("Public: should fetch available slots for service on given date")
    void testGetAvailableSlots() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();
        LocalDate targetDate = LocalDate.now().plusDays(2);

        mockMvc.perform(get("/api/v1/availability")
                        .param("serviceId", service.getId().toString())
                        .param("date", targetDate.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    @DisplayName("Booking: customer can create booking and server price is locked")
    void testCreateBookingSuccess() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();
        LocalDateTime slotTime = LocalDateTime.now().plusDays(3).withHour(11).withMinute(0).withSecond(0).withNano(0);

        CreateBookingRequest request = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime)
                .sessionType(SessionType.VIDEO)
                .question("Will my business partnership flourish?")
                .disclaimerAccepted(true)
                .build();

        MvcResult result = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.bookingReference").isNotEmpty())
                .andExpect(jsonPath("$.priceAtBooking").value(50.00))
                .andExpect(jsonPath("$.status").value("PENDING_PAYMENT"))
                .andExpect(jsonPath("$.disclaimerAccepted").value(true))
                .andReturn();

        String ref = objectMapper.readTree(result.getResponse().getContentAsString()).get("bookingReference").asText();
        assertThat(ref).startsWith("TR-");
    }

    @Test
    @DisplayName("Booking: should reject booking creation if disclaimer is not accepted")
    void testRejectBookingWithoutDisclaimer() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();
        LocalDateTime slotTime = LocalDateTime.now().plusDays(3).withHour(14).withMinute(0).withSecond(0).withNano(0);

        CreateBookingRequest request = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime)
                .sessionType(SessionType.AUDIO)
                .question("Will my move go smoothly?")
                .disclaimerAccepted(false)
                .build();

        mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Consultation disclaimer must be explicitly accepted before booking."));
    }

    @Test
    @DisplayName("Double-Booking: should reject booking conflicting with an existing active slot (409 Conflict)")
    void testDoubleBookingPrevention() throws Exception {
        var service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();
        LocalDateTime slotTime = LocalDateTime.now().plusDays(4).withHour(15).withMinute(0).withSecond(0).withNano(0);

        CreateBookingRequest firstBooking = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime)
                .sessionType(SessionType.VIDEO)
                .question("First seeker question")
                .disclaimerAccepted(true)
                .build();

        // 1. Create first booking
        mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(firstBooking)))
                .andExpect(status().isCreated());

        // 2. Attempt second booking for overlapping slot (e.g. 15:05, 5 mins later)
        CreateBookingRequest overlappingBooking = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime.plusMinutes(5))
                .sessionType(SessionType.VIDEO)
                .question("Second seeker question")
                .disclaimerAccepted(true)
                .build();

        mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(overlappingBooking)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Conflict"));
    }

    @Test
    @DisplayName("Booking: customer can view own bookings and cancel upcoming booking")
    void testCustomerViewAndCancelBooking() throws Exception {
        var service = readingServiceRepository.findBySlug("rune-yes-no").orElseThrow();
        LocalDateTime slotTime = LocalDateTime.now().plusDays(5).withHour(16).withMinute(0).withSecond(0).withNano(0);

        CreateBookingRequest request = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime)
                .sessionType(SessionType.CHAT)
                .question("Rune guidance on creative project")
                .disclaimerAccepted(true)
                .build();

        MvcResult createResult = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("id").asLong();

        // View customer bookings
        mockMvc.perform(get("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray());

        // Cancel booking
        mockMvc.perform(put("/api/v1/bookings/" + bookingId + "/cancel")
                        .header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
    }

    @Test
    @DisplayName("Admin: Reader can configure availability and blocked dates")
    void testReaderAvailabilityAndBlockedDatesManagement() throws Exception {
        ReaderAvailabilityRequest availReq = ReaderAvailabilityRequest.builder()
                .dayOfWeek(DayOfWeek.FRIDAY)
                .startTime(LocalTime.of(10, 0))
                .endTime(LocalTime.of(16, 0))
                .active(true)
                .build();

        mockMvc.perform(post("/api/v1/admin/availability")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(availReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.dayOfWeek").value("FRIDAY"))
                .andExpect(jsonPath("$.active").value(true));

        BlockedDateRequest blockedReq = BlockedDateRequest.builder()
                .date(LocalDate.now().plusDays(10))
                .reason("Personal meditation retreat")
                .build();

        mockMvc.perform(post("/api/v1/admin/blocked-dates")
                        .header("Authorization", "Bearer " + readerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(blockedReq)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reason").value("Personal meditation retreat"));
    }

    @Test
    @DisplayName("Admin: Reader/Admin can confirm and complete bookings")
    void testAdminConfirmAndCompleteBooking() throws Exception {
        var service = readingServiceRepository.findBySlug("detailed-rune-reading").orElseThrow();
        LocalDateTime slotTime = LocalDateTime.now().plusDays(6).withHour(10).withMinute(0).withSecond(0).withNano(0);

        CreateBookingRequest request = CreateBookingRequest.builder()
                .serviceId(service.getId())
                .scheduledStart(slotTime)
                .sessionType(SessionType.VIDEO)
                .question("Detailed ancestral guidance")
                .disclaimerAccepted(true)
                .build();

        MvcResult createResult = mockMvc.perform(post("/api/v1/bookings")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andReturn();

        long bookingId = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("id").asLong();

        // Reader confirms booking
        mockMvc.perform(put("/api/v1/admin/bookings/" + bookingId + "/confirm")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CONFIRMED"));

        // Reader completes booking
        mockMvc.perform(put("/api/v1/admin/bookings/" + bookingId + "/complete")
                        .header("Authorization", "Bearer " + readerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("COMPLETED"));
    }
}
