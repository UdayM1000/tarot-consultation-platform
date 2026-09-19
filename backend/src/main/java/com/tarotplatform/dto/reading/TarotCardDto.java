package com.tarotplatform.dto.reading;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TarotCardDto {

    private Long id;

    @NotBlank(message = "Card name is required")
    private String cardName;

    @NotBlank(message = "Position is required")
    private String position;

    @NotBlank(message = "Interpretation is required")
    private String interpretation;
}
