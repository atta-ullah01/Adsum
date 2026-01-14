import 'package:flutter_test/flutter_test.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final helper = TestHelper();

  setUp(() async {
    await helper.setUp();
  });

  tearDown(() async {
    await helper.tearDown();
  });

  group('EnrollmentRepository', () {
    test('addEnrollment with global course code', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final enrollment = await repo.addEnrollment(
        courseCode: 'CS101',
        section: 'A',
        targetAttendance: 80.0,
        colorTheme: '#FF5733',
      );

      expect(enrollment.enrollmentId, isNotEmpty);
      expect(enrollment.courseCode, 'CS101');
      expect(enrollment.isCustom, false);
      expect(enrollment.section, 'A');
      expect(enrollment.targetAttendance, 80.0);
    });

    test('addEnrollment with custom course', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final customCourse = CustomCourse(
        code: 'ELEC01',
        name: 'Guitar Practice',
        instructor: 'Self',
      );

      final enrollment = await repo.addEnrollment(customCourse: customCourse);

      expect(enrollment.isCustom, true);
      expect(enrollment.customCourse!.name, 'Guitar Practice');
    });

    test('getEnrollments returns all enrollments', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      await repo.addEnrollment(courseCode: 'MATH101');
      await repo.addEnrollment(courseCode: 'PHYS101');
      await repo.addEnrollment(
        customCourse: CustomCourse(code: 'C1', name: 'Custom', instructor: 'Me'),
      );

      final enrollments = await repo.getEnrollments();
      expect(enrollments.length, 3);
    });

    test('getEnrollment by ID returns correct enrollment', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'ENG101');
      final fetched = await repo.getEnrollment(created.enrollmentId);

      expect(fetched, isNotNull);
      expect(fetched!.courseCode, 'ENG101');
    });

    test('getEnrollment returns null for non-existent ID', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);
      final fetched = await repo.getEnrollment('non_existent_id');
      expect(fetched, isNull);
    });

    test('updateEnrollment modifies existing enrollment', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(
        courseCode: 'BIO101',
        targetAttendance: 75.0,
      );

      final updated = created.copyWith(targetAttendance: 85.0);
      await repo.updateEnrollment(updated);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.targetAttendance, 85.0);
    });

    test('markAttended increments stats correctly', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'CHEM101');
      await repo.markAttended(created.enrollmentId);
      await repo.markAttended(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.stats.attended, 2);
      expect(fetched.stats.totalClasses, 2);
    });

    test('markAbsent increments total only', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'HIST101');
      await repo.markAttended(created.enrollmentId);
      await repo.markAbsent(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched!.stats.attended, 1);
      expect(fetched.stats.totalClasses, 2);
    });

    test('deleteEnrollment removes enrollment', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      final created = await repo.addEnrollment(courseCode: 'DEL101');
      await repo.deleteEnrollment(created.enrollmentId);

      final fetched = await repo.getEnrollment(created.enrollmentId);
      expect(fetched, isNull);
    });

    test('getCount returns correct count', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);

      await repo.addEnrollment(courseCode: 'A');
      await repo.addEnrollment(courseCode: 'B');

      expect(await repo.getCount(), 2);
    });

    test('update non-existent enrollment does nothing', () async {
      final repo = helper.container.read(enrollmentRepositoryProvider);
      
      final ghostEnrollment = Enrollment(
        enrollmentId: 'ghost', 
        courseCode: 'GHOST', 
        stats: const EnrollmentStats()
      );
      
      // Should not throw and not add the item
      await repo.updateEnrollment(ghostEnrollment);
      
      final fetched = await repo.getEnrollment('ghost');
      expect(fetched, isNull);
    });
  });
}
