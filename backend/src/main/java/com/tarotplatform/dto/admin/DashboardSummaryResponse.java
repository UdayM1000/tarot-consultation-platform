package com.tarotplatform.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryResponse {
    private BigDecimal totalRevenue;
    private BigDecimal todayRevenue;
    private long totalBookings;
    private long todayBookings;
    private long pendingBookings;
    private long confirmedBookings;
    private long completedBookings;
    private long cancelledBookings;
    private long totalCustomers;
    private long activeCustomers;
    private long totalReaders;
    private long pendingReviews;
    private List<PopularServiceResponse> popularServices;
    private List<RecentBookingResponse> recentBookings;
}
