
import 'dart:async';

import 'package:adsum/data/sources/remote/university_remote_source.dart';
import 'package:adsum/domain/models/university.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// Fake PostgrestFilterBuilder
class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {

  FakePostgrestFilterBuilder(this._response);
  final List<Map<String, dynamic>> _response;

  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) {
    return Future.value(_response).then(onValue, onError: onError);
  }
  
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) {
    return this;
  }

  // Allow other filter methods to chain by returning this
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String columns = '*']) {
     return this;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late UniversityRemoteSource source;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    source = UniversityRemoteSource(mockClient);
  });

  group('UniversityRemoteSource', () {
    test('fetchAll returns list of universities', () async {
      // Arrange
      final mockResponse = [
        {
          'id': 'uni_123',
          'name': 'Test Uni',
          'domain': 'test.edu',
          'logo_url': null,
          'semester_start': null,
          'semester_end': null
        }
      ];
      
      final fakeBuilder = FakePostgrestFilterBuilder(mockResponse);

      when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => fakeBuilder);

      // Act
      final result = await source.fetchAll();

      // Assert
      expect(result, isA<List<University>>());
      expect(result.length, 1);
      expect(result.first.id, 'uni_123');
      expect(result.first.name, 'Test Uni');
    });

    test('fetchHostels handles mapping correctly', () async {
      // Arrange
      final mockResponse = [
        {
          'hostel_id': 'h_1', // DB column
          'name': 'Hostel A',
          'university_id': 'uni_123'
        }
      ];
      
      final fakeBuilder = FakePostgrestFilterBuilder(mockResponse);

      when(() => mockClient.from('hostels')).thenAnswer((_) => mockQueryBuilder);
      // Ensure select returns builder, and eq returns builder
      // Since fakeBuilder returns itself on eq(), we just need to return it from select().
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => fakeBuilder);

      // Act
      final result = await source.fetchHostels('uni_123');

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'h_1'); // Mapped from hostel_id
      expect(result.first.name, 'Hostel A');
    });
  });
}
