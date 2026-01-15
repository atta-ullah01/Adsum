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
    *   **Full Name**: Optional, defaults to 'Student' for guest or derived from google account.

### Step 1: Course Entry Method
*   **Goal**: Determine how the user wants to populate their schedule.
*   **Personalized Header**: Greets the user by name (e.g., "Hi Attaullah 👋").
*   **Options**:
    1.  **Scan Slip (Disabled)**: (Not implemented).
    2.  **Manual Entry (Primary)**: Navigates to the Course Selection page.
*   **Layout**: Vertical stack for accessibility; Clean, text-focused design (No Hero Image).

### Step 2: Course Selection
*   **Goal**: Populate schedule with courses.
*   **Features**:
    *   **Manage Courses**: View active enrollments (split by Global/Custom).
    *   **Global Search**: Browse university catalog (mocked `SharedDataRepository`).
    *   **Enrollment Modal**: When selecting a catalog course, a modal appears with:
        - Section Dropdown (A-E)
        - Target Attendance % Slider (50-100%)
        - Card Color Picker
    *   **Custom Courses (Inline)**: "Create Custom Course" opens an inline form with:
        - Course Name, Code, Instructor
        - Section, Target Attendance %, Total Expected Classes
        - Class Slots (Day, Time, Location)
        - GPS & WiFi Bindings
        - Card Color Picker
    *   **Edit Mode**: Tapping an enrolled course expands an inline edit form.
    
#### Edit Mode Field Permissions

| Field | Global Course | Custom Course |
|-------|:-------------:|:-------------:|
| Course Name | ❌ Read-only | ✅ Editable |
| Course Code | ❌ Read-only | ✅ Editable |
| Instructor | ❌ Read-only | ✅ Editable |
| Section | ✅ Editable | ✅ Editable |
| Target Attendance % | ✅ Editable | ✅ Editable |
| Card Color | ✅ Editable | ✅ Editable |
| GPS Binding | ✅ Editable | ✅ Editable |
| WiFi Binding | ✅ Editable | ✅ Editable |
| Class Slots | ❌ From Schedule | ✅ Editable |
| Total Expected | ❌ Read-only (Calculated) | ✅ Editable |
| Start Date | ❌ Read-only (Semester Start) | ✅ Editable |

### Step 3: Sensor Hub
*   **Goal**: Grant necessary permissions for auto-attendance.
*   **Toggles** (Initially OFF):
    *   **Geofence**: Requests "Location Always".
    *   **Motion**: Requests "Activity Recognition".
    *   **Battery**: Opens "Battery Optimization" settings.
*   **Behavior**:
    *   Toggling ON triggers system permission prompt.
    *   Denied permission keeps toggle OFF and shows SnackBar.
    *   Settings are persisted to `user.json` on "Finish".
*   **Navigation**: "Finish" button completes onboarding and redirects to Dashboard.


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
| **Course (Room Swap)** | Title, Time, *New Location*, "Room Changed" Badge | **Subject Detail** | - |
| **Conflict** | Time, Both event titles side-by-side | **Resolution Modal** | - |
| **Mess** | Meal Type, Time, Hostel, Menu Items | **Mess Menu** | **Edit Note** |
| **Exam/Quiz** | Title, Time, Loc, Duration, "Blocking"| **Subject Detail** | - |
| **Personal** | Title, Time, Note | **Edit Event** | - |
| **Holiday** | Title, "No Classes" | - | - |

| Alert Type | Display Fields | Tap Action | Color |
|------------|----------------|------------|-------|
| **Assignment** | Title, Due Time, "Due Soon" | **Assignment Detail** | 🔵 Blue |
| **Attendance** | Course, Current %, Target %, "Risk" | **Subject Detail** | 🟠 Orange |
| **Exam** | Title, Starts In, "Super Event" | **Exam Command Center** | 🔴 Red |
| **Conflict** | Source A vs Source B, "Resolve" | **Conflict Modal** | 🟡 Yellow |

