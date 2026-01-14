# Adsum Development Plan 🛠️

> **Status:** Phase 2B (Complete)
> **Goal:** Build a **robust, verification-driven** Student Productivity App.
> **Philosophy:** *"If it isn't tested, it doesn't exist. If it can fail, plan for it."*

This document is the **master engineering specification** for the development process.

---

## �️ Consistency & Robustness Checkpoints

To ensure absolute reliability, the following strictly enforced checkpoints must be passed at the end of every major phase (or every 500 lines of code changed).

### 🔍 Checkpoint A: Schema Consistency
- [ ] **Verify `SCHEMA.md` vs Code**: Ensure all Drift tables and Domain Models match `SCHEMA.md` exactly.
- [ ] **Verify `ARCHITECTURE.md` vs Code**: Ensure implemented patterns (e.g., Service Layer, Repository Pattern) match the architectural spec.
- [ ] **Data Integrity Check**: Run validator unit tests on all new data models.

### 🔄 Checkpoint B: Data Flow Audit
- [ ] **Verify `DATA_FLOW.md`**: Trace one complete user action (e.g., "Add Course") through UI -> Provider -> Repository -> DB/JSON and confirm it matches the flow diagram.
- [ ] **State Consistency**: Verify Riverpod providers correctly invalidate/refresh dependent state after mutations.

### 🧪 Checkpoint C: Robustness & Error Handling
- [ ] **Error Boundary Test**: Manually throw an exception in the new feature and verify `ErrorBoundary` catches it and shows the user-friendly UI.
- [ ] **Offline Test**: Perform the action while offline and verify `OfflineQueue` entry or appropriate error message.
- [ ] **Lint Zero**: Ensure `flutter analyze` returns 0 errors/warnings for modified files.

---

## �📊 Implementation Progress

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 0 | ✅ Complete | Foundation of Robustness |
| Phase 1A | ✅ Complete | Drift Database + JSON Service |
| Phase 1B | ✅ Complete | Domain Models + Repositories |
| Phase 2 | ✅ Complete | Connect UI to Data & Onboarding |
| Phase 3 | 🚧 Next | Sync Engine |
| Phase 4 | ⏳ Pending | Domain Logic |
| Phase 5 | ⏳ Pending | Security & CR Authority |
| Phase 6 | ⏳ Pending | Integration & Observability |

---

## ✅ Phase 0: Foundation of Robustness (COMPLETE)

### 0.1 Quality Assurance Tooling
- [x] **Linting**: `very_good_analysis` configured in `analysis_options.yaml`
- [x] **Strict Rules**: Single quotes, package imports, no prints

### 0.2 Error Architecture
- [x] **Error Types**: `lib/core/errors/error_types.dart`
  - `NetworkException`, `AuthException`, `DataIntegrityException`
  - `ValidationException`, `SystemException`, `SyncException`
- [x] **Error Boundary**: `lib/core/errors/error_boundary.dart`
  - Circuit breaker pattern
  - Recovery action determination
  - Riverpod integration

### 0.3 Logging Architecture
- [x] **AppLogger**: `lib/core/utils/app_logger.dart`
  - Levels: debug, info, warn, error, fatal
  - Context and tags support
  - File rotation (7 days, 10MB)
  - PII redaction for export

### 0.4 Production Error Handling
- [x] **main.dart**: `runZonedGuarded` wrapper
- [x] **Flutter Error Handler**: Custom `FlutterError.onError`
- [x] **Production Widget**: No red screen in release mode

---

## ✅ Phase 1A: Data Foundation - Storage (COMPLETE)

### 1.1 Drift Database
- [x] **AppDatabase**: `lib/data/sources/local/app_database.dart`
- [x] **Generated Code**: `app_database.g.dart`

#### Tables Created
| Table | File | Purpose |
|-------|------|---------|
| Users | `tables/users_table.dart` | Cached profile |
| Enrollments | `tables/enrollments_table.dart` | Course data |
| OfflineQueue | `tables/offline_queue_table.dart` | Sync queue |
| SyncMetadata | `tables/sync_metadata_table.dart` | ETags, timestamps |

### 1.2 JSON File Service
- [x] **JsonFileService**: `lib/data/sources/local/json_file_service.dart`
  - Atomic writes (`.tmp` → rename)
  - Auto-backup before overwrite
  - Backup recovery on corruption
  - CRUD operations for arrays/objects

### 1.3 Data Validation
- [x] **DataValidationService**: `lib/data/validation/data_validation.dart`
  - Sanitizers (trim, normalize)
  - Schema validators (User, Enrollment, Attendance)
  - Business rule validation

---

## ✅ Phase 1B: Data Foundation - Domain Layer (COMPLETE)

### 1.4 Domain Models (matches SCHEMA.md Part 2)

| Model | File | JSON File |
|-------|------|-----------|
| `UserProfile` | `lib/domain/models/user_profile.dart` | `user.json` |
| `Enrollment` | `lib/domain/models/enrollment.dart` | `enrollments.json` |
| `AttendanceLog` | `lib/domain/models/attendance_log.dart` | `attendance.json` |
| `CustomScheduleSlot` | `lib/domain/models/schedule.dart` | `custom_schedules.json` |
| `ScheduleBinding` | `lib/domain/models/schedule.dart` | `schedule_bindings.json` |
| `ActionItem` | `lib/domain/models/action_item.dart` | `action_items.json` |
| `PersonalEvent` | `lib/domain/models/personal_event.dart` | `events.json` |

