package com.tarotplatform.service.impl;

import com.tarotplatform.dto.reading.CreateReadingResultRequest;
import com.tarotplatform.dto.reading.ReadingResultResponse;
import com.tarotplatform.dto.reading.TarotCardDto;
import com.tarotplatform.dto.reading.UpdateReadingResultRequest;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Notification;
import com.tarotplatform.entity.ReadingResult;
import com.tarotplatform.entity.RuneReading;
import com.tarotplatform.entity.TarotCardReading;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.NotificationType;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.InvalidBookingException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.ReadingResultMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.NotificationRepository;
import com.tarotplatform.repository.ReadingResultRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.ReadingResultService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReadingResultServiceImpl implements ReadingResultService {

    private final ReadingResultRepository readingResultRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;
    private final AuditLogRepository auditLogRepository;
    private final ReadingResultMapper mapper;

    @Override
    @Transactional
    public ReadingResultResponse createReadingResult(CreateReadingResultRequest request, String readerEmail) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + request.getBookingId()));

        if (readingResultRepository.existsByBookingId(booking.getId())) {
            throw new InvalidBookingException("A reading result has already been published for booking " + booking.getBookingReference());
        }

        ReadingResult readingResult = ReadingResult.builder()
                .booking(booking)
                .summary(request.getSummary().trim())
                .advice(request.getAdvice().trim())
                .outcome(request.getOutcome() != null ? request.getOutcome().trim() : null)
                .additionalNotes(request.getAdditionalNotes() != null ? request.getAdditionalNotes().trim() : null)
                .build();

        if (request.getTarotCards() != null) {
            for (TarotCardDto cardDto : request.getTarotCards()) {
                TarotCardReading card = TarotCardReading.builder()
                        .cardName(cardDto.getCardName())
                        .position(cardDto.getPosition())
                        .interpretation(cardDto.getInterpretation())
                        .build();
                readingResult.addTarotCard(card);
            }
        }

        if (request.getRuneReadings() != null) {
            for (var runeDto : request.getRuneReadings()) {
                RuneReading rune = RuneReading.builder()
                        .runeName(runeDto.getRuneName())
                        .position(runeDto.getPosition())
                        .interpretation(runeDto.getInterpretation())
                        .build();
                readingResult.addRuneReading(rune);
            }
        }

        ReadingResult saved = readingResultRepository.save(readingResult);

        // Mark booking completed
        booking.setStatus(BookingStatus.COMPLETED);
        bookingRepository.save(booking);

        // Notify customer
        notificationRepository.save(Notification.builder()
                .user(booking.getCustomer())
                .title("Your Reading is Ready!")
                .message("Your reading results for " + booking.getBookingReference() + " (" + booking.getReadingService().getName() + ") have been published.")
                .type(NotificationType.READING_COMPLETED)
                .isRead(false)
                .build());

        auditLogRepository.save(AuditLog.builder()
                .action("READING_RESULT_PUBLISHED")
                .details("Reader " + readerEmail + " published reading result for booking " + booking.getBookingReference())
                .build());

        return mapper.toResponse(saved);
    }

    @Override
    @Transactional
    public ReadingResultResponse updateReadingResult(Long id, UpdateReadingResultRequest request, String readerEmail) {
        ReadingResult result = readingResultRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading result not found with ID: " + id));

        result.setSummary(request.getSummary().trim());
        result.setAdvice(request.getAdvice().trim());
        result.setOutcome(request.getOutcome() != null ? request.getOutcome().trim() : null);
        result.setAdditionalNotes(request.getAdditionalNotes() != null ? request.getAdditionalNotes().trim() : null);

        if (request.getTarotCards() != null) {
            result.getTarotCards().clear();
            for (TarotCardDto cardDto : request.getTarotCards()) {
                TarotCardReading card = TarotCardReading.builder()
                        .cardName(cardDto.getCardName())
                        .position(cardDto.getPosition())
                        .interpretation(cardDto.getInterpretation())
                        .build();
                result.addTarotCard(card);
            }
        }

        if (request.getRuneReadings() != null) {
            result.getRuneReadings().clear();
            for (var runeDto : request.getRuneReadings()) {
                RuneReading rune = RuneReading.builder()
                        .runeName(runeDto.getRuneName())
                        .position(runeDto.getPosition())
                        .interpretation(runeDto.getInterpretation())
                        .build();
                result.addRuneReading(rune);
            }
        }

        ReadingResult updated = readingResultRepository.save(result);

        auditLogRepository.save(AuditLog.builder()
                .action("READING_RESULT_UPDATED")
                .details("Updated reading result ID " + id + " by " + readerEmail)
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public ReadingResultResponse getReadingByIdForCustomer(Long id, String customerEmail) {
        ReadingResult result = readingResultRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading result not found with ID: " + id));

        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));

        if (!result.getBooking().getCustomer().getId().equals(customer.getId())) {
            throw new ForbiddenException("You do not have permission to view another customer's reading result.");
        }

        return mapper.toResponse(result);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReadingResultResponse> getCustomerReadings(String customerEmail, Pageable pageable) {
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));

        return readingResultRepository.findByCustomerId(customer.getId(), pageable).map(mapper::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public ReadingResultResponse getReadingByIdForAdmin(Long id) {
        ReadingResult result = readingResultRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading result not found with ID: " + id));
        return mapper.toResponse(result);
    }
}
