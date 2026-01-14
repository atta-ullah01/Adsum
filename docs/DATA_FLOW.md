# Data Flow Documentation

This document describes how data flows between schema files and UI components.

### Import Feature
User can restore data from `adsum_backup.json`.

**Logic:**
1.  **Read JSON:** Parse backup file.
2.  **Merge Strategy:**
    *   **User/Settings:** Overwrite local `user.json` (except device-specifics).
    *   **Enrollments:** Upsert based on `enrollment_id`.
    *   **Attendance:** Upsert based on `log_id`.
    *   **Appends:** Add missing events/overrides.

---

## Subject Detail Page

### Stats Tab

| UI Element | Source File | Query/Derivation |
|------------|-------------|------------------|
| Attendance % | `enrollments.json` | `stats.attended / stats.total_classes × 100` |
| Safe Bunks | `enrollments.json` | `stats.safe_bunks` |
| Total Classes | `enrollments.json` | `stats.total_classes` |
| Attended | `enrollments.json` | `stats.attended` |
| 7-Day History | `attendance.json` + `academic_calendar.json` | Filter last 7 days. Merge with holidays/cancellations. |

#### History Log (View Calendar)

**Sources:**
- `attendance.json` (Base attendance status)
- `academic_calendar.json` (Holidays)
- `schedule_modifications` table (Cancellations/Reschedules)

**Layered Retrieval Logic:**
1. **Initialize Grid:** Generate dates for the month.
2. **Apply Holidays:** Query `academic_calendar` for holidays on these dates. Mark as `HOLIDAY`.
3. **Apply Patches:** Query `schedule_modifications` for `CANCELLED` status. Mark as `CANCELLED`.
4. **Apply Attendance:** For remaining "Class" days, query `attendance.json` for status.


**Verify Flow (for PENDING):**
- User taps "Verify Attendance" → Selects "I was Present" / "I was Absent"
- Updates `attendance.json`: `status` + `verification_state` = `MANUAL_OVERRIDE`

**Edit Flow (for PRESENT/ABSENT):**
- User taps "Edit Status" → Toggles status
- Updates `attendance.json`: `status` changed, `verification_state` = `MANUAL_OVERRIDE`

### Syllabus Tab

