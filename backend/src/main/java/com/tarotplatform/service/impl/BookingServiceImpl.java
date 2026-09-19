package com.tarotplatform.service.impl;

import com.tarotplatform.dto.booking.BookingResponse;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Notification;
import com.tarotplatform.entity.ReadingService;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.NotificationType;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.BookingConflictException;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.InvalidBookingException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.BookingMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.NotificationRepository;
import com.tarotplatform.repository.ReadingServiceRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.BookingService;
import com.tarotplatform.util.BookingReferenceGenerator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final ReadingServiceRepository readingServiceRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;
    private final AuditLogRepository auditLogRepository;
    private final BookingMapper mapper;

    @Override
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public BookingResponse createBooking(String customerEmail, CreateBookingRequest request) {
        // 1. Enforce platform disclaimer acceptance
        if (!Boolean.TRUE.equals(request.getDisclaimerAccepted())) {
            throw new InvalidBookingException("Consultation disclaimer must be explicitly accepted before booking.");
        }

        // 2. Fetch customer
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer account not found"));

        // 3. Fetch reading service & verify active
        ReadingService service = readingServiceRepository.findById(request.getServiceId())
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + request.getServiceId()));

        if (!Boolean.TRUE.equals(service.getActive())) {
            throw new InvalidBookingException("Selected reading service is currently inactive");
        }

        // 4. Verify question requirement
        if (Boolean.TRUE.equals(service.getQuestionRequired())) {
            if (request.getQuestion() == null || request.getQuestion().trim().isEmpty()) {
                throw new InvalidBookingException("A specific question is required for the " + service.getName() + " consultation.");
            }
        }

        // 5. Calculate scheduled start and end
        LocalDateTime start = request.getScheduledStart();
        LocalDateTime end = start.plusMinutes(service.getDurationMinutes());

        if (start.isBefore(LocalDateTime.now())) {
            throw new InvalidBookingException("Booking slot must be scheduled in the future");
        }

        // 6. Check for double booking conflicts
        List<BookingStatus> activeStatuses = List.of(BookingStatus.CANCELLED, BookingStatus.REFUNDED);
        long conflicts = bookingRepository.countConflictingBookings(start, end, activeStatuses);
        if (conflicts > 0) {
            throw new BookingConflictException("The requested consultation slot (" + start + " to " + end + ") has already been booked. Please choose another slot.");
        }

        // 7. Lock in server-side price (never trust frontend)
        String bookingReference = BookingReferenceGenerator.generateReference();

        Booking booking = Booking.builder()
                .bookingReference(bookingReference)
                .customer(customer)
                .readingService(service)
                .scheduledStart(start)
                .scheduledEnd(end)
                .sessionType(request.getSessionType())
                .question(request.getQuestion() != null ? request.getQuestion().trim() : null)
                .additionalInformation(request.getAdditionalInformation() != null ? request.getAdditionalInformation().trim() : null)
                .priceAtBooking(service.getPrice())
                .status(BookingStatus.PENDING_PAYMENT)
                .disclaimerAccepted(true)
                .build();

        Booking saved = bookingRepository.save(booking);

        // 8. Trigger database notification
        notificationRepository.save(Notification.builder()
                .user(customer)
                .title("Booking Reserved")
                .message("Your booking " + bookingReference + " for " + service.getName() + " has been reserved. Please complete payment.")
                .type(NotificationType.BOOKING_CONFIRMED)
                .isRead(false)
                .build());

        // 9. Record audit log
        auditLogRepository.save(AuditLog.builder()
                .userId(customer.getId())
                .action("BOOKING_CREATED")
                .details("Created booking " + bookingReference + " for service ID: " + service.getId() + " [Price: ₹" + service.getPrice() + "]")
                .build());

        log.info("Successfully created booking {} for customer {}", bookingReference, customerEmail);
        return mapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<BookingResponse> getCustomerBookings(String customerEmail, Pageable pageable) {
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer account not found"));
        return bookingRepository.findByCustomerId(customer.getId(), pageable).map(mapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public BookingResponse getBookingById(Long id, String requesterEmail) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + id));

        User requester = userRepository.findByEmail(requesterEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Requester not found"));

        boolean isAuthorized = requester.getRoles().contains(Role.ADMIN)
                || requester.getRoles().contains(Role.READER)
                || booking.getCustomer().getId().equals(requester.getId());

        if (!isAuthorized) {
            throw new ForbiddenException("You do not have permission to view this booking.");
        }

        return mapper.toResponse(booking);
    }

    @Override
    @Transactional
    public BookingResponse cancelCustomerBooking(Long id, String customerEmail) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + id));

        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer account not found"));

        if (!booking.getCustomer().getId().equals(customer.getId())) {
            throw new ForbiddenException("You can only cancel your own bookings.");
        }

        if (booking.getStatus() == BookingStatus.COMPLETED) {
            throw new InvalidBookingException("Cannot cancel a consultation that has already been completed.");
        }
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new InvalidBookingException("This booking is already cancelled.");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        Booking updated = bookingRepository.save(booking);

        notificationRepository.save(Notification.builder()
                .user(customer)
                .title("Booking Cancelled")
                .message("Your booking " + booking.getBookingReference() + " has been cancelled.")
                .type(NotificationType.BOOKING_CANCELLED)
                .isRead(false)
                .build());

        auditLogRepository.save(AuditLog.builder()
                .userId(customer.getId())
                .action("BOOKING_CANCELLED")
                .details("Customer cancelled booking " + booking.getBookingReference())
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<BookingResponse> getAdminBookings(BookingStatus status, Pageable pageable) {
        if (status != null) {
            return bookingRepository.findByStatus(status, pageable).map(mapper::toResponse);
        }
        return bookingRepository.findAll(pageable).map(mapper::toResponse);
    }

    @Override
    @Transactional
    public BookingResponse confirmBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + id));

        booking.setStatus(BookingStatus.CONFIRMED);
        Booking updated = bookingRepository.save(booking);

        notificationRepository.save(Notification.builder()
                .user(booking.getCustomer())
                .title("Booking Confirmed")
                .message("Your booking " + booking.getBookingReference() + " has been confirmed.")
                .type(NotificationType.BOOKING_CONFIRMED)
                .isRead(false)
                .build());

        auditLogRepository.save(AuditLog.builder()
                .action("BOOKING_CONFIRMED")
                .details("Booking " + booking.getBookingReference() + " manually confirmed by reader/admin")
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional
    public BookingResponse completeBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + id));

        booking.setStatus(BookingStatus.COMPLETED);
        Booking updated = bookingRepository.save(booking);

        notificationRepository.save(Notification.builder()
                .user(booking.getCustomer())
                .title("Reading Completed")
                .message("Your reading session " + booking.getBookingReference() + " is completed. You can now leave a review!")
                .type(NotificationType.READING_COMPLETED)
                .isRead(false)
                .build());

        auditLogRepository.save(AuditLog.builder()
                .action("BOOKING_COMPLETED")
                .details("Booking " + booking.getBookingReference() + " marked completed")
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional
    public BookingResponse cancelAdminBooking(Long id, String reason) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + id));

        booking.setStatus(BookingStatus.CANCELLED);
        Booking updated = bookingRepository.save(booking);

        notificationRepository.save(Notification.builder()
                .user(booking.getCustomer())
                .title("Booking Cancelled by Platform")
                .message("Your booking " + booking.getBookingReference() + " was cancelled: " + (reason != null ? reason : "Administrative reason"))
                .type(NotificationType.BOOKING_CANCELLED)
                .isRead(false)
                .build());

        auditLogRepository.save(AuditLog.builder()
                .action("ADMIN_BOOKING_CANCELLED")
                .details("Booking " + booking.getBookingReference() + " cancelled by admin. Reason: " + reason)
                .build());

        return mapper.toResponse(updated);
    }
}
