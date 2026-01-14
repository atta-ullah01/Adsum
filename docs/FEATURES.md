# Adsum Features

## 1. Core System & Data Integrity

* **3-Layer Schedule Merging:** Automatically resolves conflicts between University defaults (L1), Class Representative updates (L2), and User customizations (L3).
* **Real-Time "Source of Truth":** Always displays the most accurate schedule by prioritizing personal overrides > CR updates > University base data.
* **Offline-First Architecture:** Full functionality without internet; syncs changes when connectivity is restored.
* **Referential Overrides:** "Bunk" or "Edit" statuses stick to the specific class (Course UUID) even if the time slot changes.
* **Conflict Resolution UI:** Manually prompts the user to decide when local edits conflict with server updates.

---
## 1. Onboarding & Identity Flow

### University First Identity
*   **University Selection**: Primary entry point. User must select University first.
*   **Conditional Hostel Access**: Hostel list is fetched only *after* University selection.
*   **Optional Fields**:
    *   **Hostel**: Optional. Not all students live on campus.
    *   **Section**: Optional, defaults to 'A'.
    *   **Full Name**: Optional, defaults to 'Student' or derived from email.

---

## 2. Core System & Data Integrity

### Date Strip
*Horizontal 7-day date picker at the top of the dashboard.*

| Element | Description |
|---------|-------------|
| **Day Capsules** | 7 days: 3 past, today, 3 future |
| **Today Capsule** | Shows "Today" label + primary color ring |
| **Selected Day** | Dark fill with shadow highlight |
| **Past Days** | Dimmed grey styling |
| **Future Days** | White background |
| **Event Dot** | Yellow dot indicates days with events |
| **Tap Action** | Selects day, refreshes timeline below |

### Priority Alert Carousel
*Top section showing critical, time-sensitive items.*

| Alert Type | Trigger Condition |
|------------|-------------------|
| Assignment Due Soon | Due within 24-48 hours |
| Urgent Broadcast | `is_urgent = true` from CR |
| Attendance Risk | Current % below target |
| Pending Conflict | Unresolved schedule clash |
| Upcoming Exam | Starting within 48 hours |

#### Visibility Rules

