# ADSUM Architecture

> 📌 **Living Document** — Updated as we build. Last updated: 2026-01-14.

---

## 1. High-Level Design

### 1.1 System Overview

ADSUM is a **student productivity app** focused on:
- Automated attendance tracking via GPS/WiFi
- Smart schedule management with CR authority
- Course work tracking and academic planning



### 1.2 Architecture Principles

| Principle | Description |
|-----------|-------------|
| **Cryptographic Trust** | CR actions are Ed25519 signed; verified by Edge Functions. |
| **Multi-Tenancy** | All shared tables have `university_id` for isolation. |

### 1.3 System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SERVICES                        │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   Google OAuth  │   Firebase FCM  │      Google Drive API       │
│   (Auth)        │   (Push Notif)  │      (Backup/Restore)       │
└────────┬────────┴────────┬────────┴──────────────┬──────────────┘
         │                 │                       │
         ▼                 ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                             │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   Presentation  │   Domain Logic  │      Services               │
│   (UI/Widgets)  │   (UseCases)    │  (Sync, Geofence, Notif)    │
└────────┬────────┴────────┬────────┴──────────────┬──────────────┘
         │                 │                       │
         ▼                 ▼                       ▼
┌─────────────────┬─────────────────┬─────────────────────────────┐
│   Local SQLite  │   Supabase BaaS │      Edge Functions         │
│   (Drift)       │   (PostgreSQL)  │      (CR Verification)      │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

### 1.4 Data Architecture

#### 1.4.1 Hybrid Model

| Scope | Model | Technology | Reason |
|-------|-------|------------|--------|
| **Remote (Shared)** | **Relational** | Supabase (PostgreSQL) | Data integrity, referential constraints. |
| **Local (Personal)** | **Document** | Drift (SQLite + JSON) | Matches `SCHEMA.md` JSON structure (nested objects). |

#### 1.4.2 Storage Layers

| Principle | Description |
|-----------|-------------|
| **Offline-First** | Core features work without internet. Sync when available. |
| **Local-First Data** | User data lives on device; cloud is backup + sync. |

---

## 2. Tech Stack

### 2.1 Client (Flutter)

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Framework** | Flutter 3.x | Cross-platform UI |
| **State Management** | Riverpod | Reactive state + DI |
| **Local Database** | Drift (SQLite) | Runtime storage (maps to JSON schema) |
| **Networking** | Supabase Flutter SDK | Auth, Realtime, Storage |
| **Routing** | go_router | Declarative navigation |
| **Styling** | Google Fonts + Custom Theme | Consistent typography |

### 2.2 Backend (Supabase)

| Service | Usage |
|---------|-------|
| **PostgreSQL** | Primary database (all shared tables) |
| **Auth** | Google OAuth for student login |
| **Realtime** | Live sync for schedule changes, broadcasts |
| **Storage** | Profile images, OCR scans |
| **Edge Functions** | CR signature verification, push notifications |

### 2.3 Notifications

| Type | Technology | Triggers |
|------|------------|----------|
| **Local** | `flutter_local_notifications` | Upcoming class (15min), Assignment due (24h) |
| **Push (Remote)** | FCM via Supabase Edge Functions | CR schedule changes, urgent broadcasts |

### 2.4 Backup & Sync

| Feature | Implementation |
|---------|----------------|
| **Cloud Sync** | Supabase Realtime (auto-sync when online) |
| **Google Drive Backup** | `google_sign_in` + `googleapis` for manual export |
| **Backup Contents** | Enrollments, custom courses, attendance stats, personal events |
| **Restore** | User-initiated from Settings → Import Data |

### 2.5 Security

| Aspect | Implementation |
|--------|----------------|
| **Authentication** | Supabase Auth (Google OAuth) |
| **Authorization** | Row Level Security (RLS) policies |
| **CR Signing** | Ed25519 keypair; private in device Keychain |
| **Data Encryption** | TLS in transit; AES-256 at rest (Supabase) |

---

## 3. Code Design (Flutter)

