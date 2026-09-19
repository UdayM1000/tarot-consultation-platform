package com.tarotplatform.service;

import com.tarotplatform.dto.booking.BookingResponse;
import com.tarotplatform.dto.booking.CreateBookingRequest;
import com.tarotplatform.enums.BookingStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface BookingService {

    BookingResponse createBooking(String customerEmail, CreateBookingRequest request);

    Page<BookingResponse> getCustomerBookings(String customerEmail, Pageable pageable);

    BookingResponse getBookingById(Long id, String requesterEmail);

    BookingResponse cancelCustomerBooking(Long id, String customerEmail);

    Page<BookingResponse> getAdminBookings(BookingStatus status, Pageable pageable);

    BookingResponse confirmBooking(Long id);

    BookingResponse completeBooking(Long id);

    BookingResponse cancelAdminBooking(Long id, String reason);
}
