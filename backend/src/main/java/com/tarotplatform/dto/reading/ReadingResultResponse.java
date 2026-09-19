package com.tarotplatform.dto.reading;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReadingResultResponse {
    private Long id;
    private Long bookingId;
    private String bookingReference;
    private Long customerId;
    private String customerName;
    private String customerEmail;
    private String serviceName;
    private String summary;
    private String advice;
    private String outcome;
    private String additionalNotes;
    @Builder.Default
    private List<TarotCardDto> tarotCards = new ArrayList<>();
    @Builder.Default
    private List<RuneDto> runeReadings = new ArrayList<>();
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
