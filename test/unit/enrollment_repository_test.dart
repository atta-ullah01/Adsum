
import 'package:adsum/data/repositories/enrollment_repository.dart';
import 'package:adsum/data/sources/local/json_file_service.dart';
import 'package:adsum/domain/models/enrollment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock JsonFileService
class MockJsonFileService extends Mock implements JsonFileService {
  Map<String, dynamic> data = {'enrollments': []};

  @override
  Future<Map<String, dynamic>> readJson(String fileName) async {
    return data;
  }
  
  @override
  Future<List<dynamic>?> readJsonArray(String fileName) async {
     return data['enrollments'] as List<dynamic>?;
  }

  @override
  Future<void> writeJson(String fileName, dynamic newData, {bool backup = true}) async {
    data = newData as Map<String, dynamic>;
  }

  @override
  Future<void> appendToJsonArray(String fileName, dynamic item) async {
    final list = data['enrollments'] as List<dynamic>? ?? [];
    list.add(item);
    data['enrollments'] = list;
  }
}

void main() {
  group('EnrollmentRepository', () {
    late EnrollmentRepository repository;
    late MockJsonFileService mockFileService;

    setUp(() {
      mockFileService = MockJsonFileService();
      repository = EnrollmentRepository(mockFileService);
    });

    test('addEnrollment adds a new enrollment successfully', () async {
      final result = await repository.addEnrollment(
        courseCode: 'CS101',
      );

      expect(result, isNotNull);
      expect(result!.courseCode, 'CS101');
      expect(result.section, 'A');
      
      final enrollments = await repository.getEnrollments();
      expect(enrollments.length, 1);
    });

    test('addEnrollment returns null for DUPLICATE course and section', () async {
      // 1. Add first
      await repository.addEnrollment(courseCode: 'CS101');
      
      // 2. Add same again
      final result = await repository.addEnrollment(courseCode: 'CS101');
      
      // Expect null (Duplicate)
      expect(result, isNull);
      
      // Verify list size remains 1
      final enrollments = await repository.getEnrollments();
      expect(enrollments.length, 1);
    });

    test('addEnrollment allows same course with DIFFERENT section', () async {
      // 1. Add Section A
      await repository.addEnrollment(courseCode: 'CS101');
      
      // 2. Add Section B
      final result = await repository.addEnrollment(courseCode: 'CS101', section: 'B');
      
      expect(result, isNotNull);
      expect(result!.section, 'B');
      
      final enrollments = await repository.getEnrollments();
      expect(enrollments.length, 2);
    });
  });
}
