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
public class RuneDto {

    private Long id;

    @NotBlank(message = "Rune name is required")
    private String runeName;

    @NotBlank(message = "Position is required")
    private String position;

    @NotBlank(message = "Interpretation is required")
    private String interpretation;
}
