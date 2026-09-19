package com.tarotplatform.service;

import com.tarotplatform.dto.admin.CustomerSummaryResponse;
import com.tarotplatform.dto.admin.DashboardSummaryResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface AdminDashboardService {

    DashboardSummaryResponse getDashboardSummary();

    Page<CustomerSummaryResponse> getCustomers(Pageable pageable);

    CustomerSummaryResponse getCustomerDetails(Long customerId);
}
