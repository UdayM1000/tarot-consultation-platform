package com.tarotplatform.repository;

import com.tarotplatform.entity.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByBookingIdOrderBySentAtAsc(Long bookingId);

    Page<Message> findByBookingIdOrderBySentAtDesc(Long bookingId, Pageable pageable);
}
