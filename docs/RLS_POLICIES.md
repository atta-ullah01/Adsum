
# Row Level Security (RLS) Policies

This document checks and defines the security policies for the Adsum Supabase backend.
All access is denied by default (`ENABLE RLS`).

## Policy Overview

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `users` | Own record | Own record | Own record | Own record |
| `universities` | `is_active = true` | Admin only | Admin only | Admin only |
| `hostels` | `university_id` in Active | Admin only | Admin only | Admin only |
| `courses` | `university_id` in Active | Admin only | Admin only | Admin only |
| `user_enrollments` | Own record | Own record | Own record | Own record |
| `global_schedules` | Enrolled course | Admin only | Admin only | Admin only |
| `schedule_modifications` | Enrolled course | CR (Verified) | CR | Never |
| `attendance_log` | Own record | Own record | Own record | Never |
| `course_work` | Enrolled course | CR (Verified) | Never | Never |
| `presence_confirmations` | All (Current Slot) | Own record | Never | Never |

## Detailed Policies

### 1. Users
- **Table**: `users`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `select_own_profile`: `auth.uid() = user_id`
    - `insert_own_profile`: `auth.uid() = user_id`
    - `update_own_profile`: `auth.uid() = user_id`

### 2. Universities & Hostels
- **Table**: `universities`, `hostels`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `public_read`: `true` (Or `is_active = true`)
    - `admin_write`: `auth.jwt() ->> 'role' = 'service_role'` (or specific admin claim)

### 3. Enrollments
- **Table**: `user_enrollments`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `select_own`: `auth.uid() = user_id`
    - `insert_own`: `auth.uid() = user_id`
    - `update_own`: `auth.uid() = user_id`
    - `delete_own`: `auth.uid() = user_id`

### 4. Shared Academic Data (Courses, Global Schedules)
- **Table**: `courses`, `global_schedules`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `read_all_in_uni`: `exists (select 1 from universities where id = university_id and is_active = true)`
    - **Optimization**: Allow public read for catalog browsing?
        - Yes: `true`

### 5. Sensitive Shared Data (Modifications, Work)
- **Table**: `schedule_modifications`, `course_work`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `read_enrolled`:
      ```sql
      course_code IN (
          SELECT course_code FROM user_enrollments WHERE user_id = auth.uid()
      )
      ```
    - `insert_cr`:
      ```sql
      EXISTS (
        SELECT 1 FROM user_enrollments
        WHERE user_id = auth.uid() 
        AND course_code = new.course_code
        AND role = 'CR'
      )
      ```

### 6. Logs & Crowdsourcing
- **Table**: `attendance_log`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `own_rows`: `auth.uid() = user_id` (using standard `user_id` column match)

- **Table**: `presence_confirmations`
- **Enable RLS**: `TRUE`
- **Policies**:
    - `public_read`: `true`
    - `insert_own`: `auth.uid() = user_id`
