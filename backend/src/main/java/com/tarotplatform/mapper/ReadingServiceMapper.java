package com.tarotplatform.mapper;

import com.tarotplatform.dto.service.CategoryResponse;
import com.tarotplatform.dto.service.ReadingServiceResponse;
import com.tarotplatform.entity.ReadingService;
import com.tarotplatform.entity.ServiceCategory;
import org.springframework.stereotype.Component;

@Component
public class ReadingServiceMapper {

    public CategoryResponse toCategoryResponse(ServiceCategory category) {
        if (category == null) {
            return null;
        }
        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .description(category.getDescription())
                .active(category.getActive())
                .build();
    }

    public ReadingServiceResponse toResponse(ReadingService service) {
        if (service == null) {
            return null;
        }
        return ReadingServiceResponse.builder()
                .id(service.getId())
                .categoryId(service.getCategory() != null ? service.getCategory().getId() : null)
                .categoryName(service.getCategory() != null ? service.getCategory().getName() : null)
                .name(service.getName())
                .slug(service.getSlug())
                .description(service.getDescription())
                .price(service.getPrice())
                .durationMinutes(service.getDurationMinutes())
                .active(service.getActive())
                .questionRequired(service.getQuestionRequired())
                .cardCountDescription(service.getCardCountDescription())
                .createdAt(service.getCreatedAt())
                .updatedAt(service.getUpdatedAt())
                .build();
    }
}
