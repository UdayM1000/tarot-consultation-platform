# Tarot & Rune Consultation Platform Backend

A scalable, production-grade Spring Boot 3 REST API backend engineered for Tarot and Rune consultations, multi-role access (Customers, Readers, Admins), real-time booking and scheduling, payment abstractions, live session coordination, and audit trails.

---

## Technology Stack

- **Language & Runtime**: Java 21 LTS
- **Framework**: Spring Boot 3.3.4
- **Persistence**: Spring Data JPA, Hibernate ORM
- **Database Migrations**: Flyway
- **Primary Database**: MySQL 8.x
- **Testing Database**: H2 (MySQL compatibility mode)
- **Security**: Spring Security 6, JWT (JSON Web Tokens), BCrypt password hashing
- **Validation**: Jakarta Bean Validation (`@NotNull`, `@NotBlank`, `@Size`, etc.)
- **Documentation**: OpenAPI 3.0 / Swagger UI (`springdoc-openapi`)
- **Testing**: JUnit 5, Mockito, AssertJ, Spring Security Test
- **Tooling**: Lombok, Spring Boot Actuator, Docker & Docker Compose

---

## Architecture & Package Structure

The backend follows a layered, decoupled architecture where controllers are thin, business logic is encapsulated in services, and repositories handle persistence only. Entities are never exposed directly to consumers; all API payloads utilize dedicated DTOs.

```
com.tarotplatform
├── config          # Security, OpenAPI, Web MVC, and infrastructure configurations
├── controller      # Thin REST controllers exposing versioned /api/v1 endpoints
├── dto             # Strongly-typed Data Transfer Objects
│   ├── auth        # Login, Register, Refresh Token, Auth Response DTOs
│   ├── user        # User profile, password update, and management DTOs
│   ├── service     # Reading service catalog, pricing, and category DTOs
│   ├── booking     # Booking creation, rescheduling, slot selection DTOs
│   ├── payment     # Order creation, verification, and webhook DTOs
│   ├── session     # Live session lifecycle and token DTOs
│   ├── reading     # Consultation results, Tarot card, and Rune stone DTOs
│   └── review      # Review submission and admin moderation DTOs
├── entity          # JPA Entities with relational constraints and audit timestamps
├── enums           # Domain enums (Role, SessionType, BookingStatus, etc.)
├── exception       # Centralized exceptions and global @RestControllerAdvice handler
├── repository      # Spring Data JPA repositories with custom query methods
├── security        # JWT filters, UserDetailsService, and security entry points
├── service         # Business logic contracts
│   └── impl        # Service implementations with transactional semantics
├── mapper          # Entity-to-DTO and DTO-to-Entity mapping components
└── util            # Utilities (booking reference generator, date helpers)
```

---

## Domain Model & Database ERD

### Entity Relationships
1. **User (1) ──< (N) user_roles**: Multi-role support (`CUSTOMER`, `READER`, `ADMIN`).
2. **ServiceCategory (1) ──< (N) ReadingService**: Categorization (`TAROT`, `RUNE`, `COMBO`).
3. **ReadingService (1) ──< (N) Booking**: Bookings preserve server-side `priceAtBooking`.
4. **User [Customer] (1) ──< (N) Booking**: Customer consultation requests.
5. **Booking (1) ──< (N) Payment**: Monetary transactions with status tracking.
6. **Booking (1) ── (1) ReadingResult**: Consultation outcome with advice and summary.
7. **ReadingResult (1) ──< (N) TarotCardReading**: Drawn tarot cards, positions, and interpretations.
8. **ReadingResult (1) ──< (N) RuneReading**: Cast rune stones, positions, and interpretations.
9. **Booking (1) ── (0..1) Review**: Customer ratings and comments on completed bookings.
10. **Booking (1) ── (0..1) Session**: Live audio/video/chat consultation session.
11. **Booking (1) ──< (N) Message**: Chat messages exchanged during consultation.
12. **User [Reader] (1) ──< (N) ReaderAvailability**: Weekly recurring schedule.
13. **User [Reader] (1) ──< (N) BlockedDate**: Blackout dates and reader leave.
14. **User (1) ──< (N) Notification**: User alert notifications.
15. **AuditLog**: Independent operational and security audit log.
16. **PlatformPolicy**: Configurable platform disclaimer and rules.

---

## Seed Data (Initial Services & Pricing)

Seeded via Flyway migration `V2__seed_initial_data.sql`:

| # | Service Name | Category | Duration | Price (INR) | Card / Rune Count |
|---|--------------|----------|----------|-------------|-------------------|
| 1 | Yes / No Tarot | TAROT | 15 min | ₹50.00 | 3 tarot cards |
| 2 | General Guidance | TAROT | 20 min | ₹50.00 | 3 tarot cards |
| 3 | One Situation – Detailed Question | TAROT | 30 min | ₹80.00 | 6–7 tarot cards |
| 4 | Detailed Love Reading | TAROT | 45 min | ₹120.00 | 8–9 tarot cards compulsory |
| 5 | Detailed Career Reading | TAROT | 45 min | ₹120.00 | 8–9 tarot cards compulsory |
| 6 | Love Messages | TAROT | 20 min | ₹60.00 | 4 channeled love messages |
| 7 | Rune Yes / No | RUNE | 15 min | ₹50.00 | Rune stone guidance |
| 8 | Rune Guidance | RUNE | 20 min | ₹50.00 | Rune stone guidance |
| 9 | Detailed Rune Reading | RUNE | 30 min | ₹80.00 | Multiple Rune stones |
| 10 | Tarot + Rune Confirmation | COMBO | 60 min | ₹150.00 | Full Tarot spread + Rune stone |