### Conflict Card Display
*When two events occupy the same time slot and require user resolution.*

**Layout:** Single merged card showing both events compactly:
```
┌─────────────────────────────────────────┐
│ ⚠️ CONFLICT • 9:00 - 10:00              │
│ ┌─────────────┐  ┌─────────────────────┐│
│ │ 📚 DSA      │  │ 🏋️ Gym Session      ││
│ │ LH-101      │  │ Personal            ││
│ └─────────────┘  └─────────────────────┘│
│           [Tap to Resolve]               │
└─────────────────────────────────────────┘
```

**Styling:**
- 🟠 Orange border
- Left mini-card: Official event (Admin/CR source)
- Right mini-card: User event (Personal)
- Single tap opens Resolution Modal

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

| Tab | Content | Data Source |
|-----|---------|-------------|
| **Pending** | Items requiring user action | `action_items.json` (status = PENDING) |
| **History** | Resolved/acknowledged items | `action_items.json` (status = RESOLVED) |

---

#### Action Item Types

##### 1. CONFLICT (Schedule Clash)
*Displayed when two calendar events overlap.*

| Element | Value |
|---------|-------|
| **Background** | Light purple (`0xFFF3E8FF`) |
| **Accent** | Deep purple (`0xFF6B46C1`) |
| **Icon** | Alert (⚠️) |
| **Title** | "Schedule Clash" |
| **Date** | Item creation date |

**Card Content:**
- **Split View** comparing two conflicting sources:
  - **Source A** (e.g., CR Update): Label, Title, Subtitle
  - **Source B** (e.g., Personal Event): Label, Title, Subtitle

**Actions:**
| Button | Effect |
|--------|--------|
| **Keep Mine** | Retain user's event, dismiss conflict |
| **Accept Update** | Accept the official/CR change |

**Payload Schema:**
```json
{
  "conflict_category": "CR_VS_PERSONAL",
  "sourceA": { "label": "CR Update", "title": "Math Lecture", "subtitle": "Moved to 2 PM" },
  "sourceB": { "label": "Your Event", "title": "Gym Session", "subtitle": "Personal Calendar" }
}
```

---

##### 2. VERIFY (Attendance Confirmation)
*Displayed after a class ends with uncertain presence detection.*

| Element | Value |
|---------|-------|
| **Background** | Light blue (`0xFFE0F2FE`) |
| **Accent** | Blue (`0xFF0284C7`) |
| **Icon** | Help Circle (❓) |
| **Title** | "Verify Attendance" |

**Card Content:**
- **Message**: "We detected you near [Location]. Were you present?"
- **Course**: The course name for context

**Actions:**
| Button | Effect |
|--------|--------|
| **Yes, Present** | Confirms attendance, updates `attendance.json` |
| **No, Absent** | Marks as absent |

**Payload Schema:**
```json
{
  "course": "Mobile App Design",
  "message": "We detected you near LH-102. Were you present?"
}
```

---

##### 3. SCHEDULE_CHANGE (CR Announcement)
*Displayed when a CR modifies or cancels a class.*

| Element | Value |
|---------|-------|
| **Background** | Light sky blue (`0xFFE0F7FA`) |
| **Accent** | Teal (`0xFF0891B2`) |
| **Icon** | Information Circle (ℹ️) |
| **Title** | "Schedule Update" |

**Card Content:**
- **Message**: The CR's note (e.g., "Prof. cancelled class due to emergency.")

**Actions:**
| Button | Effect |
|--------|--------|
| **Acknowledge** | Marks the announcement as seen |

**Payload Schema:**
```json
{
  "course": "Data Structures",
  "message": "Prof. Rahul cancelled class due to emergency meeting."
}
```

---

##### 4. ASSIGNMENT_DUE (Upcoming Deadline)
*Displayed when an assignment is due within 24-48 hours.*

