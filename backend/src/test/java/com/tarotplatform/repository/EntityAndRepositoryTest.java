package com.tarotplatform.repository;

import com.tarotplatform.entity.*;
import com.tarotplatform.enums.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class EntityAndRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private ReaderAvailabilityRepository availabilityRepository;

    @Autowired
    private BlockedDateRepository blockedDateRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private ReadingResultRepository readingResultRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private SessionRepository sessionRepository;

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private AuditLogRepository auditLogRepository;

    @Test
    @DisplayName("Should persist and query User with multiple roles")
    void testUserPersistence() {
        User user = User.builder()
                .name("Alex River")
                .email("alex.river@example.com")
                .phone("+919876543210")
                .password("$2a$10$dummyhashedpassword")
                .isActive(true)
                .roles(Set.of(Role.CUSTOMER, Role.READER))
                .build();

        User saved = userRepository.save(user);
        assertThat(saved.getId()).isNotNull();

        Optional<User> fetched = userRepository.findByEmail("alex.river@example.com");
        assertThat(fetched).isPresent();
        assertThat(fetched.get().getRoles()).containsExactlyInAnyOrder(Role.CUSTOMER, Role.READER);
        assertThat(fetched.get().getCreatedAt()).isNotNull();
        assertThat(fetched.get().getUpdatedAt()).isNotNull();
    }

    @Test
    @DisplayName("Should persist Booking and detect overlapping booking conflicts")
    void testBookingAndConflictDetection() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();
        ReadingService service = readingServiceRepository.findBySlug("yes-no-tarot").orElseThrow();

        LocalDateTime start = LocalDateTime.now().plusDays(1).withHour(10).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime end = start.plusMinutes(service.getDurationMinutes());

        Booking booking = Booking.builder()
                .bookingReference("TR-2026-999001")
                .customer(customer)
                .readingService(service)
                .scheduledStart(start)
                .scheduledEnd(end)
                .sessionType(SessionType.VIDEO)
                .question("Will my business expansion succeed this quarter?")
                .additionalInformation("Looking for practical milestones.")
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.CONFIRMED)
                .disclaimerAccepted(true)
                .build();

        Booking savedBooking = bookingRepository.save(booking);
        assertThat(savedBooking.getId()).isNotNull();
        assertThat(savedBooking.getPriceAtBooking()).isEqualByComparingTo(new BigDecimal("50.00"));

        // Check for conflicting overlapping slot: e.g. 10:05 to 10:20
        List<Booking> conflicts = bookingRepository.findConflictingBookings(
                start.plusMinutes(5),
                end.plusMinutes(10),
                List.of(BookingStatus.CANCELLED)
        );
        assertThat(conflicts).isNotEmpty();
        assertThat(conflicts.get(0).getBookingReference()).isEqualTo("TR-2026-999001");

        // Non-overlapping slot: e.g. 11:00 to 11:15
        List<Booking> nonConflicts = bookingRepository.findConflictingBookings(
                end.plusHours(1),
                end.plusHours(2),
                List.of(BookingStatus.CANCELLED)
        );
        assertThat(nonConflicts).isEmpty();
    }

    @Test
    @DisplayName("Should persist Reader Availability and Blocked Dates")
    void testAvailabilityAndBlockedDates() {
        User reader = userRepository.findByEmail("reader@tarotplatform.com").orElseThrow();

        ReaderAvailability availability = ReaderAvailability.builder()
                .reader(reader)
                .dayOfWeek(DayOfWeek.MONDAY)
                .startTime(LocalTime.of(9, 0))
                .endTime(LocalTime.of(17, 0))
                .active(true)
                .build();
        availabilityRepository.save(availability);

        List<ReaderAvailability> mondaySlots = availabilityRepository.findByReaderIdAndDayOfWeekAndActiveTrue(
                reader.getId(), DayOfWeek.MONDAY);
        assertThat(mondaySlots).hasSize(1);
        assertThat(mondaySlots.get(0).getStartTime()).isEqualTo(LocalTime.of(9, 0));

        BlockedDate blockedDate = BlockedDate.builder()
                .reader(reader)
                .date(LocalDate.now().plusDays(5))
                .reason("Attending Tarot Guild Symposium")
                .build();
        blockedDateRepository.save(blockedDate);

        boolean isBlocked = blockedDateRepository.existsByReaderIdAndDate(reader.getId(), LocalDate.now().plusDays(5));
        assertThat(isBlocked).isTrue();
    }

    @Test
    @DisplayName("Should persist Payment and aggregate revenues")
    void testPaymentPersistenceAndRevenue() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();
        ReadingService service = readingServiceRepository.findBySlug("detailed-love-reading").orElseThrow();

        Booking booking = bookingRepository.save(Booking.builder()
                .bookingReference("TR-2026-999002")
                .customer(customer)
                .readingService(service)
                .scheduledStart(LocalDateTime.now().plusDays(2))
                .scheduledEnd(LocalDateTime.now().plusDays(2).plusMinutes(45))
                .sessionType(SessionType.AUDIO)
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.CONFIRMED)
                .disclaimerAccepted(true)
                .build());

        Payment payment = Payment.builder()
                .booking(booking)
                .transactionId("txn_test_12345678")
                .provider("MOCK")
                .amount(service.getPrice())
                .currency("INR")
                .status(PaymentStatus.SUCCESS)
                .build();
        paymentRepository.save(payment);

        Optional<Payment> fetchedPayment = paymentRepository.findByTransactionId("txn_test_12345678");
        assertThat(fetchedPayment).isPresent();
        assertThat(fetchedPayment.get().getAmount()).isEqualByComparingTo(new BigDecimal("120.00"));

        BigDecimal totalRevenue = paymentRepository.sumAmountByStatus(PaymentStatus.SUCCESS);
        assertThat(totalRevenue).isGreaterThanOrEqualTo(new BigDecimal("120.00"));
    }

    @Test
    @DisplayName("Should persist ReadingResult with cascading Tarot Cards and Rune Stones")
    void testReadingResultWithCardsAndRunes() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();
        ReadingService service = readingServiceRepository.findBySlug("tarot-rune-confirmation").orElseThrow();

        Booking booking = bookingRepository.save(Booking.builder()
                .bookingReference("TR-2026-999003")
                .customer(customer)
                .readingService(service)
                .scheduledStart(LocalDateTime.now().minusDays(1))
                .scheduledEnd(LocalDateTime.now().minusDays(1).plusHours(1))
                .sessionType(SessionType.VIDEO)
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.COMPLETED)
                .disclaimerAccepted(true)
                .build());

        ReadingResult result = ReadingResult.builder()
                .booking(booking)
                .summary("A major transformative journey is opening with clarity.")
                .advice("Embrace patience and trust internal intuition.")
                .outcome("Long-term prosperity and balanced equilibrium.")
                .additionalNotes("Seeker resonated strongly with the High Priestess archetype.")
                .build();

        TarotCardReading card1 = TarotCardReading.builder()
                .cardName("The Fool")
                .position("Present Energy")
                .interpretation("New beginnings, leap of faith, untethered potential.")
                .build();
        result.addTarotCard(card1);

        RuneReading rune1 = RuneReading.builder()
                .runeName("Fehu")
                .position("Confirmation Stone")
                .interpretation("Abundance, realized gains, creative energy.")
                .build();
        result.addRuneReading(rune1);

        ReadingResult savedResult = readingResultRepository.save(result);
        assertThat(savedResult.getId()).isNotNull();

        Optional<ReadingResult> fetched = readingResultRepository.findByBookingId(booking.getId());
        assertThat(fetched).isPresent();
        assertThat(fetched.get().getTarotCards()).hasSize(1);
        assertThat(fetched.get().getTarotCards().get(0).getCardName()).isEqualTo("The Fool");
        assertThat(fetched.get().getRuneReadings()).hasSize(1);
        assertThat(fetched.get().getRuneReadings().get(0).getRuneName()).isEqualTo("Fehu");
    }

    @Test
    @DisplayName("Should persist Review for completed booking")
    void testReviewPersistence() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();
        ReadingService service = readingServiceRepository.findBySlug("one-situation-detailed-question").orElseThrow();

        Booking booking = bookingRepository.save(Booking.builder()
                .bookingReference("TR-2026-999004")
                .customer(customer)
                .readingService(service)
                .scheduledStart(LocalDateTime.now().minusDays(2))
                .scheduledEnd(LocalDateTime.now().minusDays(2).plusMinutes(30))
                .sessionType(SessionType.CHAT)
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.COMPLETED)
                .disclaimerAccepted(true)
                .build());

        Review review = Review.builder()
                .customer(customer)
                .booking(booking)
                .rating(5)
                .comment("Remarkable clarity and deeply reassuring guidance.")
                .approved(true)
                .build();
        Review saved = reviewRepository.save(review);
        assertThat(saved.getId()).isNotNull();

        Page<Review> approvedReviews = reviewRepository.findByApprovedTrue(PageRequest.of(0, 10));
        assertThat(approvedReviews.getContent()).isNotEmpty();
    }

    @Test
    @DisplayName("Should persist Notification and query unread count")
    void testNotificationPersistence() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();

        Notification notif = Notification.builder()
                .user(customer)
                .title("Booking Confirmed")
                .message("Your session TR-2026-000001 has been confirmed.")
                .type(NotificationType.BOOKING_CONFIRMED)
                .isRead(false)
                .build();
        notificationRepository.save(notif);

        long unreadCount = notificationRepository.countByUserIdAndIsReadFalse(customer.getId());
        assertThat(unreadCount).isGreaterThanOrEqualTo(1);
    }

    @Test
    @DisplayName("Should persist Session and Chat Message")
    void testSessionAndChatMessage() {
        User customer = userRepository.findByEmail("customer@tarotplatform.com").orElseThrow();
        ReadingService service = readingServiceRepository.findBySlug("general-guidance").orElseThrow();

        Booking booking = bookingRepository.save(Booking.builder()
                .bookingReference("TR-2026-999005")
                .customer(customer)
                .readingService(service)
                .scheduledStart(LocalDateTime.now().plusDays(3))
                .scheduledEnd(LocalDateTime.now().plusDays(3).plusMinutes(20))
                .sessionType(SessionType.CHAT)
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.CONFIRMED)
                .disclaimerAccepted(true)
                .build());

        Session session = Session.builder()
                .booking(booking)
                .sessionType(SessionType.CHAT)
                .provider("INTERNAL_WEBSOCKET")
                .status(SessionStatus.SCHEDULED)
                .build();
        sessionRepository.save(session);
        assertThat(sessionRepository.findByBookingId(booking.getId())).isPresent();

        Message message = Message.builder()
                .booking(booking)
                .sender(customer)
                .message("Hello, looking forward to our session.")
                .messageType(MessageType.TEXT)
                .build();
        messageRepository.save(message);

        List<Message> messages = messageRepository.findByBookingIdOrderBySentAtAsc(booking.getId());
        assertThat(messages).hasSize(1);
        assertThat(messages.get(0).getMessage()).isEqualTo("Hello, looking forward to our session.");
    }

    @Test
    @DisplayName("Should persist and retrieve AuditLog")
    void testAuditLog() {
        AuditLog log = AuditLog.builder()
                .userId(1L)
                .action("SERVICE_PRICE_UPDATED")
                .details("Service ID 1 price adjusted")
                .ipAddress("127.0.0.1")
                .build();
        auditLogRepository.save(log);

        Page<AuditLog> logs = auditLogRepository.findAllByOrderByCreatedAtDesc(PageRequest.of(0, 10));
        assertThat(logs.getContent()).isNotEmpty();
        assertThat(logs.getContent().get(0).getAction()).isEqualTo("SERVICE_PRICE_UPDATED");
    }
}
