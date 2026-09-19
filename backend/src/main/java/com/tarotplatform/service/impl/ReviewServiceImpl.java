package com.tarotplatform.service.impl;

import com.tarotplatform.dto.review.CreateReviewRequest;
import com.tarotplatform.dto.review.ReviewResponse;
import com.tarotplatform.entity.AuditLog;
import com.tarotplatform.entity.Booking;
import com.tarotplatform.entity.Review;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.BookingStatus;
import com.tarotplatform.exception.ForbiddenException;
import com.tarotplatform.exception.InvalidBookingException;
import com.tarotplatform.exception.ResourceNotFoundException;
import com.tarotplatform.mapper.ReviewMapper;
import com.tarotplatform.repository.AuditLogRepository;
import com.tarotplatform.repository.BookingRepository;
import com.tarotplatform.repository.ReviewRepository;
import com.tarotplatform.repository.UserRepository;
import com.tarotplatform.service.ReviewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final AuditLogRepository auditLogRepository;
    private final ReviewMapper mapper;

    @Override
    @Transactional
    public ReviewResponse createReview(CreateReviewRequest request, String customerEmail) {
        Booking booking = bookingRepository.findById(request.getBookingId())
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with ID: " + request.getBookingId()));

        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));

        if (!booking.getCustomer().getId().equals(customer.getId())) {
            throw new ForbiddenException("You can only submit reviews for your own consultation bookings.");
        }

        if (booking.getStatus() != BookingStatus.COMPLETED) {
            throw new InvalidBookingException("Only COMPLETED consultation sessions can be reviewed. Current status: " + booking.getStatus());
        }

        if (reviewRepository.existsByBookingId(booking.getId())) {
            throw new InvalidBookingException("A review has already been submitted for booking " + booking.getBookingReference());
        }

        Review review = Review.builder()
                .customer(customer)
                .booking(booking)
                .rating(request.getRating())
                .comment(request.getComment().trim())
                .approved(false) // Requires admin moderation before public listing
                .build();

        Review saved = reviewRepository.save(review);

        auditLogRepository.save(AuditLog.builder()
                .userId(customer.getId())
                .action("REVIEW_SUBMITTED")
                .details("Customer submitted review for booking " + booking.getBookingReference() + " [Rating: " + request.getRating() + "/5]")
                .build());

        return mapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReviewResponse> getApprovedReviews(Pageable pageable) {
        return reviewRepository.findByApprovedTrue(pageable).map(mapper::toResponse);
    }

    @Override
    @Transactional
    public ReviewResponse approveReview(Long id) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found with ID: " + id));

        review.setApproved(true);
        Review updated = reviewRepository.save(review);

        auditLogRepository.save(AuditLog.builder()
                .action("REVIEW_APPROVED")
                .details("Admin approved review ID " + id)
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional
    public ReviewResponse rejectReview(Long id) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found with ID: " + id));

        review.setApproved(false);
        Review updated = reviewRepository.save(review);

        auditLogRepository.save(AuditLog.builder()
                .action("REVIEW_REJECTED")
                .details("Admin rejected review ID " + id)
                .build());

        return mapper.toResponse(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ReviewResponse> getAllReviewsForAdmin(Pageable pageable) {
        return reviewRepository.findAll(pageable).map(mapper::toResponse);
    }
}
