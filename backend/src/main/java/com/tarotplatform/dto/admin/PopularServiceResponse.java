package com.tarotplatform.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PopularServiceResponse {
    private Long serviceId;
    private String serviceName;
    private long bookingCount;
    private BigDecimal totalRevenue;
}