| Selected Date | Carousel Behavior |
|---------------|-------------------|
| **Today** | ✅ Show all relevant alerts |
| **Past Date** | ❌ Hide carousel entirely |
| **Future Date** | ⚠️ Show only date-specific alerts (exam/assignment on that day) |
| **No Active Alerts** | ❌ Hide carousel (don't show empty) |

### Card Data Fields & Actions

| Card Type | Display Fields | Tap Action | Secondary Action |
|-----------|----------------|------------|------------------|
| **Course (Normal)** | Title, Time, Loc, Prof, Source | **Subject Detail** | Pulse → **Diagnostics** |
| **Course (Cancelled)**| Title, *Original Time*, "Cancelled" Badge | **Subject Detail** | *Dimmed Card (Visual Only)* |
| **Course (Rescheduled)**| Title, *New Time*, "Rescheduled" Badge | **Subject Detail** | *Sorted by New Time* |
| **Course (Extra)** | Title, Time, Loc, "Extra Class" Badge | **Subject Detail** | - |
| **Mess** | Meal Type, Time, Hostel, Menu Items | **Mess Menu** | **Edit Note** |
| **Exam/Quiz** | Title, Time, Loc, Duration, "Blocking"| **Subject Detail** | - |
| **Personal** | Title, Time, Note | **Edit Event** | - |

| Alert Type | Display Fields | Tap Action | Color |
|------------|----------------|------------|-------|
| **Assignment** | Title, Due Time, "Due Soon" | **Assignment Detail** | 🔵 Blue |
| **Attendance** | Course, Current %, Target %, "Risk" | **Subject Detail** | 🟠 Orange |
| **Exam** | Title, Starts In, "Super Event" | **Exam Command Center** | � Red |

### Source Provenance Colors
*Visual indication of where each schedule item originates.*

| Source | Color | Icon | Example |
|--------|-------|------|---------|
| **Admin (Official)** | Grey/Neutral | Shield | Base university schedule |
| **CR (Update)** | 🔵 Blue | Pencil | Class moved by CR |
| **User (Personal)** | 🟣 Purple | Person | Gym session, personal event |

### Action Center
*Unified inbox for all pending actions and decisions.*

**Route:** `/action-center`

#### Purpose
Single destination for everything requiring user attention, decision, or acknowledgment. Merges conflicts, notifications, and verifications into one page.

#### UI Structure

| Tab | Content |
|-----|---------|
| **Pending** | Items requiring user action |
| **History** | Resolved/acknowledged items |

#### Item Types

| Type | Icon | Trigger | Primary Action | Secondary Action |
|------|------|---------|----------------|------------------|
| **CONFLICT** | ⚔️ | Schedule clash (L1/L2/L3 overlap) | Accept Update | Keep Mine |
| **VERIFY** | ❓ | Class ended with medium confidence | Yes, Present | No, Absent |
| **SCHEDULE_CHANGE** | ℹ️ | CR modified/cancelled class | Acknowledge | — |
| **ASSIGNMENT_DUE** | 📝 | Assignment due in 24-48h | Mark Done | Snooze |
| **ATTENDANCE_RISK** | ⚠️ | Subject below target attendance % | Details | — |

*Scalable: New types can be added (e.g., `BROADCAST`, `EXAM`) as features mature.*

#### Conflict Types (Subset)
When `type = CONFLICT`:

| Category | Layers | Example |
|----------|--------|---------|
| `OFFICIAL_VS_PERSONAL` | L1 ↔ L3 | "Math @ 9AM" vs "Gym @ 9AM" |
| `CR_VS_PERSONAL` | L2 ↔ L3 | "Math moved to 2PM" vs "Gym" |
| `PERSONAL_VS_PERSONAL` | L3 ↔ L3 | "Gym @ 7AM" vs "Jog @ 7AM" |

#### Resolution Actions
| Action | Type | Effect |
|--------|------|--------|
| **Accept Update** | CONFLICT | Accept CR/Admin change, hide user's conflicting item |
| **Keep Mine** | CONFLICT | Keep user's item, decline the update |
| **Yes, Present** | VERIFY | Confirm attendance for the class |
| **No, Absent** | VERIFY | Mark as absent |
| **Mark Done** | ASSIGNMENT_DUE | Mark assignment complete, move to history |
| **Snooze** | ASSIGNMENT_DUE | Dismiss notification temporarily |
| **Acknowledge** | SCHEDULE_CHANGE | Mark change as seen |
| **Details** | ATTENDANCE_RISK | Navigate to Subject Detail (Stats Tab) for recovery plan |

#### History Log
Audit trail of past decisions:
- "Kept **Gym** over **Math** • Oct 21"
- "Verified present for **CS101** • Oct 20"
- "Acknowledged: CS101 moved to 3 PM • Oct 19"

### Global Search
*Full-text search across all user-relevant data.*

#### Searchable Content

| Category | Data Source | Searchable Fields |
|----------|-------------|-------------------|
| **Courses** | `enrollments.json` → `course` | `name`, `code` |
| **Professors** | `enrollments.json` → `course.instructor` | `instructor` (name) |
| **Assignments** | Supabase `course_work` | `title`, `due_at` |
| **Events** | `events.json` | `title` |
| **Custom Classes** | `custom_schedules.json` | Linked via `enrollment_id` → course |

#### Result Display
Each result shows:
- **Icon**: Category indicator (📚 Course, 👤 Professor, 📝 Assignment, 📅 Event)
- **Title**: Primary matched field
- **Subtitle**: Context (e.g., "Assignment • Due Jan 15")

#### History
Recent searches stored in `/data/search_history.json`.

### Other Features
* **Live Pulse:** If a class is currently live, card shows pulsing "Live • Tap to Verify" button.
* **Diagnostics Sheet:** Tapping Pulse opens half-sheet with GPS/WiFi/Activity confidence scores.
### Global FAB Menu
*Floating command button that opens a bottom sheet for quick navigation and actions.*

#### Navigation (4 items)
| Icon | Label | Route |
|------|-------|-------|
| 📊 | Academics | `/academics` |
| 🔔 | Actions | `/action-center` |
| 📅 | Calendar | `/calendar` |
| 🍽️ | Mess | `/mess` |

#### Quick Actions (3 items)
| Action | Description | Route |
|--------|-------------|-------|
| **Add Course** | Enroll in a new subject | `/manage-courses` |
| **Add Event** | Create personal reminder | `/calendar` |
| **Settings** | App preferences & profile | `/settings` |

---

## Subject Detail Page
*Course-specific view with attendance stats, syllabus progress, assignments, and settings.*

**Route:** `/subject-detail`

**Navigation:** From Dashboard timeline cards, Academics page course cards, or search results.

### Stats Tab

| UI Element | Description | Data Source |
|------------|-------------|-------------|
| **Attendance %** | Large pastel green card | `enrollments.json` → `stats.attended / stats.total_classes × 100` |
| **Safe Bunks** | Pastel orange card | `enrollments.json` → `stats.safe_bunks` |
| **Total Classes** | Pastel blue card | `enrollments.json` → `stats.total_classes` |
| **Attended** | Pastel purple card | `enrollments.json` → `stats.attended` |
| **7-Day History** | Horizontal strip with check/cross icons | `attendance.json` → last 7 entries |

**7-Day History Icons:**
| Status | Icon | Color |
|--------|------|-------|
| Present | ✓ | 🟢 Green |
| Absent | ✗ | 🔴 Red |
| No Class | — | ⚪ Grey |

#### Drill-down: History Calendar View
*Accessed via "View Calendar" button. Route: `/history-log`*

| UI Element | Description | Data Source |
|------------|-------------|-------------|
| **Calendar Grid** | Monthly view with color-coded status indicators | `attendance.json` filtered by `enrollment_id` |
**Status Indicators** | Colored dots/backgrounds on dates | `status` field or Event Type |
| **Day Details** | Metadata for the selected date below the grid | Specific log entry or event fields |

**Day Type Mapping:**
| Type | Source | Color | Visual |
|------|--------|-------|--------|
| **Class** | Schedule | (See Status) | Status Dot |
| **Holiday** | Academic Calendar | 🟣 Purple | Purple Dot |
| **Cancelled** | CR/Prof | ⚪ Grey | "Cancelled" Label |
| **Rescheduled** | CR/Prof | 🔵 Blue | New Time Indicator |
| **No Class** | Schedule | ⚪ white | Empty/Grey |

**Status Color Mapping (For "Class" Days):**
| Status | Verification | Color | Meaning |
|--------|--------------|-------|---------|
| PRESENT | AUTO_CONFIRMED | 🟢 Solid Green | Verified by Geofence/WiFi |
| PRESENT | MANUAL_OVERRIDE | 🟢 Hollow Green | Manually marked present |
| ABSENT | — | 🔴 Red | Missed class |
| PENDING | — | 🟡 Yellow | Needs confirmation |

**Day Details Panel:**
- **Date:** Selected date (e.g., "Mon, 13 Jan")
- **Type/Status:** "Holiday: Diwali" or "Present • Verified by WiFi"
- **Time:** Class timing
- **Verification Source:** GPS/WiFi data if available

**Actions:**
- Tap Date → View details
- "Verify Attendance" (for Pending) → Confirm "I was Present/Absent"
- "Edit Status" (for Marked) → Quick toggle between Present/Absent

### Syllabus Tab

| UI Element | Description | Data Source |
|------------|-------------|-------------|
| **Progress Card** | "X/Y Topics" with linear progress bar | `syllabus_progress.json` |
| **Modules Accordion** | Expandable unit lists | `syllabus_progress.json` → units |
| **Topic Checkboxes** | Mark individual topics complete | `syllabus_progress.json` → topics |

**Actions:**
- "Edit/Import Syllabus" (Custom courses only) → **Coming Soon** *(Schema ready)*
- Tap checkbox → Toggle topic completion

### Work Tab

| UI Element | Description | Data Source |
|------------|-------------|-------------|
| **Task List** | All assignments/quizzes for this course | `course_work` filtered by `course_code` |
| **Task Card** | Displays type-specific details | `course_work` + `work_states.json` |

**Card Types:**

| Type | Visuals | Unique Elements | Inputs Required (Creation) |
|------|---------|-----------------|----------------------------|
| **Assignment** | 📘 Blue Document | Due Date | Due Date |
| **Project** | 📗 Green Cube | Due Date | Due Date |
| **Quiz** | 🟣 Purple Timer | Window + Duration | Start Time, Duration (mins) |
| **Exam** | 🔴 Red Alert | Date/Time + Venue | Start Time, Venue (e.g., "LH-1") |

**Actions:**
- **Create Work (FAB):** Visible on Work Tab. Pre-fills subject.
- **Tap Card:** Opens Work Detail Page.
- **Mark Done:** Updates local status.

**Course Work Creation (CR-Only):**
- **Create Work FAB:** Visible on Work Tab for CRs.
- **Validation:** Exams require Venue; Quizzes require Duration.
- **Signing:** CR signs the payload with Ed25519 key.
- **Sync:** Uploaded to `course_work` table → synced to all enrolled students.

### Info Tab
*Read-only view of course metadata and personal settings. All editing is moved to the "Manage Courses" page.*

| Section | Display |
|---------|---------|
| **Course Details** | Read-only metadata (Name, Code, Instructor) |
| **Schedule** | List of classes with current binding status (Bound/Unbound) |
| **Enrollment** | View current Class Section & Target Attendance |
| **Setting** | **Description** |
|---|---|
| **Edit Profile** | Update Name, Section |
| **Smart Selection** | Select University -> Filtered Hostel List |
| **Privacy Mode** | Hide sensitive data from UI |
| **Dark Mode** | Toggle app theme |
| **Notifications** | Toggle push notifications |

---

## Manage Courses Page
*Centralized hub for adding, editing, and deleting courses.*

**Route:** `/manage-courses`

### Capabilities

| Feature | Global Courses | Custom Courses |
|---------|----------------|----------------|
| **Edit Details** | Read-only (University managed) | Editable (Name, Code, Prof) |
| **Edit Schedule** | Read-only | Add/Remove/Edit Slots |
| **Edit Bindings** | **Set GPS/WiFi per slot** | Set GPS/WiFi per slot |
| **Enrollment** | **Edit Section & Target %** | Edit Target % |
| **Settings** | **Edit Card Color** | Edit Card Color |
| **Actions** | Unenroll | Delete |

**Global Course Bindings:**
*   Users can override the University's default location for specific slots (e.g., "I attend the lab slot in a different room").
*   Can bind specifically to a WiFi SSID or GPS Geofence.

### Create Custom Course
*Interface for manually adding independent subjects not in the university catalog.*

**Route:** `/create-custom-course`

**Purpose:** Add extra electives, personal tuition, or gym schedules that act like courses.

| Section | Fields |
|---------|--------|
| **Metadata** | Course Name, **Course Code**, Instructor Name |
| **Schedule** | Day, Start Time, End Time, Location (with optional Bindings) |
| **Config** | Target Attendance % (Default 75%), Section (Default 'A') |
| **Theme** | Card Color Picker (Pastel Palette) |

**System Constraints:**
1.  **Unique Course Code:** You cannot create a course with a code (e.g., "CS-101") that already exists in your `enrollments.json`. Duplicate codes must be resolved by renaming one.
2.  **Mandatory Fields:** Name and Code are required.
3.  **Schedule Conflicts:** System allows overlaps but flags them as `CONFLICT` in the **Action Center** for manual resolution (L3 vs L1/L2).

---

---

## 3. Academic Calendar

### Event Types

| Type | Source | Color | Description |
|------|--------|-------|-------------|
| Holiday | `academic_calendar` | 🔴 Red | No classes (Diwali, Republic Day) |
| Major Exam | `academic_calendar` | 🟡 Yellow | End semester, mid-terms |
| Day Swap | `academic_calendar` | 🔵 Blue | "Follow Monday schedule on Saturday" |
| Class Cancel | `schedule_modifications` | 🔵 Blue | Specific class cancelled by CR |
| Reschedule | `schedule_modifications` | 🔵 Blue | Class moved to new time |
| Extra Class | `schedule_modifications` | 🔵 Blue | Additional class added |
| Assignment | `course_work` | 🟠 Orange | Due date markers |
| Quiz | `course_work` | 🟡 Yellow | Same-day quiz |
| Personal | `events.json` | 🟣 Purple | User-created events |

### Features
* **Multiple Events Per Day:** Calendar shows up to 3 colored dots per day.
* **Agenda View:** All events for selected day shown as separate cards.
* **User Overrides:** Hide events locally via `calendar_overrides.json`.
* **Holiday Injection:** OCR/PDF parsing to import official holiday lists.

---

## 4. Smart Attendance Engine

* **Hybrid Tracking (JIT-Geofence):** Low-power Geofence wakes the app, Activity Recognition confirms presence.
* **Reschedule Awareness:** Automatically adjusts tracking if class is moved by CR.
* **Safe-to-Skip Calculator:** Shows how many classes you can miss while maintaining target %.
* **Deficit Recovery:** Calculates consecutive classes needed to recover low attendance.
* **Granular Location Binding:** Set specific Geofence or Wi-Fi fingerprints per subject.

---

## 5. Mess & Dining

* **Weekly Rotation Menu:** View Breakfast/Lunch/Snacks/Dinner for any hostel.
* **Multi-Hostel Caching:** Cache menus from multiple hostels locally.
* **Local Menu Editing:** Modify menu items locally (personal notes like "Extra curd").
* **Reset to Global:** Re-sync local changes with official hostel menu.
* **Menu OCR:** Scan whiteboard menus to digitize them.
* **Home Hostel Binding:** Default hostel loads automatically on app start.

---

## 6. Academic Collaboration & Planning

* **Course Injection (OCR):** Scan Course Registration Slip to set up semester.
* **Assignment Priority Heap:** Sorted by deadline (closest = highest priority).
* **Exam Command Center:** "Super Events" that block all other classes.
* **Syllabus Tracker:** Mark topics as complete, view progress per course.
* **Course Resources:** Access shared notes, PDFs, and links per course.
* **Clarification Threads:** Q&A attached to specific assignments.

---

## 7. CR (Class Rep) Authority Suite

*Exclusive tools for Class Representatives to manage course schedules. Only available for catalog (global) courses, not custom courses.*

### CR Designation

| Aspect | Description |
|--------|-------------|
| **Scope** | Per course + section (e.g., CR for "CS101 Section A") |
| **Assignment** | Request-based with admin approval |
| **Multiple CRs** | Allowed per section (useful for large sections or backup) |
| **Data Source** | `cr_requests` table (Supabase) |
| **Visibility** | Other students in same section see "CR" badge |

### CR Access & Request Flow

**Entry Point:** Schedule Patcher page (`/cr/patch`) accessed via FAB Quick Actions.

The Schedule Patcher page shows **all enrolled global courses** in a horizontal selector. Each course displays its CR authorization status:

| Status | Icon | Description | Available Actions |
|--------|------|-------------|-------------------|
| **Authorized** 🔑 | Key | User is approved CR | Full patch workflow |
| **Pending** ⏳ | Clock | Request under review | View-only (waiting) |
| **Locked** 🔒 | Lock | Not a CR | "Request Access" button |

#### Integrated Request Flow

| Step | Actor | Action |
|------|-------|--------|
| 1 | Student | Opens Schedule Patcher, selects unauthorized course |
| 2 | Student | Taps "Request Access" button |
| 3 | System | Creates `cr_requests` entry with `status = PENDING` |
| 4 | Admin | Reviews and sets `status = APPROVED` or `REJECTED` |
| 5 | System | Notifies student; page updates to show new status |
| 6 | Student | First patch action triggers signing key generation |

### Schedule Patcher

*Step-by-step tool for CRs to modify class schedules with Pastel SaaS-inspired design.*

**Route:** `/cr/patch`

#### UI Components

| Component | Description |
|-----------|-------------|
| **Course Selector** | Horizontal list of pastel-colored cards with course name, code, section, and status icon |
| **Action Chips** | Colored selection chips: Cancel (red), Reschedule (blue), Extra Class (green), Swap Room (purple) |
| **Slot Selector** | Radio-style tiles showing existing recurring slots (Day • Time • Location) |
| **Date Pickers** | "Affected Date" for slot-based actions, "New Date" for reschedule/extra |
| **Time Pickers** | Start/End pickers for new time slots |
| **Input Fields** | Location and Reason text inputs |

#### Patch Actions

| Action | Use Case | Required Fields |
|--------|----------|-----------------|
| **Cancel** 🔴 | Class cancelled for a specific date | Slot → Affected Date → Reason |
| **Reschedule** 🔵 | Move class to different date/time | Slot → Affected Date → New Date → New Time → (Location) → Reason |
| **Extra Class** 🟢 | Add additional class not in schedule | Date → Time → Location → Reason |
| **Swap Room** 🟣 | Change location only, same time | Slot → Affected Date → New Location → Reason |

#### Semantic Distinction

- **Cancel / Reschedule / Swap**: Target an **existing recurring slot** from the base schedule. User must select which slot and which date occurrence is affected.
- **Extra Class**: Creates a **new slot** not in the base schedule. No slot selection needed.

### CR Audit Trail

*Read-only timeline of all schedule modifications issued by the CR.*

**Route:** `/cr/audit`

| UI Element | Description |
|------------|-------------|
| **Course Selector** | Pill-style dropdown to filter by course |
| **Date Strip** | Scrollable dates (2-week lookahead) |
| **Timeline** | ScheduleCard widgets | Tap Course $\to$ `/subject-detail`, Mess $\to$ `/mess`, Personal $\to$ `/calendar` |
| **Details Sheet** | Tap any patch to view: Event, Status, Time | Linked from timeline |

### Cryptographic Signing

*Ensures authenticity of CR updates.*

| Component | Description |
|-----------|-------------|
| **Algorithm** | Ed25519 (fast, compact signatures) |
| **Private Key** | Stored in device Keychain/Keystore (never leaves device) |
| **Public Key** | Uploaded to `signing_keys` table on first CR action |
| **Verification** | Server verifies signature before accepting patch |

#### Key Management

| Action | Trigger | Effect |
|--------|---------|--------|
| **Generate** | First CR action | Create key pair, upload public key |
| **Rotate** | User-initiated (Settings) | Old key marked `revoked_at`, new pair generated |
| **Revoke** | User loses CR status | Key marked as revoked, patches rejected |

### CR Capabilities Summary

| Feature | Route | Description |
|---------|-------|-------------|
| **Schedule Patcher** | `/cr/patch` | Cancel, Reschedule, Add Extra Classes, Swap Room |
| **Audit Trail** | `/cr/audit` | View history of all CR actions |
| **CR Request** | (integrated) | Request authority for unauthorized courses |
| **Cryptographic Signing** | (automatic) | Ed25519 signatures for authenticity |

---

## 8. Privacy & Customization

* **Private Mode:** Disables all cloud syncing; data stays on device only.
* **Guest Mode:** Use app without account; migrate data on signup.
* **Google Drive Backup:** Sync local JSON files to personal Google Drive.
*   **Data Export:** Export all data as JSON backup file.
*   **Data Import:** Restore data from JSON backup (merges with existing data).
*   **Nuke Cloud Data:** Permanently delete all cloud data.
* **Theme Toggle:** Dark/Light mode support.

---

## 9. Data Architecture

### Storage Layers

| Layer | Storage | Purpose |
|-------|---------|---------|
| **Shared Data** | Supabase PostgreSQL | Universities, courses, schedules, CR patches |
| **Personal Data** | Local JSON files | Attendance, overrides, events, settings |
| **File Storage** | Google Drive / Supabase Storage | Profile images, PDFs, notes |

### Sync Strategy
* Shared data syncs from Supabase → Local on app launch and via realtime.
* Personal data syncs Local → Google Drive when toggle enabled.
* Private Mode disables all outbound sync.

---

## 10. Student Collaboration

*Crowd-sourced features to help students share real-time class status.*

### Verification Votes

*Students can vote on whether class is happening, triggering notifications when threshold is reached.*

#### How It Works

| Step | Description |
|------|-------------|
| 1. **Trigger** | Student opens a live/upcoming class card |
| 2. **Vote** | Tap "Prof is here ✓" or "Prof missing ✗" |
| 3. **Display** | Card shows vote count (e.g., "3 voted missing") |
| 4. **Threshold** | When 5+ students vote same status → triggers notification |
| 5. **Notify** | Push sent to all enrolled: "5 students report Prof missing" |

#### Vote Button States

| State | Button Display | Condition |
|-------|----------------|-----------|
| **Not Voted** | "Vote Status" | No vote from this user |
| **Voted Present** | "✓ You voted Present" (green) | User voted prof is here |
| **Voted Missing** | "✗ You voted Missing" (orange) | User voted prof missing |
| **Threshold Reached** | "5 confirmed missing" (locked) | Voting closed |

#### Notification Threshold

| Section Size | Threshold | Rationale |
|--------------|-----------|----------|
| < 20 students | 3 votes | Small class, few votes needed |
| 20-50 students | 5 votes | Medium class |
| > 50 students | 10 votes | Large class, avoid false positives |

#### Data Model

| Field | Type | Description |
|-------|------|-------------|
| `rule_id` | UUID | Schedule slot being voted on |
| `section` | String | Voter's section |
| `user_id` | UUID | Voter |
| `date` | Date | Specific date |
| `status` | Enum | `PROF_PRESENT`, `PROF_MISSING` |
| `voted_at` | Timestamp | When vote was cast |

#### Integration with Attendance

| Scenario | Effect |
|----------|--------|
| Threshold reached for "Prof Missing" | All enrolled students get `ABSENT` marked with `source = "CROWD_VERIFIED"` |
| Class confirmed by votes | Students at location get attendance boost in confidence score |