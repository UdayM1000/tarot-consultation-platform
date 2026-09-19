package com.tarotplatform.dto.reading;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateReadingResultRequest {

    @NotNull(message = "Booking ID is required")
    private Long bookingId;

    @NotBlank(message = "Reading summary is required")
    private String summary;

    @NotBlank(message = "Advice is required")
    private String advice;

    private String outcome;

    private String additionalNotes;

    @Builder.Default
    private List<TarotCardDto> tarotCards = new ArrayList<>();

    @Builder.Default
    private List<RuneDto> runeReadings = new ArrayList<>();
}
