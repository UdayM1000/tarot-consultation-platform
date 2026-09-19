package com.tarotplatform.service;

import com.tarotplatform.dto.reading.CreateReadingResultRequest;
import com.tarotplatform.dto.reading.ReadingResultResponse;
import com.tarotplatform.dto.reading.UpdateReadingResultRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReadingResultService {

    ReadingResultResponse createReadingResult(CreateReadingResultRequest request, String readerEmail);

    ReadingResultResponse updateReadingResult(Long id, UpdateReadingResultRequest request, String readerEmail);

    ReadingResultResponse getReadingByIdForCustomer(Long id, String customerEmail);

    Page<ReadingResultResponse> getCustomerReadings(String customerEmail, Pageable pageable);

    ReadingResultResponse getReadingByIdForAdmin(Long id);
}
