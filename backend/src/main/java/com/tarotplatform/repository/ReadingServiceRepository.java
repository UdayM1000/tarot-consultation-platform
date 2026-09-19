package com.tarotplatform.repository;

import com.tarotplatform.entity.ReadingService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReadingServiceRepository extends JpaRepository<ReadingService, Long> {

    Optional<ReadingService> findBySlug(String slug);

    boolean existsBySlug(String slug);

    List<ReadingService> findByActiveTrue();

    List<ReadingService> findByCategoryIdAndActiveTrue(Long categoryId);

    Page<ReadingService> findByActiveTrue(Pageable pageable);
}
