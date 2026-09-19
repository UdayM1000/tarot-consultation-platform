package com.tarotplatform.repository;

import com.tarotplatform.entity.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SessionRepository extends JpaRepository<Session, Long> {

    Optional<Session> findByBookingId(Long bookingId);

    Optional<Session> findByExternalSessionId(String externalSessionId);

    boolean existsByBookingId(Long bookingId);
}