### 1.5 Repositories

| Repository | File | Operations |
|------------|------|------------|
| `UserRepository` | `lib/data/repositories/user_repository.dart` | CRUD, settings |
| `EnrollmentRepository` | `lib/data/repositories/enrollment_repository.dart` | CRUD, stats, attendance |
| `AttendanceRepository` | `lib/data/repositories/attendance_repository.dart` | Log, query, sync |
| `ActionItemRepository` | `lib/data/repositories/action_item_repository.dart` | Add, resolve, query |

### 1.6 Riverpod Providers
- [x] **data_providers.dart**: `lib/data/providers/data_providers.dart`
  - Service providers: `databaseProvider`, `jsonFileServiceProvider`
  - Repository providers: `userRepositoryProvider`, etc.
  - Data providers: `enrollmentsProvider`, `pendingActionItemsProvider`

---

## ✅ Phase 2: Connect UI to Data (COMPLETE)

*Goal: Replace hardcoded mock data in demo pages with repository calls.*

### 2.1 Demo App Status
The demo at `lib/presentation/` is presentation-only with mock data:
- Dashboard: Hardcoded `_getEventsForDate()` mock
- CoursesPage: Inline `_globalCourses` list
- ActionCenter: Loads from assets JSON (needs repository)

### 2.2 Tasks

| Page | Current State | Action Required |
|------|--------------|-----------------|
| Dashboard | Load from merged schedule | Done ✅ |
| CoursesPage | Load from `enrollmentsProvider` | Done ✅ |
| SubjectDetailPage | Load from `enrollmentRepository` | Done ✅ |
| ActionCenterPage | Connected to Repo | Done ✅ |
| SettingsPage | Connected to UserRepo | Done ✅ |

- [x] Create `ScheduleService` to merge L1+L2+L3
- [x] Replace mock data in Dashboard with schedule provider
- [x] Connect CoursesPage to EnrollmentRepository
- [x] Connect SubjectDetailPage to EnrollmentRepository
- [x] Connect ActionCenter to ActionItemRepository
- [x] Connect SettingsPage to UserRepository
- [x] Add reactive UI updates with Riverpod

### 2.3 Phase 2B: Onboarding & Authentication (New)
*Goal: Replace mock Auth and Wizard with real User creation.*

- [x] **AuthPage**: Connect to `UserRepository` (Create/Get User)
- [x] **Wizard**: Persist data to `EnrollmentRepository` and `Preferences`
- [x] **Splash**: Route based on `UserRepository.currentUser` existence

### 🛑 VERIFICATION GATE 2
> 1. Dashboard loads real enrollments
> 2. Adding course persists to JSON
> 3. Action items resolve and persist
> 4. No hardcoded mock data remains

---

## ⏳ Phase 3: Sync Engine

*Goal: Reliable offline-first sync with conflict resolution.*

### 3.1 Offline Queue Processing
- [ ] `SyncService`: Process `OfflineQueue` table
- [ ] Retry with exponential backoff (5 attempts)
- [ ] Dead letter queue for failures
- [ ] User notification for failed syncs

### 3.2 Supabase Integration
- [ ] Initialize Supabase client
- [ ] Read-only sync for shared data (courses, schedules)
- [ ] Write sync for user actions (attendance)
- [ ] Realtime subscriptions for updates

### 3.3 Conflict Resolution
- [ ] Timestamp comparison
- [ ] Create `ActionItem(type=CONFLICT)` on conflict
- [ ] Resolution UI

---

## ⏳ Phase 4: Domain Logic

### 4.1 Schedule Merge Engine
- [ ] Merge L1 (global) + L2 (CR patches) + L3 (personal)
- [ ] Handle holidays, day swaps
- [ ] Edge case handling

### 4.2 Attendance Confidence Engine
- [ ] GPS + WiFi + Activity scoring
- [ ] Auto-mark threshold (≥70%)
- [ ] Evidence recording

### 4.3 Safe Bunks Calculator
- [ ] Formula implementation
- [ ] Target attendance tracking

---

## ⏳ Phase 5: CR Authority & Security

- [ ] Ed25519 key generation and storage
- [ ] Schedule patch signing
- [ ] Verification in Edge Functions
- [ ] RLS policy verification

---

## ⏳ Phase 6: Integration & Observability

- [ ] E2E tests for critical flows
- [ ] Crash reporting setup
- [ ] Performance monitoring
- [ ] Log export functionality

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── errors/          # Error types, boundary
│   ├── utils/           # AppLogger
│   ├── theme/           # AppColors, AppTheme
│   └── router/          # GoRouter setup
├── data/
│   ├── sources/local/   # Drift DB, JSON service
│   ├── repositories/    # Data access layer
│   ├── providers/       # Riverpod providers
│   └── validation/      # Input validation
├── domain/
│   └── models/          # Domain models (SCHEMA.md)
└── presentation/
    ├── pages/           # UI screens (from demo)
    ├── widgets/         # Reusable components
    └── providers/       # UI state (to be migrated)
```

---

## 🚨 Known Issues

1. **Android Build**: Gradle/Java version mismatch needs resolution
2. **Lint Warnings**: ~3300 warnings in demo code (type safety)
3. **Demo UI**: Uses dynamic types, needs type-safe refactoring

---

## 📅 Changelog

| Date | Change |
|------|--------|
| 2026-01-14 | Updated to reflect actual implementation, marked Phase 0/1 complete |
| 2026-01-14 | Enhanced plan with robustness focus, failure modes, verification gates |
