package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "reviews", indexes = {
    @Index(name = "idx_review_customer", columnList = "customer_id"),
    @Index(name = "idx_review_booking", columnList = "booking_id", unique = true),
    @Index(name = "idx_review_approved", columnList = "approved")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Review extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "customer_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_review_customer")
    )
    private User customer;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "booking_id",
        nullable = false,
        unique = true,
        foreignKey = @ForeignKey(name = "fk_review_booking")
    )
    private Booking booking;

    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "comment", columnDefinition = "TEXT")
    private String comment;

    @Column(name = "approved", nullable = false)
    @Builder.Default
    private Boolean approved = false;
}
