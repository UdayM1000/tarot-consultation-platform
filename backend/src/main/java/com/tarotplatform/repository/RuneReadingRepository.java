package com.tarotplatform.repository;

import com.tarotplatform.entity.RuneReading;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RuneReadingRepository extends JpaRepository<RuneReading, Long> {

    List<RuneReading> findByReadingResultId(Long readingResultId);
}
