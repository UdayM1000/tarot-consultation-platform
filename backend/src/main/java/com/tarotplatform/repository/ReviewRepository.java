package com.tarotplatform.repository;

import com.tarotplatform.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {

    Page<Review> findByApprovedTrue(Pageable pageable);

    Optional<Review> findByBookingId(Long bookingId);

    boolean existsByBookingId(Long bookingId);

    Page<Review> findByCustomerId(Long customerId, Pageable pageable);

    long countByApprovedFalse();

    long countByApprovedTrue();
}
