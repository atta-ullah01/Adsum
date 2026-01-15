# Application Pages & UI Specifications

### 🚀 Phase 1: Onboarding & Injection (Cold Start)
_These screens run once to populate the initial "Base Layer" (L1)._

### 1. Splash & Server Handshake
- **Route**: `/` (Initial Route)
- **Flow**:
  - **Entry**: App Launch.
  - **Next**: Tap "Get Started" $\rightarrow$ **Auth (`/auth`)**.
- **UI Elements**: Branding (`/adsum:`), Hero Image, "Get Started" Button.
- **Logic**: Silently pings CR Server `/health` to check connectivity.

### 2. Auth & University Config
- **Route**: `/auth`
- **Flow**:
  - **Entry**: From Splash.
  - **Inputs**:
    - **University**: Searchable Dropdown / Typeahead.
    - **Hostel**: dependent on University.
    - **Section**: Text Input (e.g., "A", "B").
    - **Name**: Text Input (if not from Google).
  - **Back**: Returns to Splash.
  - **Next**: Success $\rightarrow$ **Course Injection (`/ocr`)** (Passing Section context).
- **UI Elements**: 
  - **Vertical Form Stack**:
    1. **University**: Searchable Dropdown (e.g., "IIT Delhi").
    2. **Hostel**: Dropdown (Loaded based on Uni).
    3. **Section**: Text Input (e.g., "A", "B").
    4. **Name**: Text Input (Optional - defaults to Google Name).
  - **Two-Card Actions** (Bottom):
    - **Student**: Sign in with Google (University Account).
    - **Guest**: Local Mode.
- **Data Action**: On signup, creates User and Session. Validates University $\rightarrow$ Hostel linkage.

### 3. Wizard Step 1: Course Injection
- **Route**: `/ocr`
- **Flow**:
  - **Entry**: From Auth.
  - **Actions**:
    - "Scan" $\rightarrow$ Process OCR $\rightarrow$ **My Courses (`/courses`)**.
    - "Manual Entry" $\rightarrow$ **My Courses (`/courses`)**.
    - "Create Custom Course" $\rightarrow$ **Create Custom (`/create-custom`)**.
- **UI Elements**: Camera Preview, "Scan Slip" button, Fallback links.

### 4. Create Custom Course
- **Route**: `/create-custom`
- **Flow**:
  - **Entry**: From Course Injection or Course Search.
  - **Actions**:
    - "Create" $\rightarrow$ Updates DB $\rightarrow$ Pop back to previous screen.
    - "Back" $\rightarrow$ Cancel.
- **UI Elements**: Inputs for Name, Code, Instructor, Time (Start/End), Days (M-S), Location, Color.

### 5. My Courses (Verification & Management)
- **Route**: `/courses`
- **Flow**:
  - **Entry**: From Onboarding (`/ocr`) OR Settings (`/settings`).
  - **Actions**:
    - Tap Course $\rightarrow$ Edit/Delete.
    - Search $\rightarrow$ Add Global/Custom.
    - "Confirm" (Onboarding) $\rightarrow$ **Sensor Hub**.
    - "Back" (Settings) $\rightarrow$ **Settings**.
- **UI Elements**: 
  - List of enrolled courses.
  - **Edit/Add Modal**:
    - **Basic**: Name, Code, Instructor.
    - **Schedule Builder** (List of Slots):
      - Display: "Mon 10:00 - 11:00 @ Room 305".
      - Action: "Add Slot" $\rightarrow$ Modal:
        - Day (Mon-Sun).
        - Start/End Time.
        - Location Name.
        - **Bindings**: "Bind GPS", "Bind Wi-Fi" (Per-slot, stored in `schedule_bindings.json`).
    - **Configuration**:
      - **Section**: Input.
      - **Target Attendance**: Slider/Input.

### 6. Wizard Step 3: Sensor Hub
- **Route**: `/sensors`
- **Flow**:
  - **Entry**: From My Courses.
  - **Actions**:
    - Toggle Permissions (Geofence, Motion, Battery).
    - "Finish" $\rightarrow$ **Main Dashboard (`/dashboard`)**.
- **UI Elements**: Permission Cards with Toggles, "Finish" Rocket Card.
---

