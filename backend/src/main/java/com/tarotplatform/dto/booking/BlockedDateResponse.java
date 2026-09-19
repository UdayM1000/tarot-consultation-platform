package com.tarotplatform.dto.booking;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BlockedDateResponse {
    private Long id;
    private Long readerId;
    private String readerName;
    private LocalDate date;
    private String reason;
}
