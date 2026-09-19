package com.tarotplatform.repository;

import com.tarotplatform.entity.Booking;
import com.tarotplatform.enums.BookingStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {

    Optional<Booking> findByBookingReference(String bookingReference);

    boolean existsByBookingReference(String bookingReference);

    Page<Booking> findByCustomerId(Long customerId, Pageable pageable);

    Page<Booking> findByStatus(BookingStatus status, Pageable pageable);

    @Query("""
        SELECT b FROM Booking b
        WHERE b.status NOT IN :excludedStatuses
        AND b.scheduledStart < :end
        AND b.scheduledEnd > :start
    """)
    List<Booking> findConflictingBookings(
        @Param("start") LocalDateTime start,
        @Param("end") LocalDateTime end,
        @Param("excludedStatuses") Collection<BookingStatus> excludedStatuses
    );

    @Query("""
        SELECT COUNT(b) FROM Booking b
        WHERE b.status NOT IN :excludedStatuses
        AND b.scheduledStart < :end
        AND b.scheduledEnd > :start
    """)
    long countConflictingBookings(
        @Param("start") LocalDateTime start,
        @Param("end") LocalDateTime end,
        @Param("excludedStatuses") Collection<BookingStatus> excludedStatuses
    );

    @Query("SELECT COUNT(b) FROM Booking b WHERE b.scheduledStart >= :startOfDay AND b.scheduledStart < :endOfDay")
    long countTodayBookings(@Param("startOfDay") LocalDateTime startOfDay, @Param("endOfDay") LocalDateTime endOfDay);

    long countByStatus(BookingStatus status);

    long countByCustomerId(Long customerId);

    Optional<Booking> findFirstByCustomerIdOrderByScheduledStartDesc(Long customerId);

    List<Booking> findTop10ByOrderByCreatedAtDesc();

    @Query("""
        SELECT b.readingService.id, b.readingService.name, COUNT(b), COALESCE(SUM(b.priceAtBooking), 0)
        FROM Booking b
        WHERE b.status != com.tarotplatform.enums.BookingStatus.CANCELLED
        GROUP BY b.readingService.id, b.readingService.name
        ORDER BY COUNT(b) DESC
    """)
    List<Object[]> findPopularServices(Pageable pageable);
}
