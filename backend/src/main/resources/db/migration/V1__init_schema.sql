-- ==========================================================
-- V1__init_schema.sql
-- Production DDL for Tarot & Rune Consultation Platform
-- ==========================================================

-- 1. Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    profile_image VARCHAR(512),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX idx_users_email ON users(email);

-- 2. User Roles table (ElementCollection)
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role VARCHAR(30) NOT NULL,
    PRIMARY KEY (user_id, role),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Service Categories
CREATE TABLE IF NOT EXISTS service_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_category_name UNIQUE (name)
);

-- 4. Reading Services
CREATE TABLE IF NOT EXISTS reading_services (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(160) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    question_required BOOLEAN NOT NULL DEFAULT TRUE,
    card_count_description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_reading_service_slug UNIQUE (slug),
    CONSTRAINT fk_reading_service_category FOREIGN KEY (category_id) REFERENCES service_categories(id)
);

CREATE INDEX idx_reading_service_slug ON reading_services(slug);
CREATE INDEX idx_reading_service_category ON reading_services(category_id);

-- 5. Bookings
CREATE TABLE IF NOT EXISTS bookings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(32) NOT NULL,
    customer_id BIGINT NOT NULL,
    reading_service_id BIGINT NOT NULL,
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP NOT NULL,
    session_type VARCHAR(30) NOT NULL,
    question TEXT,
    additional_information TEXT,
    price_at_booking DECIMAL(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING_PAYMENT',
    disclaimer_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_booking_reference UNIQUE (booking_reference),
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_booking_service FOREIGN KEY (reading_service_id) REFERENCES reading_services(id)
);

CREATE INDEX idx_booking_reference ON bookings(booking_reference);
CREATE INDEX idx_booking_customer ON bookings(customer_id);
CREATE INDEX idx_booking_service ON bookings(reading_service_id);
CREATE INDEX idx_booking_scheduled_times ON bookings(scheduled_start, scheduled_end);
CREATE INDEX idx_booking_status ON bookings(status);

-- 6. Reader Availabilities
CREATE TABLE IF NOT EXISTS reader_availabilities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reader_id BIGINT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_availability_reader FOREIGN KEY (reader_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_availability_reader_day ON reader_availabilities(reader_id, day_of_week);

-- 7. Blocked Dates
CREATE TABLE IF NOT EXISTS blocked_dates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reader_id BIGINT NOT NULL,
    date DATE NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_blocked_date_reader FOREIGN KEY (reader_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_blocked_date_reader ON blocked_dates(reader_id, date);

-- 8. Payments
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    transaction_id VARCHAR(100) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    status VARCHAR(30) NOT NULL DEFAULT 'INITIATED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_transaction UNIQUE (transaction_id),
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

CREATE INDEX idx_payment_transaction ON payments(transaction_id);
CREATE INDEX idx_payment_booking ON payments(booking_id);
CREATE INDEX idx_payment_status ON payments(status);

-- 9. Reading Results
CREATE TABLE IF NOT EXISTS reading_results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    summary TEXT NOT NULL,
    advice TEXT NOT NULL,
    outcome TEXT,
    additional_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_reading_result_booking UNIQUE (booking_id),
    CONSTRAINT fk_reading_result_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

-- 10. Tarot Card Readings
CREATE TABLE IF NOT EXISTS tarot_card_readings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reading_result_id BIGINT NOT NULL,
    card_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    interpretation TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tarot_card_reading_result FOREIGN KEY (reading_result_id) REFERENCES reading_results(id) ON DELETE CASCADE
);

CREATE INDEX idx_tarot_reading_result ON tarot_card_readings(reading_result_id);

-- 11. Rune Readings
CREATE TABLE IF NOT EXISTS rune_readings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reading_result_id BIGINT NOT NULL,
    rune_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    interpretation TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rune_reading_result FOREIGN KEY (reading_result_id) REFERENCES reading_results(id) ON DELETE CASCADE
);

CREATE INDEX idx_rune_reading_result ON rune_readings(reading_result_id);

-- 12. Reviews
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    booking_id BIGINT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_review_booking UNIQUE (booking_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
);

CREATE INDEX idx_review_customer ON reviews(customer_id);
CREATE INDEX idx_review_approved ON reviews(approved);

-- 13. Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(30) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_notification_user ON notifications(user_id);
CREATE INDEX idx_notification_user_read ON notifications(user_id, is_read);

-- 14. Sessions
CREATE TABLE IF NOT EXISTS sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    session_type VARCHAR(30) NOT NULL,
    provider VARCHAR(50) NOT NULL,
    external_session_id VARCHAR(150),
    join_url VARCHAR(512),
    started_at TIMESTAMP NULL,
    ended_at TIMESTAMP NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_session_booking UNIQUE (booking_id),
    CONSTRAINT fk_session_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

CREATE INDEX idx_session_external_id ON sessions(external_session_id);
CREATE INDEX idx_session_status ON sessions(status);

-- 15. Messages
CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    message TEXT NOT NULL,
    message_type VARCHAR(20) NOT NULL DEFAULT 'TEXT',
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    CONSTRAINT fk_message_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id)
);

CREATE INDEX idx_message_booking ON messages(booking_id);
CREATE INDEX idx_message_sender ON messages(sender_id);
CREATE INDEX idx_message_sent_at ON messages(booking_id, sent_at);

-- 16. Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    details TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created_at ON audit_logs(created_at);

-- 17. Platform Policies
CREATE TABLE IF NOT EXISTS platform_policies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    policy_key VARCHAR(50) NOT NULL,
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_policy_key UNIQUE (policy_key)
);
