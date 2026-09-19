package com.tarotplatform.repository;

import com.tarotplatform.entity.BlockedDate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BlockedDateRepository extends JpaRepository<BlockedDate, Long> {

    List<BlockedDate> findByReaderId(Long readerId);

    Optional<BlockedDate> findByReaderIdAndDate(Long readerId, LocalDate date);

    boolean existsByReaderIdAndDate(Long readerId, LocalDate date);

    List<BlockedDate> findByReaderIdAndDateBetween(Long readerId, LocalDate startDate, LocalDate endDate);
}
