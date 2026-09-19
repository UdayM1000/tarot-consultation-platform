package com.tarotplatform.repository;

import com.tarotplatform.entity.TarotCardReading;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TarotCardReadingRepository extends JpaRepository<TarotCardReading, Long> {

    List<TarotCardReading> findByReadingResultId(Long readingResultId);
}
