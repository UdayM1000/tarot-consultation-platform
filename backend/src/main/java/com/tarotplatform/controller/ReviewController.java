package com.tarotplatform.controller;

import com.tarotplatform.dto.review.CreateReviewRequest;
import com.tarotplatform.dto.review.ReviewResponse;
import com.tarotplatform.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
@Tag(name = "Reviews", description = "Customer feedback submission and public testimonial directory")
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    @Operation(summary = "Submit review for completed consultation session")
    public ResponseEntity<ReviewResponse> createReview(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CreateReviewRequest request) {
        ReviewResponse response = reviewService.createReview(request, userDetails.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get paginated public approved reviews")
    public ResponseEntity<Page<ReviewResponse>> getApprovedReviews(
            @PageableDefault(size = 15, sort = "createdAt") Pageable pageable) {
        Page<ReviewResponse> reviews = reviewService.getApprovedReviews(pageable);
        return ResponseEntity.ok(reviews);
    }
}
