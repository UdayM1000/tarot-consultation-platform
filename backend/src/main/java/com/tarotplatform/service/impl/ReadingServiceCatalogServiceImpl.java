package com.tarotplatform.service.impl;

import com.tarotplatform.dto.service.*;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.ReadingService;
import com.tarotplatform.entity.ServiceCategory;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.ReadingServiceMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.ReadingServiceRepository;
import com.tarotplatform.repository.ServiceCategoryRepository;
import com.tarotplatform.service.ReadingServiceCatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReadingServiceCatalogServiceImpl implements ReadingServiceCatalogService {

    private final ReadingServiceRepository readingServiceRepository;
    private final ServiceCategoryRepository categoryRepository;
    private final ReadingServiceMapper mapper;
    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<ReadingServiceResponse> getActiveServices(Long categoryId, Pageable pageable) {
        if (categoryId != null) {
            List<ReadingService> services = readingServiceRepository.findByCategoryIdAndActiveTrue(categoryId);
            int start = (int) pageable.getOffset();
            int end = Math.min((start + pageable.getPageSize()), services.size());
            List<ReadingServiceResponse> pagedList = services.subList(Math.min(start, services.size()), end)
                    .stream()
                    .map(mapper::toResponse)
                    .toList();
            return new PageImpl<>(pagedList, pageable, services.size());
        } else {
            return readingServiceRepository.findByActiveTrue(pageable).map(mapper::toResponse);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public ReadingServiceResponse getServiceById(Long id) {
        ReadingService service = readingServiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + id));
        return mapper.toResponse(service);
    }

    @Override
    @Transactional(readOnly = true)
    public ReadingServiceResponse getServiceBySlug(String slug) {
        ReadingService service = readingServiceRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with slug: " + slug));
        return mapper.toResponse(service);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findByActiveTrue().stream()
                .map(mapper::toCategoryResponse)
                .toList();
    }

    @Override
    @Transactional
    public ReadingServiceResponse createService(CreateReadingServiceRequest request) {
        String slug = request.getSlug().trim().toLowerCase();
        if (readingServiceRepository.existsBySlug(slug)) {
            throw new IllegalArgumentException("A reading service with slug '" + slug + "' already exists");
        }

        ServiceCategory category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new ResourceNotFoundException("Service category not found with ID: " + request.getCategoryId()));

        ReadingService service = ReadingService.builder()
                .category(category)
                .name(request.getName().trim())
                .slug(slug)
                .description(request.getDescription().trim())
                .price(request.getPrice())
                .durationMinutes(request.getDurationMinutes())
                .active(true)
                .questionRequired(request.getQuestionRequired() != null ? request.getQuestionRequired() : true)
                .cardCountDescription(request.getCardCountDescription())
                .build();

        ReadingService saved = readingServiceRepository.save(service);

        auditLogRepository.save(AuditLog.builder()
                .action("SERVICE_CREATED")
                .details("Created reading service: " + saved.getName() + " [Price: ₹" + saved.getPrice() + "]")
                .build());

        return mapper.toResponse(saved);
    }

    @Override
    @Transactional
    public ReadingServiceResponse updateService(Long id, UpdateReadingServiceRequest request) {
        ReadingService service = readingServiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + id));

        String slug = request.getSlug().trim().toLowerCase();
        if (!service.getSlug().equalsIgnoreCase(slug) && readingServiceRepository.existsBySlug(slug)) {
            throw new IllegalArgumentException("A reading service with slug '" + slug + "' already exists");
        }

        if (request.getCategoryId() != null && !request.getCategoryId().equals(service.getCategory().getId())) {
            ServiceCategory category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new ResourceNotFoundException("Service category not found with ID: " + request.getCategoryId()));
            service.setCategory(category);
        }

        service.setName(request.getName().trim());
        service.setSlug(slug);
        service.setDescription(request.getDescription().trim());
        service.setPrice(request.getPrice());
        service.setDurationMinutes(request.getDurationMinutes());
        if (request.getActive() != null) {
            service.setActive(request.getActive());
        }
        if (request.getQuestionRequired() != null) {
            service.setQuestionRequired(request.getQuestionRequired());
        }
        if (request.getCardCountDescription() != null) {
            service.setCardCountDescription(request.getCardCountDescription());
        }

        ReadingService updated = readingServiceRepository.save(service);

        auditLogRepository.save(AuditLog.builder()
                .action("SERVICE_UPDATED")
                .details("Updated reading service ID: " + id + " [Price: ₹" + updated.getPrice() + "]")
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional
    public void deleteService(Long id) {
        ReadingService service = readingServiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + id));

        // Soft delete / deactivate to preserve historical integrity
        service.setActive(false);
        readingServiceRepository.save(service);

        auditLogRepository.save(AuditLog.builder()
                .action("SERVICE_DEACTIVATED")
                .details("Deactivated reading service ID: " + id)
                .build());
    }

    @Override
    @Transactional
    public ReadingServiceResponse updateServiceStatus(Long id, boolean active) {
        ReadingService service = readingServiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reading service not found with ID: " + id));

        service.setActive(active);
        ReadingService updated = readingServiceRepository.save(service);

        auditLogRepository.save(AuditLog.builder()
                .action("SERVICE_STATUS_CHANGED")
                .details("Set reading service ID: " + id + " active status to " + active)
                .build());

        return mapper.toResponse(updated);
    }
}
