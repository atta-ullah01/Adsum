# Mock Data Test Fixtures

This directory contains organized JSON fixture files for testing data integration in the main dashboard and other features.

## File Structure

```
test/fixtures/mock_data/
├── README.md              # This file
├── user.json              # User profile with settings
├── enrollments.json       # 7 course enrollments (5 catalog + 2 custom)
├── action_items.json      # 7 action items (5 pending + 2 resolved)
├── events.json            # 7 calendar events (personal, exam, holiday)
├── attendance.json        # 12 attendance logs (various states)
├── custom_schedules.json  # 5 custom course slots
├── schedule_bindings.json # 3 GPS/WiFi bindings
└── menu_cache.json        # 28 mess menu entries (full week)
```

## Data Coverage

### Enrollments (`enrollments.json`)
| ID | Course | Type | Attendance | Status |
|----|--------|------|------------|--------|
| `enroll_dsa_001` | COL106 - DSA | Catalog | 90% | ✅ Safe to bunk |
| `enroll_ml_002` | COL774 - ML | Catalog | 73% | ⚠️ At risk |
| `enroll_os_003` | COL331 - OS | Catalog | 66% | ❌ Critical |
| `enroll_dbms_004` | COL362 - DBMS | Catalog | 100% | ✅ Perfect |
| `enroll_cn_005` | COL334 - CN | Catalog | 100% | 🆕 Just started |
| `enroll_gym_006` | GYM001 - Gym | Custom | 80% | ✅ Good |
| `enroll_music_007` | MUS101 - Guitar | Custom | 100% | ✅ Perfect |

### Action Items (`action_items.json`)
- `CONFLICT`: Schedule clash (ML vs Gym)
- `VERIFY`: Medium confidence attendance check
- `SCHEDULE_CHANGE`: Class cancellation
- `ASSIGNMENT_DUE`: Upcoming deadline
- `ATTENDANCE_RISK`: Below target warning
- 2 resolved items for history tab

### Events (`events.json`)
- Personal events (today, tomorrow, past)
- Exam (upcoming DSA mid-sem)
- Holiday (Republic Day)
- Assignment due marker

### Attendance (`attendance.json`)
- PRESENT: Auto-confirmed (geofence, WiFi)
- PRESENT: Manual override
- ABSENT: Marked manually
- PENDING: Needs verification (medium confidence)

## Usage in Tests

```dart
import 'dart:convert';
import 'dart:io';

// Load fixture
final file = File('test/fixtures/mock_data/enrollments.json');
final json = jsonDecode(await file.readAsString()) as List;
final enrollments = json.map((e) => Enrollment.fromJson(e)).toList();
```

## Usage with MockDataSeeder

The `MockDataSeeder` service uses similar data but generates UUIDs dynamically.
These fixtures use stable IDs for predictable test assertions.
