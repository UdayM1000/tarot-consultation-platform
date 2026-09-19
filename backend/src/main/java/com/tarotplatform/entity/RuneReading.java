package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "rune_readings", indexes = {
    @Index(name = "idx_rune_reading_result", columnList = "reading_result_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RuneReading extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "reading_result_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_rune_reading_result")
    )
    private ReadingResult readingResult;

    @Column(name = "rune_name", nullable = false, length = 100)
    private String runeName;

    @Column(name = "position", nullable = false, length = 100)
    private String position;

    @Column(name = "interpretation", columnDefinition = "TEXT", nullable = false)
    private String interpretation;
}