### 🏠 Phase 2: The Core Navigation
_The daily driver screens._
6. **Main Dashboard:** The "Action" View.
    - **Header:** Personalized Greeting + Avatar.
    - **Top (Priority Zone):** 
        - **Priority Alert Carousel:** Swipeable "Glass Cards" for critical updates (Exams, Urgent Broadcasts, Conflicts).
        - **Emergency Pinner:** Red/Orange gradient cards for events starting < 48 hours.
    - **Body (Timeline):** Vertical sliding list of `ScheduleCard` widgets.
        - **Left Strip:** Time + Source Indication Color.
        - **Right Card:** Event Details + Status.
    - **Bottom:** Unified Command Button (Floating "Menu" pill).
    - **Interactions:**
        - **Live Pulse:** If a class is live, the card shows a pulsing **"Live • Tap to Verify"** button.
        - **Diagnostics Sheet:** Tapping "Pulse" opens a half-sheet showing GPS/WiFi/Activity confidence scores.

7. **Action Center:** The "Inbox" View.
    - **Purpose:** Unified hub for all pending actions (conflicts, verifications, schedule changes, assignments, attendance risks).
    - **Route:** `/action-center`
    - **Header:** "X Pending Items" (Dynamic Badge).
    - **Tabs:**
        - **Pending:** Items requiring user action.
            - *CONFLICT:* **[Accept Update]** **[Keep Mine]**
            - *VERIFY:* **[Yes, Present]** **[No, Absent]**
            - *SCHEDULE_CHANGE:* **[Acknowledge]**
            - *ASSIGNMENT_DUE:* **[Mark Done]** **[Snooze]**
            - *ATTENDANCE_RISK:* **[Details]**
        - **History:** Log of resolved/acknowledged items.
            - *Examples:* "Kept Gym over Math • Oct 21", "Verified present for CS101 • Oct 20"
    - **Item Types:** `CONFLICT`, `VERIFY`, `SCHEDULE_CHANGE`, `ASSIGNMENT_DUE`, `ATTENDANCE_RISK`

8. **Global FAB Menu (Command Center):** 
    - **Trigger:** Floating "Menu" button on Dashboard.
    - **Design:** Expansion sheet with two sections.
    - **Navigation Grid (4 items):** 
        - **Academics**: Course stats and attendance.
        - **Actions**: Pending items and decisions (Action Center).
        - **Calendar**: Academic calendar.
        - **Mess**: Dining menu viewer.
    - **Quick Actions (3 items):**
        - **Add Course**: Enroll/Create flow → `/manage-courses`
        - **Add Event**: Create personal reminder → `/calendar`
        - **Settings**: App preferences & profile → `/settings`

9. **Global Search:** Search bar for Courses, Professors, or specific assignments.

---
### ⚔️ Phase 3: The Sync & Conflict Manager (Crucial)

> **Note:** The original "Notification Center" has been consolidated into the **Action Center** (Page 7) for a unified inbox experience.

11. **Action Center** *(See Page 7 for full spec)*
    - Handles all pending items: conflicts, verifications, schedule changes, assignments, attendance risks.
    - **Social features** (Clarification Threads, mentions) deferred to future release.
    - **Attendance Verification**:
        - _Trigger:_ When class ends and Confidence Score was "Medium" (Yellow).
        - _Action:_ `VERIFY` item appears in Action Center with "Yes, Present" / "No, Absent" buttons.

12. **Conflict Resolution Modal:** 
    - **Trigger:** Inline from Action Center when resolving a `CONFLICT` item, OR proactively when schedule sync detects clash.
    - **UI:** "⚠️ Clashes with Gym" warning with split comparison view.
    - **File:** `conflict_resolution_modal.dart`

---

### 📍 Phase 4: Attendance & Tracking

