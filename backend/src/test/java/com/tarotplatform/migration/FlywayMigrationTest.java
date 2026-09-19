package com.tarotplatform.migration;

import com.tarotplatform.entity.ReadingService;
import com.tarotplatform.entity.ServiceCategory;
import com.tarotplatform.entity.User;
import com.tarotplatform.enums.Role;
import com.tarotplatform.repository.PlatformPolicyRepository;
import com.tarotplatform.repository.ReadingServiceRepository;
import com.tarotplatform.repository.ServiceCategoryRepository;
import com.tarotplatform.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class FlywayMigrationTest {

    @Autowired
    private ServiceCategoryRepository categoryRepository;

    @Autowired
    private ReadingServiceRepository readingServiceRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PlatformPolicyRepository platformPolicyRepository;

    @Test
    @DisplayName("Verify Flyway migrations apply cleanly and seed 3 categories")
    void shouldHaveSeededThreeCategories() {
        List<ServiceCategory> categories = categoryRepository.findAll();
        assertThat(categories).hasSize(3);
        assertThat(categories).extracting(ServiceCategory::getName)
                .containsExactlyInAnyOrder("TAROT", "RUNE", "COMBO");
    }

    @Test
    @DisplayName("Verify Flyway seeds all 10 required Tarot and Rune services with exact prices")
    void shouldHaveSeededAllTenServicesWithAccuratePricing() {
        List<ReadingService> services = readingServiceRepository.findAll();
        assertThat(services).hasSize(10);

        // 1. Yes / No Tarot (₹50)
        Optional<ReadingService> yesNo = readingServiceRepository.findBySlug("yes-no-tarot");
        assertThat(yesNo).isPresent();
        assertThat(yesNo.get().getPrice()).isEqualByComparingTo(new BigDecimal("50.00"));
        assertThat(yesNo.get().getCategory().getName()).isEqualTo("TAROT");

        // 2. General Guidance (₹50)
        Optional<ReadingService> general = readingServiceRepository.findBySlug("general-guidance");
        assertThat(general).isPresent();
        assertThat(general.get().getPrice()).isEqualByComparingTo(new BigDecimal("50.00"));

        // 3. One Situation – Detailed Question (₹80)
        Optional<ReadingService> oneSituation = readingServiceRepository.findBySlug("one-situation-detailed-question");
        assertThat(oneSituation).isPresent();
        assertThat(oneSituation.get().getPrice()).isEqualByComparingTo(new BigDecimal("80.00"));

        // 4. Detailed Love Reading (₹120)
        Optional<ReadingService> love = readingServiceRepository.findBySlug("detailed-love-reading");
        assertThat(love).isPresent();
        assertThat(love.get().getPrice()).isEqualByComparingTo(new BigDecimal("120.00"));

        // 5. Detailed Career Reading (₹120)
        Optional<ReadingService> career = readingServiceRepository.findBySlug("detailed-career-reading");
        assertThat(career).isPresent();
        assertThat(career.get().getPrice()).isEqualByComparingTo(new BigDecimal("120.00"));

        // 6. Love Messages (₹60)
        Optional<ReadingService> messages = readingServiceRepository.findBySlug("love-messages");
        assertThat(messages).isPresent();
        assertThat(messages.get().getPrice()).isEqualByComparingTo(new BigDecimal("60.00"));

        // 7. Rune Yes / No (₹50)
        Optional<ReadingService> runeYesNo = readingServiceRepository.findBySlug("rune-yes-no");
        assertThat(runeYesNo).isPresent();
        assertThat(runeYesNo.get().getPrice()).isEqualByComparingTo(new BigDecimal("50.00"));
        assertThat(runeYesNo.get().getCategory().getName()).isEqualTo("RUNE");

        // 8. Rune Guidance (₹50)
        Optional<ReadingService> runeGuidance = readingServiceRepository.findBySlug("rune-guidance");
        assertThat(runeGuidance).isPresent();
        assertThat(runeGuidance.get().getPrice()).isEqualByComparingTo(new BigDecimal("50.00"));

        // 9. Detailed Rune Reading (₹80)
        Optional<ReadingService> detailedRune = readingServiceRepository.findBySlug("detailed-rune-reading");
        assertThat(detailedRune).isPresent();
        assertThat(detailedRune.get().getPrice()).isEqualByComparingTo(new BigDecimal("80.00"));

        // 10. Tarot + Rune Confirmation (₹150)
        Optional<ReadingService> combo = readingServiceRepository.findBySlug("tarot-rune-confirmation");
        assertThat(combo).isPresent();
        assertThat(combo.get().getPrice()).isEqualByComparingTo(new BigDecimal("150.00"));
        assertThat(combo.get().getCategory().getName()).isEqualTo("COMBO");
    }

    @Test
    @DisplayName("Verify platform consultation disclaimer is seeded")
    void shouldHaveSeededPlatformDisclaimer() {
        var policy = platformPolicyRepository.findByPolicyKey("CONSULTATION_DISCLAIMER");
        assertThat(policy).isPresent();
        assertThat(policy.get().getContent()).contains("Tarot and Rune readings are guidance, not guarantees");
        assertThat(policy.get().getContent()).contains("No health questions");
        assertThat(policy.get().getContent()).contains("No legal questions");
        assertThat(policy.get().getContent()).contains("No pregnancy questions");
    }

    @Test
    @DisplayName("Verify initial admin, reader, and customer accounts are seeded")
    void shouldHaveSeededInitialUsers() {
        Optional<User> admin = userRepository.findByEmail("admin@tarotplatform.com");
        assertThat(admin).isPresent();
        assertThat(admin.get().getRoles()).contains(Role.ADMIN);

        Optional<User> reader = userRepository.findByEmail("reader@tarotplatform.com");
        assertThat(reader).isPresent();
        assertThat(reader.get().getRoles()).contains(Role.READER);

        Optional<User> customer = userRepository.findByEmail("customer@tarotplatform.com");
        assertThat(customer).isPresent();
        assertThat(customer.get().getRoles()).contains(Role.CUSTOMER);
    }
}
