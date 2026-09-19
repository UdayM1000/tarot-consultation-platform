package com.tarotplatform.repository;

import com.tarotplatform.entity.ReaderAvailability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.DayOfWeek;
import java.util.List;

@Repository
public interface ReaderAvailabilityRepository extends JpaRepository<ReaderAvailability, Long> {

    List<ReaderAvailability> findByReaderId(Long readerId);

    List<ReaderAvailability> findByReaderIdAndActiveTrue(Long readerId);

    List<ReaderAvailability> findByReaderIdAndDayOfWeekAndActiveTrue(Long readerId, DayOfWeek dayOfWeek);

    List<ReaderAvailability> findByActiveTrue();
}
