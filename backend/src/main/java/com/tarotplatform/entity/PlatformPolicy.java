package com.tarotplatform.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "platform_policies", indexes = {
    @Index(name = "idx_policy_key", columnList = "policy_key", unique = true)
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlatformPolicy extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "policy_key", nullable = false, unique = true, length = 50)
    private String policyKey;

    @Column(name = "title", nullable = false, length = 150)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "active", nullable = false)
    @Builder.Default
    private Boolean active = true;
}