**Sources:**
| File/Table | Purpose |
|------------|---------|
| `syllabus_units` | Catalog course unit structure (sync'd) |
| `syllabus_topics` | Catalog course topic definitions (sync'd) |
| `custom_syllabus.json` | Custom course structure (user-defined) |
| `syllabus_progress.json` | Completed topic IDs (both types) |

**Data Retrieval Logic:**
```
1. Check: Is enrollment.course.is_custom = true?
   ├─ YES (Custom) → Load structure from custom_syllabus.json WHERE course_code
   └─ NO (Catalog) → Load structure from syllabus_units + syllabus_topics WHERE course_code

2. Load progress: syllabus_progress.json[course_code] → Array of topic_ids

3. Merge: For each topic in structure:
   └─ topic.done = (topic_id IN progress_array)
```

**UI Element Mapping:**
| UI Element | Source | Rendering |
|------------|--------|-----------|
| Progress Card | Merged data | `completed / total × 100%` |
| Modules Accordion | `units[]` | Expandable list grouped by unit_order |
| Topic Checkbox | `topic.done` | Checked if topic_id in progress |
| Edit/Import Button | `is_custom` | Shown only for custom courses |

**Write Actions:**
| Action | Target File | Operation |
|--------|-------------|-----------|
| Toggle topic | `syllabus_progress.json` | Add/remove `topic_id` from array |
| Save syllabus (custom) | `custom_syllabus.json` | Overwrite units/topics structure |

### Work Tab

**Sources:**
| File/Table | Purpose |
|------------|---------|
| `course_work` | Assignment/quiz/exam definitions |
| `work_states.json` | User's completion status + grade |

**Data Retrieval Logic:**
```
1. Load work: SELECT * FROM course_work WHERE course_code = ?
2. Load states: work_states.json[work_id]
3. Merge: For each work item, attach status from states (PENDING/SUBMITTED/GRADED)
4. Filter: Optionally hide items where is_hidden_from_calendar = true
```

**UI Element Mapping:**
| UI Element | Source | Rendering |
|------------|--------|-----------|
| Task List | `course_work[]` | Filter by `course_code`, sort by `due_at` |
| Assignment Card | `course_work` (type=ASSIGNMENT) | **Title**, Due (`due_at`), Status |
| Quiz Card | `course_work` (type=QUIZ) | **Title**, Window (`start_at`-`due_at`), Duration (`duration_minutes`) |
| Exam Card | `course_work` (work_type=EXAM) | **Title**, Date (`start_at`), Venue (`venue`) |

**Work Detail Page Mapping:**
| UI Element | Schema Table | Schema Field |
|------------|--------------|--------------|
| Course Tag | `course_work` | `course_code` |
| Type Badge | `course_work` | `work_type` |
| Title | `course_work` | `title` |
| Due/Date | `course_work` | `due_at` / `start_at` |
| Duration | `course_work` | `duration_minutes` |
| Venue | `course_work` | `venue` |
| Description | `course_work` | `description` |
| Discussion | `work_comments` | `text`, `user_id`, `created_at` |

**Write Actions:**
| Action | Target | Operation |
|--------|--------|-----------|
| Mark Done | `work_states.json` | Set `status = "SUBMITTED"` |
| Hide | `work_states.json` | Set `is_hidden_from_calendar = true` |
| Post Comment | `work_comments` | INSERT row |

### Info Tab
*Read-only overview of course details and settings.*

**Sources:**
| File | Purpose |
|------|---------|
| `enrollments.json` | Course metadata (`custom_course` or `course_code`), Section, Color |
| `courses` table | Catalog course metadata (name, instructor) |
| `schedule_bindings` | Counts of bound slots vs default |

**Data Retrieval Logic:**
```
1. Fetch Slots:
   ├─ Catalog: SELECT * FROM global_schedules WHERE course_code
   └─ Custom: Read custom_schedules.json WHERE enrollment_id

2. Fetch Bindings: Read schedule_bindings.json WHERE rule_id IN (slots)

3. Merge for Display:
   For each slot:
   ├─ If binding exists → Status = "Bound: " + binding.location_name
   └─ Else → Status = "Default: " + slot.location_name
```

**UI Element Mapping:**
| UI Element | Source |
|------------|--------|
| **Course Details** | Name, Code, Instructor (from `enrollments` or `courses`) |
| **Catalog Tag** | Shown if `custom_course == null` |
| **Schedule Summary** | List slots; show derived "Bound" / "Default" status (no edit) |
| **Enrollment** | Read-only display of `section` and `target_attendance` |
| **Settings** | Read-only display of `color_theme` |

**Write Actions:**
*None.* All edits must be done via `Manage Courses Page`.

### Manage Courses Page
*Centralized hub for all course configuration.*

**Two Categories:**

| Section | Custom Course | University Catalog |
|---------|--------------|-------------------|
| **Course Details** | All editable (Name, Code, Instructor, Expected) | Read-only + "University Catalog" tag |
| **Schedule Structure** | Add/Remove/Edit Slots | Read-only (from `global_schedules`) |
| **Slot Bindings** | Per-slot GPS/WiFi binding (via `schedule_bindings`) | Per-slot GPS/WiFi binding (overrides `global_schedules` defaults) |
| **My Enrollment** | Section, Target Attendance | Section, Target Attendance |
| **Settings** | Color Theme | Color Theme |
| **Actions** | "Delete Course" | "Unenroll from Course" |

**Sources:**
| File | Purpose |
|------|---------|
| `enrollments.json` | User's enrollment data (including `custom_course` definition) |
| `courses` table | Global course metadata (read-only for Catalog) |
| `global_schedules` | Default schedule for Catalog courses |
| `custom_schedules.json` | Schedule for Custom courses |
| `schedule_bindings.json` | User's per-slot location override (both types) |

**Write Actions:**
| Action | Target | Condition | Operation Logic |
|--------|--------|-----------|-----------------|
| Update Custom Course | `enrollments.custom_course.*` | Custom only | **OVERWRITE** entire object |
| Update Schedule | `custom_schedules.json` | Custom only | **add/remove** slots |
| Update Section | `enrollments.section` | Both | **OVERWRITE** field |
| Update Target | `enrollments.target_attendance` | Both | **OVERWRITE** field |
| Update Theme | `enrollments.color_theme` | Both | **OVERWRITE** field |
| Update Slot Binding | `schedule_bindings.json` | Both | **UPSERT** (create or update binding) |
| Delete Course | `enrollments` entry | Custom only | **DELETE** row |
| Unenroll | `enrollments` entry | Catalog only | **DELETE** row |

---

## Academics Page

**Source:** `enrollments.json`

| UI Element | Query |
|------------|-------|
| Course List | All entries in `enrollments.json` |
| Smart Summary (Safe/Risk) | Count courses where `stats.attended / stats.total_classes < target_attendance` |
| Course Card Stats | `stats.attended`, `stats.total_classes`, `stats.safe_bunks` |

---

## Action Center

**Source:** `action_items.json`

| Tab | Query |
|-----|-------|
| Pending | Filter by `status = "PENDING"` |
| History | Filter by `status = "RESOLVED"` |

**UI Rendering:**
- Card color: `bg_color`, `accent_color`
- Content: `type`-specific payload fields

---

## Dashboard

### Priority Alert Carousel

**Sources:** `action_items.json`, `enrollments.json`, `events.json`

| Alert Type | Source | Condition |
|------------|--------|-----------|
| Assignment Due | `action_items.json` | `type = "ASSIGNMENT_DUE"` |
| Attendance Risk | `action_items.json` | `type = "ATTENDANCE_RISK"` |
| Conflict | `action_items.json` | `type = "CONFLICT"` |
| Upcoming Exam | `events.json` | `type = "EXAM"` within 48h |

### Timeline

**Sources:** `enrollments.json` → schedule, `schedule_modifications` table, `events.json`

| Card Type | Source |
|-----------|--------|
| Course (Normal) | Base schedule from enrollment |
| Course (Cancelled/Rescheduled) | `schedule_modifications` table |
| Personal Event | `events.json` |
| Mess | `mess_menu.json` |

---

## Global Search

**Sources:** Multiple

| Category | Source File | Searchable Fields |
|----------|-------------|-------------------|
| Courses | `enrollments.json` → `course` | `name`, `code` |
| Professors | `enrollments.json` → `course.instructor` | `instructor` |
| Assignments | `action_items.json` | `title` (where type = ASSIGNMENT_DUE) |
| Events | `events.json` | `title` |

---

## Mess Menu

**Source:** `mess_menu.json`

| UI Element | Query |
|------------|-------|
| Menu Cards | Filter by `hostel_id` + `date` |
| Meal Tabs | Group by `meal_type` (B/L/S/D) |

---

## Calendar

**Sources:** `events.json`, `academic_calendar.json`, `schedule_modifications` table

| Event Type | Source | Color |
|------------|--------|-------|
| Holiday | `academic_calendar.json` | 🔴 Pink |
| Day Swap | `academic_calendar.json` | 🔵 Blue |
| Major Exam | `academic_calendar.json` | 🟡 Yellow |
| CR Change | `schedule_modifications` | 🔵 Blue |
| Personal | `events.json` | 🟣 Purple |

---

---
 
## Course Work Issuance (CR-Only)

**Entry Points:** `/academics`, `/subject-detail` (Work Tab FAB)

**Issuance Flow:**
1. CR opens "Create Work" sheet.
2. Selects **Type** (Assignment, Project, Quiz, Exam).
3. Fills type-specific fields:
   - *Exam:* `start_at`, `venue`
   - *Quiz:* `start_at`, `duration_minutes`
   - *Assignment/Project:* `due_at`
4. Taps "Broadcast to Class".
5. Client signs payload with CR's Ed25519 private key.
6. Supabase Edge Function verifies signature.
7. Row inserted into `course_work` table.
8. All students enrolled in `course_code` receive the new work item on sync.

**Write Actions:**
| Action | Target Table | Key Fields Written |
|--------|--------------|----------------------|
| **Create Assignment** | `course_work` | `title`, `due_at`, `cr_user_id`, `cr_signature` |
| **Create Project** | `course_work` | `title`, `due_at`, `cr_user_id`, `cr_signature` |
| **Create Quiz** | `course_work` | `title`, `start_at`, `due_at` (window end), `duration_minutes` |
| **Create Exam** | `course_work` | `title`, `start_at`, `venue` |

---

 ## CR Authority Suite

### Schedule Patcher Page

**Route:** `/cr/patch`

**Sources:**
| Data | Source | Purpose |
|------|--------|---------|
| Enrolled Courses | `enrollments.json` | Display course cards (filter: `is_custom = false`) |
| CR Status | `cr_requests` table | Determine Authorized/Pending/Locked per course |
| Schedule Slots | `global_schedules` table | List available slots for selected course |

**Data Retrieval Logic:**
```
1. Load global enrollments: enrollments.json WHERE is_custom = false
2. For each course, check cr_requests WHERE user_id + course_code + section
   ├─ status = APPROVED → Authorized (show patch form)
   ├─ status = PENDING → Pending (show waiting message)
   └─ No record → Locked (show Request Access button)
3. If Authorized, load slots: global_schedules WHERE course_code + section
```

**Write Actions:**

| Action | Target Table | Data Written |
|--------|--------------|--------------|
| Request Access | `cr_requests` | `user_id`, `course_code`, `section`, `status = PENDING` |
| Cancel Class | `schedule_modifications` | `target_rule_id`, `affected_date`, `action = CANCEL`, `note`, `cr_signature` |
| Reschedule | `schedule_modifications` | `target_rule_id`, `affected_date`, `new_date`, `new_start_time`, `new_end_time`, `new_location`, `note`, `cr_signature` |
| Extra Class | `schedule_modifications` | `course_code`, `section`, `new_date`, `new_start_time`, `new_end_time`, `new_location`, `note`, `cr_signature` |
| Swap Room | `schedule_modifications` | `target_rule_id`, `affected_date`, `action = SWAP_ROOM`, `new_location`, `note`, `cr_signature` |

**Signing & Verification Flow:**
```
1. Client (CR Device):
   ├─ payload = { course_code, action, date, new_time, ... }
   ├─ signature = Ed25519_Sign(message: JSON(payload), privateKey: SecureStorage.key)
   └─ POST /patch { ...payload, signature }

2. Server (Edge Function / Database Trigger):
   ├─ Fetch public_key FROM signing_keys WHERE user_id = request.user_id
   ├─ is_valid = Ed25519_Verify(message: JSON(payload), signature, publicKey)
   │
   ├─ TRUE  → INSERT into schedule_modifications (Patch Applied)
   └─ FALSE → REJECT (Error 403: Invalid Signature)
```
*Integrity Guarantee: Relies on private key remaining on device. Prevents token theft exploits.*

### Audit Trail Page

**Route:** `/cr/audit`

**Sources:**
| Data | Source |
|------|--------|
| Patch History | `schedule_modifications` WHERE `cr_user_id = current_user` |
| Course Details | `courses` table (for display name) |

**Data Retrieval Logic:**
```
1. Load patches: schedule_modifications WHERE cr_user_id = ? ORDER BY created_at DESC
2. Group by affected_date for timeline display
3. For each patch, resolve course_code → course name from courses table
```

**UI Element Mapping:**
| UI Element | Source Field |
|------------|--------------|
| Event Title | `courses.name` (via `course_code`) |
| Status Badge | `action` (CANCEL → Red, RESCHEDULE → Blue, etc.) |
| Time | `affected_date` + `new_start_time` |
| Reason | `note` |
| Issued At | `created_at` |


---

## Settings & Profile Data Flow

### 1. Profile Data (Cloud + Local)
- **Read**: App Launch -> Fetch `users` table -> Cache to Local Prefs -> Display in Settings.
- **Write**: Edit Profile -> Optimistic Update UI -> API PATCH `users` -> Persist to Local Prefs.

### 2. App Preferences (Local Only)
- **Scope**: Dark Mode, Notifications, Private Mode.
- **Storage**: `SharedPreferences` / `Hive` Box.
- **Flow**: Toggle Switch -> Write Key-Value Pair -> Trigger App Rebuild.

**UI Element Mapping:**
| UI Element | Source |
|------------|--------|
| Avatar | `users.photo_url` (Cloud) / Local Placeholder |
| Name | `users.full_name` (Cloud) |
| Size | `universities.name` (via `users.university_id`) |
| Hostel | `hostels.name` (via `users.hostel_id`) *Filtered by Uni* |
| Dark Mode Toggle | `prefs.darkMode` (Local Boolean) |
| Notifications Toggle | `prefs.notificationsEnabled` (Local Boolean) |
| Private Mode | `prefs.privateMode` (Local Boolean) |

**Write Actions:**
| Action | Target | Operation |
|--------|--------|-----------|
| Update Profile | `users` table | `UPDATE users SET full_name = ?, hostel_id = ? ...` |
| Toggle Theme | Local Prefs | `prefs.setBool('darkMode', val)` |
| Toggle Notifications | Local Prefs | `prefs.setBool('notificationsEnabled', val)` |
| Toggle Privacy | Local Prefs | `prefs.setBool('privateMode', val)` (Stops Sync) |
| Nuke Data | Cloud + Local | `DELETE FROM users ...` AND Clear Local Storage |

---

## User Data Management (Import/Export)

**Context:** Users can backup their personal data (attendance, custom events, settings) to a JSON file and restore it later.

### Export Flow
```
1. User tap "Export Data"
2. App queries Local Database (drift/hive):
   - Fetch User Profile (except Auth tokens)
   - Fetch Attendance Logs
   - Fetch Custom Events/Overrides
   - Fetch App Settings
3. Serialize to JSON
4. Write to device file system (Download/Share sheet)
```

### Import Flow
```
1. User tap "Import Data" -> Pick JSON file
2. Parse JSON & Validate Schema
3. For each entity type:
   - Conflict Strategy: Merge/Overwrite (User prompted or Auto-merge by timestamp)
   - Upsert into Local Database
4. Trigger UI refresh (Recompute stats)
```
