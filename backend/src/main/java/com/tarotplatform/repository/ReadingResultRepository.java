package com.tarotplatform.repository;

import com.tarotplatform.entity.ReadingResult;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReadingResultRepository extends JpaRepository<ReadingResult, Long> {

    Optional<ReadingResult> findByBookingId(Long bookingId);

    boolean existsByBookingId(Long bookingId);

    @Query("SELECT r FROM ReadingResult r WHERE r.booking.customer.id = :customerId")
    Page<ReadingResult> findByCustomerId(@Param("customerId") Long customerId, Pageable pageable);
}
