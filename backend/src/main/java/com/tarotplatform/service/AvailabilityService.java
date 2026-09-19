package com.tarotplatform.service;

import com.tarotplatform.dto.booking.*;

import java.time.LocalDate;
import java.util.List;

public interface AvailabilityService {

    List<TimeSlotResponse> getAvailableSlots(Long serviceId, LocalDate date);

    ReaderAvailabilityResponse addAvailability(ReaderAvailabilityRequest request, String authEmail);

    List<ReaderAvailabilityResponse> getAvailabilities(Long readerId);

    ReaderAvailabilityResponse updateAvailability(Long id, ReaderAvailabilityRequest request, String authEmail);

    void deleteAvailability(Long id, String authEmail);

    BlockedDateResponse addBlockedDate(BlockedDateRequest request, String authEmail);

    List<BlockedDateResponse> getBlockedDates(Long readerId);

    void deleteBlockedDate(Long id, String authEmail);
}
