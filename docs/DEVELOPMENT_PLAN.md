# Adsum Development Plan 🛠️

> **Status:** Phase 2A/2B (In Progress)
> **Goal:** Build a **robust, verification-driven** Student Productivity App.
> **Philosophy:** *"If it isn't tested, it doesn't exist. If it can fail, plan for it."*

This document is the **master engineering specification** for the development process.

---

## 🛡️ Consistency & Robustness Checkpoints

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

## 📊 Implementation Progress

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 0 | ✅ Complete | Foundation of Robustness |
| Phase 1A | ✅ Complete | Drift Database + JSON Service |
| Phase 1B | ✅ Complete | Domain Models + Repositories (Core) |
| Phase 2A | ✅ Complete | Feature Backend (Work, Syllabus, Mess, Calendar) |
| Phase 2B | ✅ Complete | Connect UI to Data |
| Phase 3 | ⏳ Pending | Sync Engine |
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

### 1.4 Data Constraints
- [x] **Duplicate Enrollment Prevention**: `EnrollmentRepository.addEnrollment()` returns `null` if course+section already enrolled.
- [x] **Sensor Defaults**: All sensor settings default to `false` until user grants permission.
  - Business rule validation

---

## ✅ Phase 1B: Data Foundation - Core Domain (COMPLETE)

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
| `ScheduleRepository` | `lib/data/repositories/schedule_repository.dart` | Custom slots, bindings |

### 1.6 Riverpod Providers
- [x] **data_providers.dart**: `lib/data/providers/data_providers.dart`
  - Service providers: `databaseProvider`, `jsonFileServiceProvider`
  - Repository providers: `userRepositoryProvider`, etc.
  - Data providers: `enrollmentsProvider`, `pendingActionItemsProvider`

---

## ✅ Phase 2A: Data Foundation - Features (COMPLETE)

*Goal: Implement repositories and services for specialized features using strict architecture.*

### 2A.1 Feature Components (Provider → Service → Repository)
| Feature | Service | Repository | Model |
|---|---|---|---|
| **Work** | `WorkService` | `WorkRepository` | `Work`, `WorkState` |
| **Syllabus** | `SyllabusService` | `SyllabusRepository` | `SyllabusUnit`, `SyllabusTopic`, `CustomSyllabus` |
| **Mess** | `MessService` | `MessRepository` | `MessMenu`, `MenuCache` |
| **Calendar** | `CalendarService` | `CalendarRepository` | `CalendarEvent`, `CalendarOverride` |

### 2A.2 Tasks
- [x] Implement `WorkRepository` (Pure CRUD) & `WorkService` (Business Logic)
- [x] Implement `SyllabusRepository` & `SyllabusService`
- [x] Implement `MessRepository` & `MessService`
- [x] Implement `CalendarRepository` & `CalendarService`
- [x] Register Service providers in `data_providers.dart`
- [x] Verify with `flutter test test/data_layer_verification_test.dart`

---

## ✅ Phase 2B: Connect UI to Data (COMPLETE)

*Goal: Replace hardcoded mock data in demo pages with repository calls.*

### 2B.1 Demo App Status
The demo at `lib/presentation/` contains **24 pages** across 12 feature directories:

### 2B.2 All Pages Status

#### Core Pages
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| SplashPage | `splash/splash_page.dart` | ✅ Connected | `userRepositoryProvider` |
| AuthPage | `auth/auth_page.dart` | ✅ Connected | `userRepositoryProvider` |
| DashboardPage | `dashboard/dashboard_page.dart` | ✅ Connected | `todayScheduleProvider` |
| SettingsPage | `settings/settings_page.dart` | ✅ Connected | `userRepositoryProvider` |
| EditProfilePage | `settings/edit_profile_page.dart` | ✅ Connected | `userRepositoryProvider` |

#### Courses & Enrollment
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| CoursesPage | `courses/courses_page.dart` | ✅ Connected | `enrollmentsProvider` |
| SubjectDetailPage | `courses/subject_detail_page.dart` | ✅ Connected | `enrollmentsProvider`, `attendanceLogsProvider` |
| CreateCustomCoursePage | `courses/create_custom_course_page.dart` | ✅ Connected | `enrollmentRepositoryProvider` (Actions) |

#### Academics
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| AssignmentsPage | `academics/assignments_page.dart` | ✅ Connected | `pendingWorkProvider` ✅ |
| SyllabusEditorPage | `academics/syllabus_editor_page.dart` | ✅ Connected | `syllabusServiceProvider` ✅ |
| WorkDetailPage | `academics/work_detail_page.dart` | ✅ Connected | `workServiceProvider` ✅ |

#### Attendance
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| AcademicsPage | `attendance/academics_page.dart` | ✅ Connected | `enrollmentsProvider` |
| GeofenceDebuggerPage | `attendance/geofence_debugger_page.dart` | ✅ Verified | `geofenceServiceProvider` (Visual Only) |
| HistoryLogPage | `attendance/history_log_page.dart` | ✅ Connected | `attendanceLogsProvider` |

