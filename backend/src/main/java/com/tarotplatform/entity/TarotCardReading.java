package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "tarot_card_readings", indexes = {
    @Index(name = "idx_tarot_reading_result", columnList = "reading_result_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TarotCardReading extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "reading_result_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_tarot_card_reading_result")
    )
    private ReadingResult readingResult;

    @Column(name = "card_name", nullable = false, length = 100)
    private String cardName;

    @Column(name = "position", nullable = false, length = 100)
    private String position;

    @Column(name = "interpretation", columnDefinition = "TEXT", nullable = false)
    private String interpretation;
}