| Element | Value |
|---------|-------|
| **Background** | Light amber (`0xFFFEF3C7`) |
| **Accent** | Amber (`0xFFD97706`) |
| **Icon** | Document Text (📝) |
| **Title** | Assignment title |

**Card Content:**
- **Course**: The parent course name
- **Work Title**: The assignment name (large, bold)
- **Due Text**: Countdown (e.g., "Due in 28 hours")

**Actions:**
| Button | Effect |
|--------|--------|
| **Mark Done** | Updates `work_states.json` to `status = SUBMITTED` |
| **Snooze** | Dismisses notification temporarily (item moves to history) |

**Payload Schema:**
```json
{
  "work": "Finance Dashboard",
  "course": "HCI",
  "due_text": "Due in 28 hours"
}
```

---

##### 5. ATTENDANCE_RISK (Low Attendance Warning)
*Displayed when a subject falls below the target attendance %.*

| Element | Value |
|---------|-------|
| **Background** | Light red/rose (`0xFFFFE4E6`) |
| **Accent** | Rose (`0xFFE11D48`) |
| **Icon** | Warning (⚠️) |
| **Title** | "Attendance Risk" |

**Card Content:**
- **Course**: The at-risk course name
- **Message**: Recovery guidance (e.g., "You need to attend next 3 classes to be safe.")
- **Current %**: The student's current attendance percentage

**Actions:**
| Button | Effect |
|--------|--------|
| **Details** | Navigates to Subject Detail (Stats Tab) for a full recovery plan |

**Payload Schema:**
```json
{
  "course": "Linear Algebra",
  "current_per": "72%",
  "message": "You need to attend next 3 classes to be safe."
}
```

---

#### Resolution Lifecycle
1.  User taps action button.
2.  `ActionCenterProvider.resolveItem()` is called.
3.  `ActionItemRepository.resolve()` updates `action_items.json`:
    - Sets `status = RESOLVED`
    - Sets `resolution` to the action taken
    - Sets `resolved_at` timestamp
4.  UI refreshes: item moves from **Pending** to **History** tab.

#### History Log
Audit trail of past decisions, displayed in the "History" tab:
- Shows resolved items with their action status (e.g., "ACKNOWLEDGED", "MARK_DONE")
- Sorted by resolution time (newest first)
- Persists across app restarts (stored in `action_items.json`)


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

## Work Detail Page
*Focused view for a single assignment, quiz, or exam.*

**Route:** `/academics/detail`

### Features
1.  **Dynamic Meta Header**:
    *   Visual prominence for Title and Due Date.
    *   Color-coded badges for Work Type (Assignment, Quiz, Exam) and Course.
    *   **Urgency Indicators**: "Due Tomorrow", "Urgent" tags.
2.  **Interactive Actions**:
    *   **Mark as Completed**: Updates status to `submitted`, moves item to "Completed" lists.
    *   **Context Menu**: "Hide from Calendar" to declutter views.
3.  **Discussion Board**:
    *   **Real-time Comments**: Chat-like interface for Q&A on specific assignments.
    *   **Ask a Question**: Post inquiries visible to classmates (and potentially CR/Prof).
4.  **Rich Details**:
    *   Description/Instructions text.
    *   Venue and Seat info (for Exams).
    *   Duration and Window info (for Quizzes).

---
## Academics Page
*The hub for tracking attendance, safe bunks, and overall academic health.*

**Route:** `/academics`

### Features
1.  **Header Navigation**:
    *   **Unified Assignments**: A list icon that opens the **Unified Assignments Page** containing work details for all courses in one place.
2.  **Smart Summary Card**:
    *   **"On Track" (Green):** Displays total safe bunks available across all courses.
    *   **"Attention Needed" (Orange):** Highlights count of courses falling below target attendance %.
3.  **Course Feed**:
    *   **Bento-style Stats Cards:** Displays current attendance %, safe bunks, and a visual progress bar for each course.
    *   **Status Indicators:** Color-coded (Green/Orange) based on whether the student is above or below their set target.
