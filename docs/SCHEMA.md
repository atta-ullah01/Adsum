# Adsum Data Model

**Architecture:** Hybrid (Supabase PostgreSQL + Local JSON + Google Drive)

---

## 📊 Part 1: Supabase SQL Tables (Shared Data)

*Stored in Supabase PostgreSQL. Synced to all users. Protected by RLS.*

---

### 🏗️ Module 1: Core Infrastructure

#### `universities`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `university_id` | UUID | **PK** | Unique university ID |
| `name` | String | | e.g., "IIT Delhi" |
| `short_code` | String | Unique | e.g., "IITD" |
| `timezone` | String | | IANA timezone |
| `is_active` | Boolean | | Soft delete |
| `created_at` | Timestamp | | Audit |

#### `hostels`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `hostel_id` | UUID | **PK** | |
| `university_id` | UUID | **FK** | |
| `name` | String | | e.g., "Hostel H1" |
| `location_lat` | Float | | For nearest-mess |
| `location_long` | Float | | |
| `is_active` | Boolean | | |

#### `courses`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `course_code` | String | **PK** | e.g., "CS101" |
| `university_id` | UUID | **FK** | |
| `course_name` | String | | Official name |
| `instructor` | String | | |
| `total_expected_classes` | Int | | Denominator |

#### `academic_calendar`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `calendar_id` | UUID | **PK** | |
| `university_id` | UUID | **FK** | |
| `date` | Date | Index | |
| `title` | String | | e.g., "Diwali", "Republic Day" |
| `type` | Enum | | `HOLIDAY`, `EXAM`, `DAY_SWAP` |
| `day_order_override` | Enum | | `MON`, `TUE`... (only for DAY_SWAP) |
| `source` | Enum | | `ADMIN`, `CR` |

---

### ⏳ Module 2: Schedule Engine (Shared Layers)

#### `global_schedules` (Layer 1)
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `rule_id` | UUID | **PK** | |
| `course_code` | String | **FK** | |
| `section` | String | | Null = all sections |
| `day_of_week` | Enum | | `MON`... |
| `start_time` | Time | | |
| `end_time` | Time | | |
| `location_name` | String | | "LH-1" |
| `location_lat` | Float | | Geofence |
| `location_long` | Float | | |
| `wifi_ssid` | String | | Expected AP |

#### `schedule_modifications` (Layer 2 - CR)
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `patch_id` | UUID | **PK** | |
| `target_rule_id` | UUID | **FK** | L1 rule, null if extra class |
| `course_code` | String | **FK** | |
| `section` | String | | |
| `affected_date` | Date | Index | Original occurrence date |
| `action` | Enum | | `CANCEL`, `RESCHEDULE`, `EXTRA_CLASS`, `SWAP_ROOM` |
| `new_date` | Date | | For RESCHEDULE/EXTRA_CLASS |
| `new_start_time` | Time | | For RESCHEDULE/EXTRA_CLASS |
| `new_end_time` | Time | | For RESCHEDULE/EXTRA_CLASS |
| `new_location` | String | | For RESCHEDULE/EXTRA_CLASS/SWAP_ROOM |
| `note` | String | | CR explanation (required) |
| `cr_user_id` | UUID | **FK** | |
| `cr_signature` | String | | Ed25519 signature |

#### `signing_keys`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `key_id` | UUID | **PK** | |
| `user_id` | UUID | **FK** | CR owner |
| `public_key` | Text | | Ed25519 public |
| `revoked_at` | Timestamp | | Null if active |

---

### 📚 Module 3: Course Content (Shared)

#### `course_work`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `work_id` | UUID | **PK** | |
| `course_code` | String | **FK** | Links to `courses` |
| `work_type` | Enum | | `ASSIGNMENT`, `QUIZ`, `EXAM`, `PROJECT` |
| `title` | String | | Work title |
| `due_at` | Timestamp | | Deadline (Assignment/Project) or Quiz window end |
| `start_at` | Timestamp | | Exam/Quiz start time |
| `duration_minutes` | Int | | Quiz duration |
| `venue` | String | | Exam venue + seat (e.g., "LH-101 • A4") |
| `description` | Text | | Instructions or notes |
| `is_super_event` | Boolean | | If true, blocks calendar (used for Mid-Sem/End-Sem) |
| `cr_user_id` | UUID | **FK** | CR who issued this work |
| `cr_signature` | String | | Ed25519 signature for verification |
| `created_at` | Timestamp | | |

