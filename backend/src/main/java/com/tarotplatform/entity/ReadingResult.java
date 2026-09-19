package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "reading_results", indexes = {
    @Index(name = "idx_reading_result_booking", columnList = "booking_id", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReadingResult extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "booking_id",
        nullable = false,
        unique = true,
        foreignKey = @ForeignKey(name = "fk_reading_result_booking")
    )
    private Booking booking;

    @Column(name = "summary", columnDefinition = "TEXT", nullable = false)
    private String summary;

    @Column(name = "advice", columnDefinition = "TEXT", nullable = false)
    private String advice;

    @Column(name = "outcome", columnDefinition = "TEXT")
    private String outcome;

    @Column(name = "additional_notes", columnDefinition = "TEXT")
    private String additionalNotes;

    @OneToMany(mappedBy = "readingResult", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<TarotCardReading> tarotCards = new ArrayList<>();

    @OneToMany(mappedBy = "readingResult", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RuneReading> runeReadings = new ArrayList<>();

    public void addTarotCard(TarotCardReading card) {
        tarotCards.add(card);
        card.setReadingResult(this);
    }

    public void addRuneReading(RuneReading rune) {
        runeReadings.add(rune);
        rune.setReadingResult(this);
    }
}