4.  **Quick Actions**:
    *   **Add Course (+):** Direct access to "Manage Courses" for enrolling in new subjects.

---
## Unified Assignments Page
*A centralized hub to view and manage work for **all** enrolled courses in one place.*

**Route:** `/assignments`

**Entry Point:** Accessed via the list icon on the **Academics Page**.

### Features
1.  **Consolidated List**: Aggregates assignments, quizzes, and exams from all subjects.
2.  **Tabbed View**:
    *   **Pending**: Upcoming tasks sorted by urgency (e.g., "Due Today", "Due Tomorrow").
    *   **Completed**: History of submitted or graded work.
3.  **Quick Actions**:
    *   **Add Task (+)**: Create a new assignment for any course directly from this hub.
    *   **Tap to Detail**: Opens the specific **Work Detail Page**.
4.  **Visual Queues**:
    *   **Color Strips**: Identifies the course (matches the course card color).
    *   **Urgency Badges**: "Urgent" flame icon for tasks due within 24h.

---

## Manage Courses Page
*Centralized hub for adding, editing, and deleting courses.*

**Route:** `/manage-courses`

> **Reference:** This feature is fully documented in **Step 2: Course Selection (Onboarding)**.
> It shares the exact same UI and capabilities (Edit Details, Schedule Builder, Slot Bindings) as the onboarding wizard.

**Entry Points:**
- **Onboarding:** via Wizard Step 2.
- **Academics Page:** via FAB (+) in Standalone Mode.
- **Settings:** via "Manage Courses" option.

---


## 3. Academic Calendar

**Route:** `/calendar`

*Full-month calendar view with event markers and agenda list.*

### UI Structure

| Section | Description |
|---------|-------------|
| **App Bar** | Title, Back button, "Import Holidays" button |
| **Month Navigation** | Prev/Next arrows, Month-Year label |
| **Weekday Headers** | Mon–Sun labels |
| **Calendar Grid** | Day cells with colored event markers (up to 3 dots) |
| **Agenda View** | Scrollable list of events for selected day |
| **FAB** | "Event" button to add new personal event |

---

### Event Types

| Type | Source | Marker Color | Card Background | Description |
|------|--------|--------------|-----------------|-------------|
| **Holiday** | Imported (`events.json`) | 🔴 Red | Pastel Pink | No classes (Diwali, Republic Day) |
| **Exam** | Official (`course_work`) | 🟡 Yellow | Pastel Yellow | End semester, mid-terms |
| **Quiz** | Official (`course_work`) | 🟡 Yellow | Pastel Yellow | Same-day quiz |
| **Assignment** | Official (`course_work`) | 🟠 Orange | Pastel Orange | Deadlines & Projects |
| **Day Swap** | Imported (`events.json`) | 🔵 Blue | Pastel Blue | "Follow Monday schedule on Saturday" |
| **Personal** | User (`events.json`) | 🟣 Purple | Pastel Purple | User-created events |

---

### Day Cell Rendering

Each calendar day cell shows:
- **Day number** (bold, centered)
- **Selection ring**: Black fill if selected, grey if today
- **Event markers**: Up to 3 colored dots below the number

```
┌─────────┐
│   15    │  ← Selected (black fill)
│   ●●    │  ← 2 events (red + blue dots)
└─────────┘
```

---

### Agenda View (Selected Day)

Displays all events for the selected date as cards:

| Element | Content |
|---------|---------|
| **Date Header** | "Tuesday, 15 January" |
| **Event Card** | Type badge, Title, Description, Date, Time |
| **Empty State** | Icon + "Nothing scheduled for today" |

---

### Event Card Examples by Type

