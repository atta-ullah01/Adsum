import 'package:adsum/domain/models/mess.dart';
import 'package:adsum/presentation/pages/academics/assignments_page.dart';
import 'package:adsum/presentation/pages/academics/syllabus_editor_page.dart';
import 'package:adsum/presentation/pages/academics/work_detail_page.dart';
import 'package:adsum/presentation/pages/action_center/action_center_page.dart';
import 'package:adsum/presentation/pages/attendance/academics_page.dart';
import 'package:adsum/presentation/pages/attendance/geofence_debugger_page.dart';
import 'package:adsum/presentation/pages/attendance/history_log_page.dart';
import 'package:adsum/presentation/pages/auth/auth_page.dart';
import 'package:adsum/presentation/pages/calendar/academic_calendar_page.dart';
import 'package:adsum/presentation/pages/calendar/holiday_injection_page.dart';
import 'package:adsum/presentation/pages/courses/courses_page.dart';
import 'package:adsum/presentation/pages/courses/subject_detail_page.dart';
import 'package:adsum/presentation/pages/cr_authority/audit_trail_page.dart';
import 'package:adsum/presentation/pages/cr_authority/schedule_patcher_page.dart';
import 'package:adsum/presentation/pages/dashboard/dashboard_page.dart';
import 'package:adsum/presentation/pages/mess/menu_editor_page.dart';
import 'package:adsum/presentation/pages/mess/mess_menu_page.dart';
import 'package:adsum/presentation/pages/settings/edit_profile_page.dart';
import 'package:adsum/presentation/pages/settings/settings_page.dart';
import 'package:adsum/presentation/pages/splash/splash_page.dart';
import 'package:adsum/presentation/pages/wizard/wizard_ocr_page.dart';
import 'package:adsum/presentation/pages/wizard/wizard_sensors_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/ocr',
      builder: (context, state) => const WizardOcrPage(),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesPage(),
    ),
    GoRoute(
      path: '/manage-courses',
      builder: (context, state) => const CoursesPage(showWizard: false),
    ),
    GoRoute(
      path: '/sensors',
      builder: (context, state) => const WizardSensorsPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    // Slot details removed

    GoRoute(
      path: '/action-center',
      builder: (context, state) => const ActionCenterPage(),
    ),
    GoRoute(
      path: '/subject-detail',
      builder: (context, state) {
        final extras = state.extra! as Map<String, dynamic>;
        return SubjectDetailPage(
          courseTitle: extras['title'],
          courseCode: extras['code'],
          isCustomCourse: extras['isCustomCourse'] ?? false,
        );
      },
    ),
    GoRoute(
      path: '/history-log',
      builder: (context, state) {
         final extras = state.extra! as Map<String, dynamic>;
         return HistoryLogPage(courseTitle: extras['title']);
      },
    ),
    GoRoute(
      path: '/geofence-debugger',
      builder: (context, state) {
         final extras = state.extra! as Map<String, dynamic>;
         return GeofenceDebuggerPage(courseTitle: extras['title']);
      },
    ),
    // Phase 4: Academics
    GoRoute(
      path: '/academics',
      builder: (context, state) => const AcademicsPage(),
    ),
    
    // Phase 6: Mess
    GoRoute(
      path: '/mess',
      builder: (context, state) => const MessMenuPage(),
    ),
    GoRoute(
      path: '/mess/editor',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final day = extra['day'] as MessDayOfWeek? ?? MessDayOfWeek.mon;
        final hostelId = extra['hostelId'] as String? ?? '';
        return MenuEditorPage(day: day, hostelId: hostelId);
      },
    ),
    
    // Phase 7: Calendar
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const AcademicCalendarPage(),
    ),
    GoRoute(
      path: '/calendar/inject',
      builder: (context, state) => const HolidayInjectionPage(),
    ),
    
    // Phase 9: Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/settings/profile',
      builder: (context, state) => const EditProfilePage(),
    ),

    // Phase 5: Academics
    GoRoute(
      path: '/assignments',
      builder: (context, state) => const AssignmentsPage(),
    ),
    GoRoute(
      path: '/academics/detail',
      builder: (context, state) {
        final workItem = state.extra! as Map<String, dynamic>;
        return WorkDetailPage(workItem: workItem);
      },
    ),
    GoRoute(
      path: '/syllabus-editor',
      builder: (context, state) {
        final extras = state.extra! as Map<String, dynamic>;
        return SyllabusEditorPage(courseCode: extras['courseCode']);
      },
    ),
    // Phase 10: CR Authority
    GoRoute(
      path: '/cr/patch',
      builder: (context, state) => const SchedulePatcherPage(),
    ),
    GoRoute(
      path: '/cr/audit',
      builder: (context, state) => const AuditTrailPage(),
    ),
  ],
);
