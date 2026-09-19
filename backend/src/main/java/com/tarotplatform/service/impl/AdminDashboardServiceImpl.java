package com.tarotplatform.service.impl;

import com.tarotplatform.dto.admin.CustomerSummaryResponse;
import com.tarotplatform.dto.admin.DashboardSummaryResponse;
import com.tarotplatform.dto.admin.PopularServiceResponse;
import com.tarotplatform.dto.admin.RecentBookingResponse;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.enums.PaymentStatus;
import com.tarotplatform.enums.Role;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.PaymentRepository;
import com.tarotplatform.repository.ReviewRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final PaymentRepository paymentRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;

    @Override
    @Transactional(readOnly = true)
    public DashboardSummaryResponse getDashboardSummary() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1);

        BigDecimal totalRevenue = paymentRepository.sumAmountByStatus(PaymentStatus.SUCCESS);
        BigDecimal todayRevenue = paymentRepository.sumAmountByStatusAndDateRange(PaymentStatus.SUCCESS, startOfDay, endOfDay);

        long totalBookings = bookingRepository.count();
        long todayBookings = bookingRepository.countTodayBookings(startOfDay, endOfDay);
        long pendingBookings = bookingRepository.countByStatus(BookingStatus.PENDING_PAYMENT);
        long confirmedBookings = bookingRepository.countByStatus(BookingStatus.CONFIRMED);
        long completedBookings = bookingRepository.countByStatus(BookingStatus.COMPLETED);
        long cancelledBookings = bookingRepository.countByStatus(BookingStatus.CANCELLED);

        long totalCustomers = userRepository.countByRole(Role.CUSTOMER);
        long activeCustomers = userRepository.countActiveByRole(Role.CUSTOMER);
        long totalReaders = userRepository.countByRole(Role.READER);

        long pendingReviews = reviewRepository.countByApprovedFalse();

        List<PopularServiceResponse> popularServices = bookingRepository.findPopularServices(PageRequest.of(0, 5))
                .stream()
                .map(row -> PopularServiceResponse.builder()
                        .serviceId((Long) row[0])
                        .serviceName((String) row[1])
                        .bookingCount(((Number) row[2]).longValue())
                        .totalRevenue((BigDecimal) row[3])
                        .build())
                .collect(Collectors.toList());

        List<RecentBookingResponse> recentBookings = bookingRepository.findTop10ByOrderByCreatedAtDesc()
                .stream()
                .map(this::toRecentBookingResponse)
                .collect(Collectors.toList());

        return DashboardSummaryResponse.builder()
                .totalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO)
                .todayRevenue(todayRevenue != null ? todayRevenue : BigDecimal.ZERO)
                .totalBookings(totalBookings)
                .todayBookings(todayBookings)
                .pendingBookings(pendingBookings)
                .confirmedBookings(confirmedBookings)
                .completedBookings(completedBookings)
                .cancelledBookings(cancelledBookings)
                .totalCustomers(totalCustomers)
                .activeCustomers(activeCustomers)
                .totalReaders(totalReaders)
                .pendingReviews(pendingReviews)
                .popularServices(popularServices)
                .recentBookings(recentBookings)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<CustomerSummaryResponse> getCustomers(Pageable pageable) {
        Page<User> customerPage = userRepository.findByRole(Role.CUSTOMER, pageable);
        return customerPage.map(this::toCustomerSummaryResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public CustomerSummaryResponse getCustomerDetails(Long customerId) {
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + customerId));
        return toCustomerSummaryResponse(customer);
    }

    private CustomerSummaryResponse toCustomerSummaryResponse(User customer) {
        long totalBookings = bookingRepository.countByCustomerId(customer.getId());
        BigDecimal totalSpent = paymentRepository.sumAmountByCustomerIdAndStatus(customer.getId(), PaymentStatus.SUCCESS);
        LocalDateTime lastConsultationDate = bookingRepository.findFirstByCustomerIdOrderByScheduledStartDesc(customer.getId())
                .map(Booking::getScheduledStart)
                .orElse(null);

        return CustomerSummaryResponse.builder()
                .id(customer.getId())
                .name(customer.getName())
                .email(customer.getEmail())
                .phone(customer.getPhone())
                .active(Boolean.TRUE.equals(customer.getIsActive()))
                .createdAt(customer.getCreatedAt())
                .totalBookings(totalBookings)
                .totalSpent(totalSpent != null ? totalSpent : BigDecimal.ZERO)
                .lastConsultationDate(lastConsultationDate)
                .build();
    }

    private RecentBookingResponse toRecentBookingResponse(Booking booking) {
        return RecentBookingResponse.builder()
                .id(booking.getId())
                .bookingReference(booking.getBookingReference())
                .customerName(booking.getCustomer() != null ? booking.getCustomer().getName() : null)
                .customerEmail(booking.getCustomer() != null ? booking.getCustomer().getEmail() : null)
                .serviceName(booking.getReadingService() != null ? booking.getReadingService().getName() : null)
                .scheduledStart(booking.getScheduledStart())
                .scheduledEnd(booking.getScheduledEnd())
                .status(booking.getStatus())
                .price(booking.getPriceAtBooking())
                .createdAt(booking.getCreatedAt())
                .build();
    }
}