#### 🔴 Holiday
```
┌──────────────────────────────────────┐
│ [HOLIDAY]                      🔔    │  ← Red badge, Pink background
├──────────────────────────────────────┤
│ Republic Day                         │  ← Title (large, bold)
│ National holiday - University closed │  ← Description (grey)
├──────────────────────────────────────┤
│ 📅 26 Jan    🕐 All Day              │  ← No time = All Day
└──────────────────────────────────────┘
```
**Source:** `events.json` (Imported)

---

#### 🔵 Day Swap
```
┌──────────────────────────────────────┐
│ [DAY SWAP]                     🔔    │  ← Blue badge, Blue background
├──────────────────────────────────────┤
│ Follow Monday Schedule               │  
│ Makeup classes for Jan 14 holiday    │  
├──────────────────────────────────────┤
│ 📅 18 Jan    🔄 MON                  │  ← Target day indicator
└──────────────────────────────────────┘
```
**Source:** `events.json` (Imported)  
**Effect:** Schedule Engine loads Monday's classes instead of Saturday's.

---

#### 🟣 Personal
```
┌──────────────────────────────────────┐
│ [PERSONAL]                     🔔    │  ← Purple badge, Purple BG
├──────────────────────────────────────┤
│ Gym Session                          │  
│ Leg Day                              │  
├──────────────────────────────────────┤
│ 📅 15 Jan    🕐 14:00 - 15:00        │
└──────────────────────────────────────┘
```
**Source:** `events.json` (User Created via AddEventPage)

---

#### 🟡 Exam
```
┌──────────────────────────────────────┐
│ [EXAM]                         🔔    │  ← Yellow badge, Yellow BG
├──────────────────────────────────────┤
│ DSA Mid-Semester                     │  
│ COL106 exam                          │  
├──────────────────────────────────────┤
│ 📅 20 Jan    🕐 09:00 - 11:00        │
└──────────────────────────────────────┘
```
**Source:** `course_work` (Derived - WorkType.exam)

---

#### 🟡 Quiz
```
┌──────────────────────────────────────┐
│ [QUIZ]                         🔔    │  ← Yellow badge, Yellow BG
├──────────────────────────────────────┤
│ DBMS Surprise Quiz                   │  
│ COL362 quiz                          │  
├──────────────────────────────────────┤
│ 📅 15 Jan    🕐 11:30                │
└──────────────────────────────────────┘
```
**Source:** `course_work` (Derived - WorkType.quiz)

---