#### Calendar
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| AcademicCalendarPage | `calendar/academic_calendar_page.dart` | ✅ Connected | `calendarEventsProvider` ✅ |
| AddEventPage | `calendar/add_event_page.dart` | ✅ Connected | `calendarServiceProvider` ✅ |
| HolidayInjectionPage | `calendar/holiday_injection_page.dart` | ✅ Connected | `calendarServiceProvider` ✅ |

#### CR Authority
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| SchedulePatcherPage | `cr_authority/schedule_patcher_page.dart` | ⏳ Pending | `scheduleRepositoryProvider`, `patchProvider` (Missing) |
| AuditTrailPage | `cr_authority/audit_trail_page.dart` | ⏳ Pending | `auditLogProvider` (Missing) |

#### Mess
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| MessMenuPage | `mess/mess_menu_page.dart` | ✅ Connected | `todayMessMenuProvider` ✅ |
| MenuEditorPage | `mess/menu_editor_page.dart` | ✅ Connected | `messServiceProvider` ✅ |

#### Action & Notifications
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| ActionCenterPage | `action_center/action_center_page.dart` | ✅ Connected | `pendingActionItemsProvider` |

#### Wizard (Onboarding)
| Page | File | Status | Required Provider |
|------|------|--------|-------------------|
| WizardOcrPage | `wizard/wizard_ocr_page.dart` | ✅ Connected | `userRepositoryProvider` |
| WizardSensorsPage | `wizard/wizard_sensors_page.dart` | ✅ Connected | `userRepositoryProvider` |

### 2B.4 Completed Tasks
- [x] Create `ScheduleService` to merge L1+L2+L3
- [x] Replace mock data in Dashboard with schedule provider
- [x] Connect CoursesPage to EnrollmentRepository
- [x] Connect SubjectDetailPage to EnrollmentRepository
- [x] Connect ActionCenter to ActionItemRepository
- [x] Connect SettingsPage to UserRepository
- [x] Add reactive UI updates with Riverpod
- [x] Connect Form Pages (Add Event, Create Custom Course)
- [x] Connect Editor Pages (Syllabus, Menu, Profile)
- [x] Connect Detail Pages (Work, History)

### 2B.3 Onboarding & Authentication
*Goal: Replace mock Auth and Wizard with real User creation.*

- [x] **AuthPage**: Connect to `UserRepository` (Create/Get User)
- [x] **Wizard**: Persist data to `EnrollmentRepository` and `Preferences`
- [x] **Splash**: Route based on `UserRepository.currentUser` existence

### 🛑 VERIFICATION GATE 2
> 1. Dashboard loads real enrollments
> 2. Adding course persists to JSON
> 3. Action items resolve and persist
> 4. No hardcoded mock data remains (Verified via comprehensive audit)
> 5. All 24 pages audited: 21 Connected, 2 Pending Backend, 1 Config Only.

---

## ⏳ Phase 3: Backend Integration & Sync

*Goal: Full connection to Supabase (Auth, DB, Realtime) with offline-first reliability.*

### 3.1 Backend Setup & Auth
- [ ] Initialize Supabase project & client
- [ ] **Auth Integration**: Connect generic `AuthProvider` to Supabase Auth (Google/Email)
- [ ] **Row Level Security (RLS)**: Verify policies for Users, Enrollments, Attendance
- [ ] **Database Helpers**: RPC functions for complex queries (e.g., stats aggregation)

### 3.2 Offline Queue Processing
- [ ] `SyncService`: Process `OfflineQueue` table
- [ ] Retry with exponential backoff (5 attempts)
- [ ] Dead letter queue for failures
- [ ] User notification for failed syncs

### 3.3 Data Sync Implementation
- [ ] **Read-Only Sync**: Fetch shared data (Universities, Global Courses) on startup
- [ ] **Write Sync**: Push local actions (Enrollments, Attendance) to server
- [ ] **Realtime Subscriptions**: Listen for Schedule changes (`schedule_modifications`)

### 3.3 Conflict Resolution
- [ ] Timestamp comparison (Sync Engine)
- [ ] Create `ActionItem(type=CONFLICT)` on conflict
- [ ] Resolution UI in Action Center

#### Course Slot Conflicts (Design Decision: 2026-01-15)
- **Behavior**: Allow enrollment even when time-slots conflict.
- **Resolution**: Create `ActionItem(type=CONFLICT)` for user to resolve in Action Center.
- **Persistence**: Conflict remains until slot is changed or user explicitly dismisses.
- **No Blocking**: Enrollment/course creation is NOT blocked by conflicts.

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
| 2026-01-14 | Introduced Phase 2A (Feature Backend) and Phase 2B (Connect UI) split |
| 2026-01-14 | Cleaned up: deleted `schedule/`, `conflicts/`, `notifications/` directories (unused) |
| 2026-01-14 | Updated Phase 2 with complete page inventory (24 pages across 12 directories) |
| 2026-01-14 | Updated to reflect actual implementation, marked Phase 0/1 complete |
| 2026-01-14 | Enhanced plan with robustness focus, failure modes, verification gates |