_Granular control per subject._
13. **Academics:** (Course List & Aggregated Stats)
    *   **Smart Summary Card:** A dynamic top banner.
        *   green *Safe:* "You are on track!" + Total Safe Bunks metric.
        *   orange *Risk:* "Attention Needed" + Count of subjects < 75%.
    *   **Course Feed:** List of premium "Stats Tiles" (Dynamic height, ~140px).
        *   **Layout:** Bento-style card with a clean "Stats Row" (Big % + Safe Bunks text).
        *   **Typography:** Large bold percentage (32px) for impact.
        *   **Progress:** Sleek "Linear Progress Bar" (Dark pill on light track) at the bottom.
        *   **Status:** Displays "Safe to Bunk" count or "Recovery Needed" prominently.
    *   **Actions:** FAB (+) opens "Manage Courses" (Standalone Mode) to add/import subjects.
14. **Subject Detail View (Phase 4d):**
    *   **Aesthetic:** "Pastel SaaS" style with high border-radius (30px) and soft colors.
    *   **Navigation:** Minimalist top tab bar with a sliding underline indicator. Fully swipable pages.
    *   **Stats Tab (Bento Grid):**
        *   **Primary Card:** Large Pastel Green card for "Attendance %" (Top Left).
        *   **Secondary Card:** Pastel Orange card for "Safe Bunks" (Top Right).
        *   **Tertiary Cards:** Pastel Blue/Purple for "Total Classes" and "Attended".
        *   **History Strip:** A visual horizontal list of the last 7 days (Check/Cross icons) replacing simple text.
    *   **Syllabus Tab:**
        *   **Overview:** Clean linear progress bar with simple text stats ("X/Y Topics") - No complex gradients.
        *   **Modules:** Collapsible Accordion lists on a soft grey background.
        *   **Action:** "Edit/Import Syllabus" button (leads to Page 37).
    *   **Work Tab (Renamed from Assignments):**
        *   **Heap:** List of pending assignments, quizzes, and exams.
        *   **Action:** Tap item to open Work Detail Page (Page 37).
    *   **Manage Tab (Renamed from Settings):**
        *   **Course Details:** 
            *   *Global Courses:* Read-only metadata (Code, Prof) + Tag "University Catalog".
            *   *Custom Courses:* Editable fields (Name, Code, Prof).
        *   **Schedule Management:**
            *   *Global Courses:* View-only slot list (from `global_schedules`).
            *   *Custom Courses:* Editable slot list (add/remove/edit via `custom_schedules`).
        *   **Slot Bindings (Per-slot, user-specific via `schedule_bindings`):**
            *   Each slot can have GPS and WiFi bindings.
            *   *Global Courses:* User bindings override shared defaults.
            *   *Custom Courses:* User sets bindings directly.
        *   **Preferences:** Target Attendance Slider & Color Theme (Available for both).
        *   **Actions:** "Unenroll" (Global) or "Delete Course" (Custom).
15. **History Log:** Granular view of past attendance.
    - **Visuals:** Custom Calendar Grid with color-coded status indicators:
        - 🟢 (Solid Green): Present (Auto-verified).
        - 🟢 (Hollow Green): Present (Manual Override).
        - 🔴 (Red): Absent.
        - 🟡 (Yellow): Pending Confirmation.
    - **Day Details:** Selected day shows specific metadata (e.g., "Verified by WiFi") below the calendar.
    - **Action:** "Request Correction" button available for Absent/Pending entries.
16. **Geofence Debugger:** Diagnostic tool for missed attendance.
    - **Radar Visualizer:** Animated "Radar Scan" showing User's position relative to the Class Polygon (Square).
    - **Live Scoreboard:** Real-time metrics grid displaying:
        - GPS Accuracy (e.g., "4.2m").
        - Wi-Fi Signal Strength (e.g., "-58 dBm").
        - Total Confidence Score (%).
    - **Action:** "Calibrate Wi-Fi" button to capture the current BSSID as the canonical signature.

---

### 📚 Phase 5: Academics & Assignments
_The "Shared Brain" of the class._
17. **Assignment Heap:** List of tasks sorted by deadline (closest deadline = highest priority).
18. **Assignment Detail:** Full description + Attachments.
19. **Clarification Thread:** Nested comments section under an assignment (synced with CR/Class).
20. **SHEET: Create/Edit Assignment:** Form with "Type" (Project/HW) and "Deadline."
21. **Exam Command Center:** Read-only list of "Super Events" (Exams) that block out all other classes.