#### 🟠 Assignment
```
┌──────────────────────────────────────┐
│ [ASSIGNMENT]                   🔔    │  ← Orange badge, Orange BG
├──────────────────────────────────────┤
│ OS Lab Report                        │  
│ COL331 assignment                    │  
├──────────────────────────────────────┤
│ 📅 17 Jan    🕐 Due 23:59            │  ← Due time
└──────────────────────────────────────┘
```
**Source:** `course_work` (Derived - WorkType.assignment)
└──────────────────────────────────────┘
```


### Add Event

**Entry Point:** FAB button ("+ Event")

Opens `AddEventPage` modal with:

| Field | Type | Required |
|-------|------|----------|
| Title | Text | ✅ |
| Date | Date Picker | ✅ (defaults to selected day) |
| Type | Dropdown (Personal, Holiday, Exam, etc.) | ✅ |
| Start Time | Time Picker | Optional |
| End Time | Time Picker | Optional |
| Description | Multi-line Text | Optional |

**On Save:**
1. Calls `CalendarService.addEvent()`
2. Persists to `events.json`
3. Invalidates `calendarEventsProvider`
4. Returns to calendar (UI refreshes)

---

### Import Holidays

**Entry Point:** Cloud upload icon in app bar → `/calendar/inject`

Allows bulk import of academic calendar events from:
- Official university PDFs
- Manual entry

*Note: OCR parsing planned for Phase 3.*

---

### Missing Features (Planned)

| Feature | Status | Priority |
|---------|--------|----------|
| **Edit Event** | ✅ Done | High |
| **Delete Event** | ✅ Done | High |
| **Recurring Events** | 🚧 TODO | Medium |
| **Event Notifications** | 🚧 TODO | Medium |
| **Sync with Google Calendar** | 🚧 TODO | Low |
| **Week View** | 🚧 TODO | Low |

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

* **Course Injection (Manual):** Wizard for quick course selection. (OCR Scanning disabled for cost optimization).
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
| **Day Swap** 🔵 | Makeup day: "Follow Monday schedule on Saturday" | Affected Date → Target Day (MON-SUN) → Reason |

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

* **No Profile Pictures:** User avatars display initials only (no image upload/storage).
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
| **File Storage** | Google Drive / Supabase Storage | PDFs, notes (Profile photos removed) |

### Sync Strategy
* Shared data syncs from Supabase → Local on app launch and via realtime.
* Personal data syncs Local → Google Drive when toggle enabled.
* Private Mode disables all outbound sync.

---

## 10. Live Presence Voting (Crowdsourcing)

*Ephemeral, real-time crowd-sourced presence indicator displayed directly on Live class cards.*

### Design Philosophy

| Principle | Description |
|-----------|-------------|
| **Ephemeral** | Votes exist only while a class is live. No historical storage. |
| **Live Display** | Vote count shown directly on the ScheduleCard (not a separate page). |
| **Simple** | Two buttons: "I'm Here ✓" / "Prof Missing ✗". One vote per user per slot. |
| **No Backend Threshold Logic** | Frontend aggregates counts via Supabase Realtime; no server-side triggers. |

---

### UI Integration (ScheduleCard)

When a class is **currently live** (`event.isCurrent == true`), the card shows a voting strip:

```
┌────────────────────────────────────────────────┐
│  📚 Data Structures • Lecture              ⚡ │
│  LH-101 • Prof. Sharma                         │
│                                                │
│  ┌──────────────────────────────────────────┐  │
│  │  👥 32 Verified Present                  │◄── Count Only
│  └──────────────────────────────────────────┘  │
└────────────────────────────────────────────────┘
```

---

### Simplified Presence Count

> **Design Decision**: Removed "Prof Present / Prof Missing" voting in favor of a simpler **presence count** that shows how many students have verified their attendance.

| Display | Meaning |
|---------|---------|
| **32 Verified** | 32 students marked themselves present via the Live Verification popup |

---

### Data Flow

1. User taps "Mark Present" → App upserts row to `presence_confirmations`.
2. Supabase Realtime broadcasts change to all subscribers.
3. All apps watching that `rule_id + date` update their live count.

---

### Supabase Table (Ephemeral)

> **No historical storage**: A scheduled job deletes all confirmations older than 24 hours.

| Column | Type | Description |
|--------|------|-------------|
| `confirmation_id` | UUID | PK |
| `rule_id` | UUID | FK → `global_schedules.rule_id` |
| `date` | Date | Today's date |
| `user_id` | UUID | Confirming user |
| `confirmed_at` | Timestamp | For TTL cleanup |

---

### Visibility Rules

| Condition | Presence Count Visible? |
|-----------|-------------------------|
| Class is **currently live** | ✅ Yes |
| Class is **upcoming/past/cancelled** | ❌ No |
| Non-academic events (Mess, Personal) | ❌ No |

---

### UI Design Notes

**Schedule Card Styling:**
- White background for all cards (no color fill).
- Black border (`2px`) for **Live** cards; subtle grey border for non-live cards.
- Presence count shown only on **Academic** cards, hidden for Mess/Personal events.

**Live Verification Popup:**
- 2x2 Grid layout with pastel-colored tiles and **black borders**.
- All text in tiles uses **black** color for readability.
- "Present" tile shows live count of verified students.
- GPS, WiFi, and Activity status displayed in separate tiles with success/loading indicators.
- Confidence score (%) displayed in header next to "Live Verification" title.
- "Mark Present" button triggers personal attendance confirmation.