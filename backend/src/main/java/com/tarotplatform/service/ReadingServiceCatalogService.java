package com.tarotplatform.service;

import com.tarotplatform.dto.service.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface ReadingServiceCatalogService {

    Page<ReadingServiceResponse> getActiveServices(Long categoryId, Pageable pageable);

    ReadingServiceResponse getServiceById(Long id);

    ReadingServiceResponse getServiceBySlug(String slug);

    List<CategoryResponse> getAllCategories();

    ReadingServiceResponse createService(CreateReadingServiceRequest request);

    ReadingServiceResponse updateService(Long id, UpdateReadingServiceRequest request);

    void deleteService(Long id);

    ReadingServiceResponse updateServiceStatus(Long id, boolean active);
}
