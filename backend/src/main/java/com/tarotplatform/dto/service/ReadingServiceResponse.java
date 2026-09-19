package com.tarotplatform.dto.service;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReadingServiceResponse {
    private Long id;
    private Long categoryId;
    private String categoryName;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private Integer durationMinutes;
    private Boolean active;
    private Boolean questionRequired;
    private String cardCountDescription;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