---
### 🍛 Phase 6: Mess & Dining
_Food tracking._
22. **Mess Menu View:** Interactive Card stack (B/L/Snacks/D) with Time Status. Functional Hostel Switcher & Date Picker.
23. **Menu Editor:** Weekly Tab View (Mon-Sun). Supports editing Food Items & Timings.
24. **Menu OCR:** Integrated "Auto-Scan" action within the Editor.

---
### 🗓️ Phase 7: Holiday Management
_Managing the "Day Order" and Exceptions._
25. **Academic Calendar:** "Split View" UI.
    - **Top (Overview):** Monthly Grid with color-coded dot indicators (Pink=Holiday, Blue=Swap, Yellow=Exam, Purple=Personal).
    - **Bottom (Agenda):** Vertical list of Premium Cards for the selected date.
    - **Actions:** 
      - Tap Date $\rightarrow$ Update Agenda.
      - "Add Event" (FAB) $\rightarrow$ Create personal reminder.
26. **Holiday Injection Preview:** Split screen to verify a parsed PDF of the "Holiday List."
27. **Day Order Manager (Sheet):** 
    - **Trigger**: Tap any event/day in Agenda View.
    - **UI**: Modal Sheet to toggle "Active" status or override "Day Order" (e.g., "Follows Monday"). 
    - **Logic**: Tracks source (Admin/CR/User).

---
### 👑 Phase 10: CR Authority Suite

_Visible ONLY if user has approved CR requests. Accessed via the **Quick Actions** sheet (FAB) on the Main Dashboard._

28. **Schedule Patcher:**
    - **Route**: `/cr/patch`
    - **UI**: Pastel SaaS-style with horizontal course selector and action cards.
    - **Flows by Action**:
        - **Cancel**: Course → Action → Slot → Affected Date → Reason → Submit
        - **Reschedule**: Course → Action → Slot → Affected Date → New Date/Time → (Location) → Reason → Submit
        - **Extra Class**: Course → Action → New Date/Time → Location → Reason → Submit
        - **Swap Room**: Course → Action → Slot → Affected Date → New Location → Reason → Submit
    - **CR Request**: Unauthorized courses show "Request Access" CTA.

29. **Audit Trail:**
    - **Route**: `/cr/audit`
    - **UI**: Dashboard-like timeline view.
    - **Components**:
        - **Date Strip**: Forward-only (2 weeks lookahead).
        - **Timeline**: `ScheduleCard` widgets with patch status badges (Cancelled, Rescheduled, Extra Class).
        - **Details Sheet**: Tap any patched item to view full details (Event, Status, Time, Reason, Issued By, Issued At).
    - **Note**: Read-only view for accountability.

---
### ⚙️ Phase 9: Settings & Data
_Privacy and maintenance._
32. **App Settings:**
    - **Actions**:
      - "Edit Profile" $\rightarrow$ Update Name, University, Hostel, Default Section.

      - Toggles: Theme, Notification defaults.
33. **Privacy Vault:**
    - Toggle: "Private Mode" (Kill Sync).
    - Action: "Export Data (JSON)."
    - Action: "Import Data (JSON)" (Restore Backup).
    - Action: "Nuke Cloud Data."
	- CR Identity Manager: (Visible only to CR). "Rotate Signing Key" / "Backup Key" (Essential for the Cryptographic Signing feature).
34. **Offline Banner (State):** "No Internet. Saving changes locally." (Non-intrusive header).
35. **SHEET: Slot Details:** The detailed view when tapping any class on the schedule. Shows the "Layer Source" (Base/CR/User) and allows a manual "L3 Override."
36. **Syllabus Editor & Injector:**
    Mode A (Parser): "Scan Document" or "Upload PDF". Splits text into Unit > Topic structure.
    Mode B (Manual): Drag-and-drop interface to reorder Units. "Add Topic" button.
    Verification: User reviews the parsed hierarchy before saving it to the Course.

37. **Work Detail Page:**
    - **Header:** Title, Type Badge (Assignment/Quiz/Exam), Urgent Flag.
    - **Dynamic Content:**
        - Assignment: Due Date.
        - Quiz: Time Window + Duration.
        - Exam: Date + Venue/Seat Info.
    - **Body:** Instructions, Attachments list.
    - **Actions:** "Mark as Completed", "Ask Question" (Discussion).
