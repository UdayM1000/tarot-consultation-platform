package com.tarotplatform.controller;

import com.tarotplatform.dto.admin.CustomerSummaryResponse;
import com.tarotplatform.dto.admin.DashboardSummaryResponse;
import com.tarotplatform.service.AdminDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin - Dashboard & Analytics", description = "Admin platform analytics, revenue KPIs, and customer management")
@SecurityRequirement(name = "bearerAuth")
public class AdminDashboardController {

    private final AdminDashboardService dashboardService;

    @GetMapping("/dashboard")
    @Operation(summary = "Get admin dashboard overview metrics, revenues, and recent activity")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary() {
        DashboardSummaryResponse summary = dashboardService.getDashboardSummary();
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/customers")
    @Operation(summary = "Get paginated customer directory with booking statistics and lifetime spend")
    public ResponseEntity<Page<CustomerSummaryResponse>> getCustomers(
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<CustomerSummaryResponse> customers = dashboardService.getCustomers(pageable);
        return ResponseEntity.ok(customers);
    }

    @GetMapping("/customers/{id}")
    @Operation(summary = "Get customer details with booking history summary")
    public ResponseEntity<CustomerSummaryResponse> getCustomerDetails(@PathVariable Long id) {
        CustomerSummaryResponse customer = dashboardService.getCustomerDetails(id);
        return ResponseEntity.ok(customer);
    }
}
