package com.tarotplatform.entity;

import com.tarotplatform.enums.SessionStatus;
import com.tarotplatform.enums.SessionType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "sessions", indexes = {
    @Index(name = "idx_session_booking", columnList = "booking_id", unique = true),
    @Index(name = "idx_session_external_id", columnList = "external_session_id"),
    @Index(name = "idx_session_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Session extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "booking_id",
        nullable = false,
        unique = true,
        foreignKey = @ForeignKey(name = "fk_session_booking")
    )
    private Booking booking;

    @Enumerated(EnumType.STRING)
    @Column(name = "session_type", nullable = false, length = 30)
    private SessionType sessionType;

    @Column(name = "provider", nullable = false, length = 50)
    private String provider;

    @Column(name = "external_session_id", length = 150)
    private String externalSessionId;

    @Column(name = "join_url", length = 512)
    private String joinUrl;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    @Builder.Default
    private SessionStatus status = SessionStatus.SCHEDULED;
}