### 3.1 Project Structure

```
lib/
├── core/
│   ├── theme/           # AppColors, TextStyles
│   ├── constants/       # App-wide constants
│   └── utils/           # Helpers, extensions
├── data/
│   ├── models/          # Drift entities, DTOs
│   ├── repositories/    # Data access layer
│   └── sources/
│       ├── local/       # Drift DAOs
│       └── remote/      # Supabase clients
├── domain/
│   ├── entities/        # Business objects
│   └── usecases/        # Business logic
├── presentation/
│   ├── pages/           # Full-screen views
│   ├── widgets/         # Reusable components
│   └── providers/       # Riverpod providers
├── services/
│   ├── sync/            # Background sync engine
│   ├── geofence/        # Attendance tracking
│   └── notifications/   # FCM handler
└── main.dart
```

### 3.2 Layer Responsibilities

| Layer | Responsibility | Example |
|-------|----------------|---------|
| **Presentation** | UI rendering, user input | `DashboardPage`, `ScheduleCard` |
| **Providers** | State management, UI logic | `scheduleProvider`, `authProvider` |
| **Domain** | Business rules | `MarkAttendanceUseCase` |
| **Data** | Data access, caching | `EnrollmentRepository` |
| **Services** | Background tasks, platform APIs | `SyncService`, `GeofenceService` |

### 3.3 Data Flow

```
UI Widget
    │
    ▼ (watches)
Riverpod Provider
    │
    ▼ (calls)
UseCase (Domain)
    │
    ▼ (fetches/saves)
Repository (Data)
    │
    ├──▶ Local Source (Drift)
    └──▶ Remote Source (Supabase)
```

### 3.4 Key Patterns

| Pattern | Usage |
|---------|-------|
| **Repository Pattern** | Abstract data sources behind interface |
| **UseCase Pattern** | Single-purpose business logic units |
| **Provider Pattern** | Riverpod for reactive state + DI |
| **Offline Queue** | Failed writes queued for retry |

---

## 4. Key Algorithms

> 📝 Detailed pseudocode lives in `DATA_FLOW.md`.

### 4.1 Schedule Merge (3-Layer)

1. **L1 (University):** Base timetable from `global_schedules`
2. **L2 (CR):** Patches from `schedule_modifications` (signed)
3. **L3 (User):** Personal overrides from `personal_overrides`

Priority: **L3 > L2 > L1**

### 4.2 Attendance Confidence

```
Score = (GPS_Weight × GPS_Score) + (WiFi_Weight × WiFi_Score) + (Activity_Weight × Activity_Score)

Default Weights: GPS=40%, WiFi=30%, Activity=30%
Threshold: 70% = Auto-mark Present
```

---

## 5. Database Overview

> 📝 Full schema in `SCHEMA.md`.

### 5.1 Core Tables

| Module | Tables |
|--------|--------|
| **Users** | `users`, `signing_keys` |
| **Courses** | `courses`, `enrollments`, `global_schedules`, `custom_courses` |
| **Schedule** | `schedule_modifications`, `personal_overrides`, `schedule_bindings` |
| **Attendance** | `attendance_log`, `attendance_stats` |
| **Academic** | `course_work`, `syllabus_units`, `syllabus_topics` |
| **Mess** | `hostels`, `mess_menus` |
| **Collab** | `cr_requests`, `verification_votes` |

### 5.2 RLS Policy Summary

| Table | Policy |
|-------|--------|
| `enrollments` | Users see only their own |
| `schedule_modifications` | CRs can INSERT for their approved course+section |
| `attendance_log` | Users can INSERT/UPDATE their own |

---

## 6. Future Considerations

| Item | Status |
|------|--------|
| **Push Notifications** | Planned (FCM via Edge Functions) |
| **Offline Conflict Resolution** | Planned (LWW with user prompt) |
| **Course Resources/Attachments** | Deferred (V2) |
| **Exam Command Center** | Deferred (V2) |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-14 | Initial refactor. Moved details to DATA_FLOW.md. |
