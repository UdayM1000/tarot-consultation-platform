package com.tarotplatform.mapper;

import com.tarotplatform.dto.review.ReviewResponse;
import com.tarotplatform.entity.Review;
import org.springframework.stereotype.Component;

@Component
public class ReviewMapper {

    public ReviewResponse toResponse(Review review) {
        if (review == null) {
            return null;
        }
        return ReviewResponse.builder()
                .id(review.getId())
                .customerId(review.getCustomer() != null ? review.getCustomer().getId() : null)
                .customerName(review.getCustomer() != null ? review.getCustomer().getName() : null)
                .bookingId(review.getBooking() != null ? review.getBooking().getId() : null)
                .rating(review.getRating())
                .comment(review.getComment())
                .approved(review.getApproved())
                .createdAt(review.getCreatedAt())
                .build();
    }
}
