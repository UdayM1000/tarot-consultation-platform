package com.tarotplatform.controller;

import com.tarotplatform.dto.review.ReviewResponse;
import com.tarotplatform.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/admin/reviews")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin Reviews", description = "Administrator review moderation and approval")
public class AdminReviewController {

    private final ReviewService reviewService;

    @GetMapping
    @Operation(summary = "Get all reviews for admin moderation")
    public ResponseEntity<Page<ReviewResponse>> getAllReviews(
            @PageableDefault(size = 20, sort = "createdAt") Pageable pageable) {
        Page<ReviewResponse> reviews = reviewService.getAllReviewsForAdmin(pageable);
        return ResponseEntity.ok(reviews);
    }

    @PutMapping("/{id}/approve")
    @Operation(summary = "Approve review for public directory")
    public ResponseEntity<ReviewResponse> approveReview(@PathVariable Long id) {
        ReviewResponse response = reviewService.approveReview(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/reject")
    @Operation(summary = "Reject/unpublish review")
    public ResponseEntity<ReviewResponse> rejectReview(@PathVariable Long id) {
        ReviewResponse response = reviewService.rejectReview(id);
        return ResponseEntity.ok(response);
    }
}
