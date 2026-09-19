package com.tarotplatform.service.impl;

import com.tarotplatform.dto.booking.*;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.BlockedDate;
import com.tarotplatform.entity.ReaderAvailability;
import com.tarotplatform.entity.ReadingService;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.exception.UnauthorizedException;
import com.tarotplatform.mapper.BookingMapper;
import com.tarotplatform.repository.*;
import com.tarotplatform.service.AvailabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AvailabilityServiceImpl implements AvailabilityService {

    private final ReaderAvailabilityRepository availabilityRepository;
    private final BlockedDateRepository blockedDateRepository;
    private final ReadingServiceRepository readingServiceRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final BookingMapper mapper;
    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional(readOnly = true)
    public List<TimeSlotResponse> getAvailableSlots(Long serviceId, LocalDate date) {
        ReadingService service = readingServiceRepository.findById(serviceId)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + serviceId));

        int duration = service.getDurationMinutes();
        DayOfWeek dayOfWeek = date.getDayOfWeek();

        List<ReaderAvailability> availabilities = availabilityRepository.findByActiveTrue().stream()
                .filter(a -> a.getDayOfWeek() == dayOfWeek)
                .toList();

        // If no explicit reader availabilities configured for this day, provide standard platform default hours
        if (availabilities.isEmpty()) {
            User defaultReader = userRepository.findByEmail("reader@tarotplatform.com").orElse(null);
            if (defaultReader != null && Boolean.TRUE.equals(defaultReader.getIsActive())) {
                availabilities = List.of(ReaderAvailability.builder()
                        .reader(defaultReader)
                        .dayOfWeek(dayOfWeek)
                        .startTime(LocalTime.of(9, 0))
                        .endTime(LocalTime.of(18, 0))
                        .active(true)
                        .build());
            }
        }

        List<TimeSlotResponse> slots = new ArrayList<>();
        List<BookingStatus> excludedStatuses = List.of(BookingStatus.CANCELLED, BookingStatus.REFUNDED);

        for (ReaderAvailability av : availabilities) {
            User reader = av.getReader();

            // Check if reader date is blocked
            if (blockedDateRepository.existsByReaderIdAndDate(reader.getId(), date)) {
                continue;
            }

            LocalTime current = av.getStartTime();
            LocalTime end = av.getEndTime();

            while (!current.plusMinutes(duration).isAfter(end)) {
                LocalTime slotEnd = current.plusMinutes(duration);
                LocalDateTime startDateTime = LocalDateTime.of(date, current);
                LocalDateTime endDateTime = LocalDateTime.of(date, slotEnd);

                long conflicts = bookingRepository.countConflictingBookings(
                        startDateTime, endDateTime, excludedStatuses);

                slots.add(TimeSlotResponse.builder()
                        .startTime(current)
                        .endTime(slotEnd)
                        .available(conflicts == 0)
                        .readerId(reader.getId())
                        .readerName(reader.getName())
                        .build());

                current = slotEnd;
            }
        }

        return slots;
    }

    @Override
    @Transactional
    public ReaderAvailabilityResponse addAvailability(ReaderAvailabilityRequest request, String authEmail) {
        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));

        User reader = determineTargetReader(request.getReaderId(), user);

        ReaderAvailability availability = ReaderAvailability.builder()
                .reader(reader)
                .dayOfWeek(request.getDayOfWeek())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .active(request.getActive() != null ? request.getActive() : true)
                .build();

        ReaderAvailability saved = availabilityRepository.save(availability);

        auditLogRepository.save(AuditLog.builder()
                .userId(user.getId())
                .action("AVAILABILITY_CREATED")
                .details("Created availability for reader ID " + reader.getId() + " on " + request.getDayOfWeek())
                .build());

        return mapper.toAvailabilityResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ReaderAvailabilityResponse> getAvailabilities(Long readerId) {
        List<ReaderAvailability> list = readerId != null
                ? availabilityRepository.findByReaderId(readerId)
                : availabilityRepository.findAll();
        return list.stream().map(mapper::toAvailabilityResponse).toList();
    }

    @Override
    @Transactional
    public ReaderAvailabilityResponse updateAvailability(Long id, ReaderAvailabilityRequest request, String authEmail) {
        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));

        ReaderAvailability availability = availabilityRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reader availability not found with ID: " + id));

        if (!user.getRoles().contains(Role.ADMIN) && !availability.getReader().getId().equals(user.getId())) {
            throw new UnauthorizedException("You can only modify your own availability");
        }

        availability.setDayOfWeek(request.getDayOfWeek());
        availability.setStartTime(request.getStartTime());
        availability.setEndTime(request.getEndTime());
        if (request.getActive() != null) {
            availability.setActive(request.getActive());
        }

        ReaderAvailability updated = availabilityRepository.save(availability);
        return mapper.toAvailabilityResponse(updated);
    }

    @Override
    @Transactional
    public void deleteAvailability(Long id, String authEmail) {
        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));

        ReaderAvailability availability = availabilityRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reader availability not found with ID: " + id));

        if (!user.getRoles().contains(Role.ADMIN) && !availability.getReader().getId().equals(user.getId())) {
            throw new UnauthorizedException("You can only delete your own availability");
        }

        availabilityRepository.delete(availability);
    }

    @Override
    @Transactional
    public BlockedDateResponse addBlockedDate(BlockedDateRequest request, String authEmail) {
        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));

        User reader = determineTargetReader(request.getReaderId(), user);

        BlockedDate blockedDate = BlockedDate.builder()
                .reader(reader)
                .date(request.getDate())
                .reason(request.getReason())
                .build();

        BlockedDate saved = blockedDateRepository.save(blockedDate);
        return mapper.toBlockedDateResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BlockedDateResponse> getBlockedDates(Long readerId) {
        List<BlockedDate> list = readerId != null
                ? blockedDateRepository.findByReaderId(readerId)
                : blockedDateRepository.findAll();
        return list.stream().map(mapper::toBlockedDateResponse).toList();
    }

    @Override
    @Transactional
    public void deleteBlockedDate(Long id, String authEmail) {
        User user = userRepository.findByEmail(authEmail)
                .orElseThrow(() -> new UnauthorizedException("Authenticated user not found"));

        BlockedDate blockedDate = blockedDateRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Blocked date not found with ID: " + id));

        if (!user.getRoles().contains(Role.ADMIN) && !blockedDate.getReader().getId().equals(user.getId())) {
            throw new UnauthorizedException("You can only remove your own blocked dates");
        }

        blockedDateRepository.delete(blockedDate);
    }

    private User determineTargetReader(Long readerId, User authUser) {
        if (readerId != null) {
            if (!authUser.getRoles().contains(Role.ADMIN) && !readerId.equals(authUser.getId())) {
                throw new UnauthorizedException("Cannot configure availability for another reader");
            }
            return userRepository.findById(readerId)
                    .orElseThrow(() -> new ResourceNotFoundException("Reader not found with ID: " + readerId));
        } else {
            return authUser;
        }
    }
}
