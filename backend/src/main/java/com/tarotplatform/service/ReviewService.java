package com.tarotplatform.service;

import com.tarotplatform.dto.review.CreateReviewRequest;
import com.tarotplatform.dto.review.ReviewResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReviewService {

    ReviewResponse createReview(CreateReviewRequest request, String customerEmail);

    Page<ReviewResponse> getApprovedReviews(Pageable pageable);

    ReviewResponse approveReview(Long id);

    ReviewResponse rejectReview(Long id);

    Page<ReviewResponse> getAllReviewsForAdmin(Pageable pageable);
}
