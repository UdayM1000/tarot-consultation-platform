package com.tarotplatform.mapper;

import com.tarotplatform.dto.booking.BlockedDateResponse;
import com.tarotplatform.dto.booking.BookingResponse;
import com.tarotplatform.dto.booking.ReaderAvailabilityResponse;
import com.tarotplatform.entity.BlockedDate;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.ReaderAvailability;
import org.springframework.stereotype.Component;

@Component
public class BookingMapper {

    public BookingResponse toResponse(Booking booking) {
        if (booking == null) {
            return null;
        }
        return BookingResponse.builder()
                .id(booking.getId())
                .bookingReference(booking.getBookingReference())
                .customerId(booking.getCustomer() != null ? booking.getCustomer().getId() : null)
                .customerName(booking.getCustomer() != null ? booking.getCustomer().getName() : null)
                .customerEmail(booking.getCustomer() != null ? booking.getCustomer().getEmail() : null)
                .serviceId(booking.getReadingService() != null ? booking.getReadingService().getId() : null)
                .serviceName(booking.getReadingService() != null ? booking.getReadingService().getName() : null)
                .serviceSlug(booking.getReadingService() != null ? booking.getReadingService().getSlug() : null)
                .durationMinutes(booking.getReadingService() != null ? booking.getReadingService().getDurationMinutes() : null)
                .scheduledStart(booking.getScheduledStart())
                .scheduledEnd(booking.getScheduledEnd())
                .sessionType(booking.getSessionType())
                .question(booking.getQuestion())
                .additionalInformation(booking.getAdditionalInformation())
                .priceAtBooking(booking.getPriceAtBooking())
                .status(booking.getStatus())
                .disclaimerAccepted(booking.getDisclaimerAccepted())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .build();
    }

    public ReaderAvailabilityResponse toAvailabilityResponse(ReaderAvailability availability) {
        if (availability == null) {
            return null;
        }
        return ReaderAvailabilityResponse.builder()
                .id(availability.getId())
                .readerId(availability.getReader() != null ? availability.getReader().getId() : null)
                .readerName(availability.getReader() != null ? availability.getReader().getName() : null)
                .dayOfWeek(availability.getDayOfWeek())
                .startTime(availability.getStartTime())
                .endTime(availability.getEndTime())
                .active(availability.getActive())
                .build();
    }

    public BlockedDateResponse toBlockedDateResponse(BlockedDate blockedDate) {
        if (blockedDate == null) {
            return null;
        }
        return BlockedDateResponse.builder()
                .id(blockedDate.getId())
                .readerId(blockedDate.getReader() != null ? blockedDate.getReader().getId() : null)
                .readerName(blockedDate.getReader() != null ? blockedDate.getReader().getName() : null)
                .date(blockedDate.getDate())
                .reason(blockedDate.getReason())
                .build();
    }
}
