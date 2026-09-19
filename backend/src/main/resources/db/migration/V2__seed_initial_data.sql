-- ==========================================================
-- V2__seed_initial_data.sql
-- Seed Initial Service Categories, Services, Policies, and Accounts
-- ==========================================================

-- 1. Seed Service Categories
INSERT INTO service_categories (id, name, description, active) VALUES
(1, 'TAROT', 'Tarot card readings providing intuitive wisdom and life guidance', TRUE),
(2, 'RUNE', 'Ancient Norse rune stone castings for elemental and symbolic insight', TRUE),
(3, 'COMBO', 'Synchronized Tarot and Rune combination consultations for holistic clarity', TRUE);

-- 2. Seed 10 Initial Consultation Services
INSERT INTO reading_services (id, category_id, name, slug, description, price, duration_minutes, active, question_required, card_count_description) VALUES
(1, 1, 'Yes / No Tarot', 'yes-no-tarot', '1 direct question, 3 tarot cards, clear answer, no follow-ups.', 50.00, 15, TRUE, TRUE, '3 tarot cards'),
(2, 1, 'General Guidance', 'general-guidance', 'No fixed question, 3 tarot cards, situation-based guidance.', 50.00, 20, TRUE, FALSE, '3 tarot cards'),
(3, 1, 'One Situation – Detailed Question', 'one-situation-detailed-question', '1 specific question, 6–7 tarot cards, situation, advice and outcome.', 80.00, 30, TRUE, TRUE, '6–7 tarot cards'),
(4, 1, 'Detailed Love Reading', 'detailed-love-reading', 'Feelings & connection, direction and advice, 8–9 tarot cards compulsory.', 120.00, 45, TRUE, TRUE, '8–9 tarot cards compulsory'),
(5, 1, 'Detailed Career Reading', 'detailed-career-reading', 'Career direction & growth, opportunities and guidance, 8–9 tarot cards compulsory.', 120.00, 45, TRUE, TRUE, '8–9 tarot cards compulsory'),
(6, 1, 'Love Messages', 'love-messages', '4 channeled love messages.', 60.00, 20, TRUE, FALSE, '4 channeled love messages'),
(7, 2, 'Rune Yes / No', 'rune-yes-no', '1 direct question and Rune stone guidance.', 50.00, 15, TRUE, TRUE, 'Rune stone guidance'),
(8, 2, 'Rune Guidance', 'rune-guidance', 'General guidance only, no fixed question.', 50.00, 20, TRUE, FALSE, 'Rune stone guidance'),
(9, 2, 'Detailed Rune Reading', 'detailed-rune-reading', '1 detailed question, multiple Rune stones and deep symbolic explanation.', 80.00, 30, TRUE, TRUE, 'Multiple Rune stones'),
(10, 3, 'Tarot + Rune Confirmation', 'tarot-rune-confirmation', 'Tarot reading followed by Rune Stone confirmation.', 150.00, 60, TRUE, TRUE, 'Full Tarot spread with Rune stone confirmation');

-- 3. Seed Platform Policy / Disclaimer
INSERT INTO platform_policies (id, policy_key, title, content, active) VALUES
(1, 'CONSULTATION_DISCLAIMER', 'Tarot & Rune Consultation Platform Policy & Disclaimer', 'Tarot and Rune readings are guidance, not guarantees. No health questions. No legal questions. No pregnancy questions.', TRUE);

-- 4. Seed Initial Users (Password: Password@123)
-- BCrypt hash: $2a$10$l1.CPsL6LdLOVC2S64C1VuU2yJHDqyy9pQV9w0VSLHzg9JdANLLFi
INSERT INTO users (id, name, email, phone, password, profile_image, is_active) VALUES
(1, 'Platform Administrator', 'admin@tarotplatform.com', '+919999900001', '$2a$10$l1.CPsL6LdLOVC2S64C1VuU2yJHDqyy9pQV9w0VSLHzg9JdANLLFi', NULL, TRUE),
(2, 'Master Reader Astrid', 'reader@tarotplatform.com', '+919999900002', '$2a$10$l1.CPsL6LdLOVC2S64C1VuU2yJHDqyy9pQV9w0VSLHzg9JdANLLFi', NULL, TRUE),
(3, 'Seeker Priya', 'customer@tarotplatform.com', '+919999900003', '$2a$10$l1.CPsL6LdLOVC2S64C1VuU2yJHDqyy9pQV9w0VSLHzg9JdANLLFi', NULL, TRUE);

-- 5. Seed User Roles
INSERT INTO user_roles (user_id, role) VALUES
(1, 'ADMIN'),
(2, 'READER'),
(3, 'CUSTOMER');
