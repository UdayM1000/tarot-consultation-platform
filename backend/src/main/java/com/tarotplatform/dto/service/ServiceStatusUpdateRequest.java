package com.tarotplatform.dto.service;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ServiceStatusUpdateRequest {

    @NotNull(message = "Active status is required")
    private Boolean active;
}
