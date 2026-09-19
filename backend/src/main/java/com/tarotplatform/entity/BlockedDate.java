package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "blocked_dates", indexes = {
    @Index(name = "idx_blocked_date_reader", columnList = "reader_id, date")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BlockedDate extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "reader_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_blocked_date_reader")
    )
    private User reader;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "reason", length = 255)
    private String reason;
}