#### `syllabus_units`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `unit_id` | UUID | **PK** | |
| `course_code` | String | **FK** | |
| `title` | String | | |
| `unit_order` | Int | | |

#### `syllabus_topics`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `topic_id` | UUID | **PK** | |
| `unit_id` | UUID | **FK** | |
| `title` | String | | |


#### `work_comments`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `comment_id` | UUID | **PK** | |
| `work_id` | UUID | **FK** | |
| `user_id` | UUID | **FK** | |
| `text` | String | | Comment content |
| `created_at` | Timestamp | | |

---

### 🍛 Module 4: Mess (Shared)

*Weekly rotation menu. Global, read-only for users.*

#### `mess_menus`
| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `menu_id` | UUID | **PK** | |
| `hostel_id` | UUID | **FK** | Links to hostel |
| `day_of_week` | Enum | | `MON`, `TUE`... (weekly rotation) |
| `meal_type` | Enum | | `BREAKFAST`, `LUNCH`, `SNACKS`, `DINNER` |
| `start_time` | Time | | e.g., "07:30" |
| `end_time` | Time | | e.g., "09:30" |
| `items` | Text | | e.g., "Rice, Dal, Roti, Paneer" |

**Workflow:**
1. User selects hostel → fetches all `mess_menus` for that `hostel_id`
2. User selects date → app calculates `day_of_week` from date
3. Display all meals for that day (Breakfast, Lunch, etc.)

---

### 📣 Module 5: Collaboration (Shared)

#### `cr_requests`
*Tracks CR role requests for catalog courses. Admins approve via direct database access.*

| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `request_id` | UUID | **PK** | |
| `user_id` | UUID | **FK** | Requester |
| `course_code` | String | **FK** | Catalog course (not custom) |
| `section` | String | | Section (e.g., "A", "B") |
| `status` | Enum | | `PENDING`, `APPROVED`, `REJECTED` |
| `requested_at` | Timestamp | | |
| `reviewed_at` | Timestamp | | Null until reviewed |

*Note: CR scope is strictly **per-section**. A user can be CR for "CS101-A" but not "CS101-B". Admin approval grants authority only for that specific `course_code` + `section` combination.*

#### `verification_votes`
*Crowd-sourced class status voting (see Section 10: Student Collaboration in FEATURES.md).*

| Column | Type | Key | Description |
|--------|------|-----|-------------|
| `vote_id` | UUID | **PK** | |
| `rule_id` | UUID | **FK** | Schedule slot |
| `section` | String | | Voter's section |
| `user_id` | UUID | **FK** | Voter |
| `date` | Date | | |
| `status` | Enum | | `PROF_PRESENT`, `PROF_MISSING` |
| `voted_at` | Timestamp | | |

---

## 📱 Part 2: Local JSON Files (Personal Data)

*Stored on device. Synced to Google Drive when toggle enabled.*

---