### Seeded Accounts
- **Admin**: `admin@tarotplatform.com` / `Password@123` (Role: `ADMIN`)
- **Reader**: `reader@tarotplatform.com` / `Password@123` (Role: `READER`)
- **Customer**: `customer@tarotplatform.com` / `Password@123` (Role: `CUSTOMER`)

---

## Environment Variables

Copy `.env.example` to `.env` or supply system environment variables:

| Variable | Description | Default (Dev) |
|---|---|---|
| `DB_URL` | JDBC URL for MySQL | `jdbc:mysql://localhost:3306/tarot_db?...` |
| `DB_USERNAME` | MySQL database user | `root` |
| `DB_PASSWORD` | MySQL database password | `root` |
| `JWT_SECRET` | 256-bit secret key for HMAC-SHA256 | Configured secure fallback |
| `JWT_EXPIRATION` | Access token lifespan in ms | `86400000` (24h) |
| `REFRESH_TOKEN_EXPIRATION` | Refresh token lifespan in ms | `604800000` (7 days) |
| `PAYMENT_PROVIDER` | Active payment gateway | `MOCK` |
| `PAYMENT_PROVIDER_KEY` | Provider public API key | `mock_key_test` |
| `PAYMENT_PROVIDER_SECRET` | Provider private secret | `mock_secret_test` |

---

## Running Locally

### 1. Start MySQL (Docker or Native)
```bash
docker compose up -d tarot-mysql
```

### 2. Build and Run the Backend
```bash
mvn clean spring-boot:run
```

The application starts on `http://localhost:8080`.

### 3. Run with Docker Compose
```bash
docker compose up --build
```

---

## API Documentation (Swagger / OpenAPI)

Once the backend is running, inspect and interact with the endpoints:
- **Swagger UI**: `http://localhost:8080/swagger-ui.html`
- **OpenAPI JSON**: `http://localhost:8080/v3/api-docs`

---

## Running Automated Tests

Run the complete test suite with Flyway migration validation, MockMvc web tests, and JPA repository tests:

```bash
mvn clean test
```

All 51 automated tests execute against an in-memory MySQL-compatible H2 database:
- `FlywayMigrationTest`: Verifies DDL execution, table creation, seed categories, 10 services with exact pricing, disclaimers, and seed user accounts.
- `EntityAndRepositoryTest`: Verifies user multi-role persistence, booking conflict detection, reader schedule query, payments revenue aggregation, reading result cascading, reviews, notifications, sessions, chat messages, and audit logs.
- `AuthenticationAndSecurityTest`: Full JWT authentication lifecycle, registration, login, token refresh, user profile updates, password changes, and role authorization.
- `ReadingServiceCatalogTest`: Public paginated catalog, category lookups, admin service creation, updates, and active status toggling.
- `BookingAndAvailabilityTest`: Reader slot calculation, double-booking rejection, mandatory disclaimer acceptance, and admin booking status management.
- `PaymentSystemTest`: Server-side price lock, mock gateway order creation, signature verification, automatic booking confirmation, audit logs, and webhooks.
- `ReadingResultSystemTest`: Tarot cards and Rune stone interpretations publication, customer access verification, and reader updates.
- `ReviewAndNotificationTest`: Customer reviews workflow (only completed consultations, one review per booking), admin review approval, and notification lifecycle.
- `SessionAndChatTest`: Live video/chat session creation, room joining, WebSocket STOMP endpoint verification, message storage, and session termination.
- `AdminDashboardTest`: Platform overview metrics, revenue aggregation, today's bookings, popular services ranking, recent bookings list, and paginated customer directory.

---

## Implementation Roadmap (100% Completed)

- [x] **Phase 1**: Project setup, Database, Entities, Enums, Repositories, Flyway migrations, Seed data.
- [x] **Phase 2**: Authentication, JWT tokens, Spring Security filter chain, Role-based authorization.
- [x] **Phase 3**: Reading services catalogue, DTOs, Admin service management APIs.
- [x] **Phase 4**: Reader availability engine, Booking creation with transactional double-booking protection.
- [x] **Phase 5**: Payment abstraction layer, Mock payment provider, Webhooks, Verification.
- [x] **Phase 6**: Reading result APIs, Tarot card spreads, Rune casting interpretations, Seeker access control.
- [x] **Phase 7**: Customer reviews & moderation, In-app notification engine.
- [x] **Phase 8**: Session provider interface, Video/audio tokens, WebSocket chat architecture.
- [x] **Phase 9**: Admin dashboard analytics, Revenue metrics, Customer management.
- [x] **Phase 10**: End-to-end integration tests, Swagger grouping, Production docker hardening.
