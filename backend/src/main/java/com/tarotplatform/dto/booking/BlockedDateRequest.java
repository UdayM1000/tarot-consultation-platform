package com.tarotplatform.dto.booking;

import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BlockedDateRequest {

    private Long readerId;

    @NotNull(message = "Date is required")
    @FutureOrPresent(message = "Blocked date cannot be in the past")
    private LocalDate date;

    @Size(max = 255, message = "Reason must not exceed 255 characters")
    private String reason;
}