### `/data/user.json`
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "full_name": "Attaullah",
  "profile_image": "path/to/local.jpg",
  "university_id": "uuid",
  "home_hostel_id": "uuid",
  "default_section": "A",
  
  "settings": {
    "theme_mode": "SYSTEM",
    "notifications_enabled": true,
    "is_private_mode": false,
    "google_sync_enabled": true,
    "last_sync_at": "2026-01-13T10:00:00Z"
  }
}
```

### `/data/enrollments.json`
```json
[
  {
    "enrollment_id": "uuid",
    "course_code": "CS101",
    "custom_course": null,
    "section": "A",
    "target_attendance": 75.0,
    "color_theme": "#FF5733",
    
    "stats": {
      "total_classes": 40,
      "attended": 30,
      "safe_bunks": 2
    }
  },
  {
    "enrollment_id": "uuid",
    "course_code": null, // Null for custom courses
    "custom_course": {
      "code": "MY101", // Required unique code
      "name": "My Elective",
      "instructor": "Self",
      "total_expected": 30
      // Schedule is stored in custom_schedules.json linked by enrollment_id
    },
    "section": "A", // Can default to 'A'
    "target_attendance": 50.0,
    "color_theme": "#9B59B6",
    "stats": { "attended": 5, "total_classes": 10, "safe_bunks": 1 }
  }
]
```

*Note: CR status is derived from `cr_requests` table (Supabase), not stored locally.*

### `/data/custom_schedules.json`
User-created schedule slots for custom courses. **Location/WiFi bindings are stored separately in `schedule_bindings.json`**.

```json
[
  {
    "rule_id": "uuid",
    "enrollment_id": "uuid",
    "day_of_week": "TUE",
    "start_time": "14:00",
    "end_time": "15:00"
  }
]
```

### `/data/schedule_bindings.json`
**Unified user-specific location/WiFi bindings for ANY schedule slot** (works for both `global_schedules` and `custom_schedules`).

```json
[
  {
    "binding_id": "uuid",
    "user_id": "uuid",
    "rule_id": "uuid",           // FK to global_schedules.rule_id OR custom_schedules.rule_id
    "schedule_type": "GLOBAL",   // Enum: GLOBAL, CUSTOM (to disambiguate FK target)
    "location_name": "My Seat - Row 5",
    "location_lat": 28.541,
    "location_long": 77.123,
    "wifi_ssid": "IIITU_5G"
  }
]
```

### `/data/attendance.json`
```json
[
  {
    "log_id": "uuid",
    "enrollment_id": "uuid",
    "date": "2026-01-13",
    "status": "PRESENT",
    "source": "GEOFENCE",
    "confidence_score": 95,
    "verification_state": "AUTO_CONFIRMED",
    "evidence": {
      "gps_lat": 28.541,
      "gps_long": 77.123,
      "wifi_bssid": "AA:BB:CC",
      "activity": "STILL"
    },
    "synced": true
  }
]
```


### `/data/events.json`
```json
[
  {
    "event_id": "uuid",
    "title": "Gym",
    "date": "2026-01-15",
    "start_time": "07:00",
    "end_time": "08:00"
  }
]
```

### `/data/calendar_overrides.json`
*User's local overrides to hide specific calendar events.*
```json
[
  {
    "calendar_id": "uuid",
    "is_hidden": true
  }
]
```
**Feature:** Hide holidays/events from your personal calendar view.

### `/data/action_items.json`
*Unified inbox for Action Center - all pending actions and decisions.*
```json
[
  {
    "item_id": "uuid",
    "type": "CONFLICT", // CONFLICT, VERIFY, SCHEDULE_CHANGE, ASSIGNMENT_DUE, ATTENDANCE_RISK
    "status": "PENDING", // PENDING, RESOLVED
    "title": "Schedule Clash",
    "body": "Math Lecture vs Gym Session",
    "created_at": "2026-01-14T08:00:00Z",
    "resolved_at": null,
    "resolution": null, // ACCEPT_UPDATE, KEEP_MINE, YES_PRESENT, NO_ABSENT, ACKNOWLEDGED, MARK_DONE, SNOOZE, DETAILS
    "bg_color": "0xFFF3E8FF", // Hex color for card background (Flutter format)
    "accent_color": "0xFF6B46C1", // Hex color for accent/buttons
    "payload": {
      // Type-specific data (see below)
    }
  }
]
```

#### Type-Specific Payloads (Strict Schema)

**CONFLICT:**
```json
{
  "conflict_category": "OFFICIAL_VS_PERSONAL", // Enum: OFFICIAL_VS_PERSONAL, CR_VS_PERSONAL, PERSONAL_VS_PERSONAL
  "sourceA": {
    "label": "CR Update",
    "title": "Math Lecture",
    "subtitle": "Moved to 2 PM",
    "layer": "L2"
  },
  "sourceB": {
    "label": "Your Event",
    "title": "Gym Session",
    "subtitle": "Personal Calendar",
    "layer": "L3"
  }
}
```

**VERIFY:**
```json
{
  "course": "Mobile App Design",
  "message": "We detected you near LH-102. Were you present?"
}
```

**SCHEDULE_CHANGE:**
```json
{
  "course": "Data Structures",
  "message": "Prof. Rahul cancelled class due to emergency."
}
```

**ASSIGNMENT_DUE:**
```json
{
  "work": "Finance Dashboard",
  "course": "HCI",
  "due_text": "Due in 28 hours"
}
```

**ATTENDANCE_RISK:**
```json
{
  "course": "Linear Algebra",
  "current_per": "72%",
  "message": "You need to attend next 3 classes to be safe."
}
```

### `/data/syllabus_progress.json`
```json
{
  "CS101": ["topic_id_1", "topic_id_3"],
  "PH100": ["topic_id_5"]
}
```
*Maps course_code to array of completed topic_ids*

### `/data/custom_syllabus.json`
*User-defined syllabus structure for custom courses only.*
```json
[
  {
    "course_code": "CUSTOM_001",
    "units": [
      {
        "unit_id": "u1",
        "title": "Unit 1: Basics",
        "topics": [
          { "topic_id": "t1", "name": "Introduction" },
          { "topic_id": "t2", "name": "Setup" }
        ]
      }
    ]
  }
]
```
*Catalog courses fetch structure from university API; only custom courses use this file.*

### `/data/work_states.json`
*Tracks completion and visibility of course work.*
```json
[
  {
    "work_id": "uuid",
    "status": "SUBMITTED",
    "grade": "A",
    "is_hidden_from_calendar": false
  }
]
```

### `/data/resource_states.json`
```json
[
  {
    "resource_id": "uuid",
    "is_hidden": false,
    "is_favorite": true
  }
]
```

### `/data/menu_cache.json`
*User's local copy of mess menus. Can be modified locally or reset to global.*

```json
{
  "last_synced_at": "2026-01-13T10:00:00Z",
  "current_hostel_id": "uuid",
  
  "menus": [
    {
      "menu_id": "uuid",
      "hostel_id": "uuid",
      "day_of_week": "MON",
      "meal_type": "BREAKFAST",
      "start_time": "07:30",
      "end_time": "09:30",
      "items": "Idli, Sambar, Tea",
      "is_modified": false
    },
    {
      "menu_id": "uuid",
      "hostel_id": "uuid",
      "day_of_week": "MON",
      "meal_type": "LUNCH",
      "start_time": "12:30",
      "end_time": "14:30",
      "items": "Rice, Dal, Roti, Sabzi (I prefer extra rice)",
      "is_modified": true
    }
  ]
}
```

**Features:**
- Each menu has `hostel_id` → Can cache multiple hostels
- `current_hostel_id` → Which hostel to display by default
- `is_modified: true` → User edited this locally
- **Reset to Global**: Re-fetch from Supabase, set `is_modified = false`
- **Switch Hostel**: Filter `menus` by `hostel_id`, or fetch if not cached


### `/data/search_history.json`
```json
[
  { "query": "Compiler", "at": "2026-01-13T09:00:00Z" }
]
```

---

## � Part 3: File Storage

| Storage | Location | Contents |
|---------|----------|----------|
| Profile Images | Google Drive or Supabase Storage | `avatars/{user_id}.jpg` |
| OCR Scans | Google Drive | Timetable/menu photos |
| Resources | Supabase Storage | Syllabus PDFs, notes |

---

## 🔄 Part 4: Sync Strategy

| Data Type | Direction | When |
|-----------|-----------|------|
| Courses, Schedules, Calendar | Supabase → Local | App launch, realtime |
| CR Patches, Broadcasts | Supabase → Local | Realtime WebSocket |
| Verification Votes | Local → Supabase | On vote |
| All `/data/*.json` | Local → Google Drive | When sync toggle ON |

### Export Feature
When user exports data, create `adsum_backup.json`:
```json
{
  "exported_at": "2026-01-13T10:00:00Z",
  "user": { ... },
  "enrollments": [ ... ],
  "attendance": [ ... ],
  "events": [ ... ],
  "overrides": [ ... ]
}
```

---

## Summary

| Layer | Count | Storage |
|-------|-------|---------|
| Supabase SQL Tables | 16 | PostgreSQL |
| Local JSON Files | 11 | Device + Google Drive |
| File Buckets | 2 | Google Drive |
