
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/services/sync_service.dart';
import 'package:adsum/data/sources/local/app_database.dart';
import 'package:adsum/data/sync/writers/enrollment_writer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAppDatabase extends Mock implements AppDatabase {}
class MockConnectivity extends Mock implements Connectivity {}
class MockEnrollmentWriter extends Mock implements EnrollmentWriter {}

// Fake OfflineQueueItem
class FakeOfflineQueueItem extends Fake implements OfflineQueueItem {

  FakeOfflineQueueItem({
    required this.id,
    required this.entityType,
    required this.payloadJson,
    this.retryCount = 0,
    this.nextRetryAt,
  });
  @override
  final int id;
  @override
  final String entityType;
  @override
  final String payloadJson;
  @override
  final int retryCount;
  @override
  final DateTime? nextRetryAt;
}

void main() {
  late MockAppDatabase mockDb;
  late MockConnectivity mockConnectivity;
  late MockEnrollmentWriter mockEnrollmentWriter;
  late ProviderContainer container;

  setUp(() {
    mockDb = MockAppDatabase();
    mockConnectivity = MockConnectivity();
    mockEnrollmentWriter = MockEnrollmentWriter();

    // Mock connectivity stream
    when(() => mockConnectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    container.dispose();
  });

  SyncService createService() {
    container = ProviderContainer(
      overrides: [
        enrollmentWriterProvider.overrideWithValue(mockEnrollmentWriter),
        // We cannot easily override syncServiceProvider because we want to inject mockConnectivity
        // So we will instantiate SyncService manually via a temporary provider
      ],
    );
     // Since Ref is required by SyncService, we use a provider to construct it properly
     // using the container's Ref logic.
     final startService = Provider((ref) => SyncService(mockDb, ref, connectivity: mockConnectivity));
     return container.read(startService);
  }

  group('SyncService', () {
    test('processQueue skips if offline', () async {
      // Arrange
      final service = createService();
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      await service.processQueue();

      // Assert
      verifyNever(() => mockDb.getPendingQueueItems());
    });

    test('processQueue processes ENROLLMENT item successfully', () async {
      // Arrange
      final service = createService();
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
      
      final item = FakeOfflineQueueItem(
        id: 1, 
        entityType: 'ENROLLMENT', 
        payloadJson: '{"enrollment_id": "e1"}'
      );
      
      when(() => mockDb.getPendingQueueItems()).thenAnswer((_) async => [item]);
      when(() => mockEnrollmentWriter.sync(any())).thenAnswer((_) async => {});
      when(() => mockDb.updateQueueItemStatus(any(), any())).thenAnswer((_) async {});

      // Act
      await service.processQueue();

      // Assert
      verify(() => mockEnrollmentWriter.sync({'enrollment_id': 'e1'})).called(1);
      verify(() => mockDb.updateQueueItemStatus(1, 'COMPLETED')).called(1);
    });

    test('processQueue handles error with retry', () async {
       // Arrange
      final service = createService();
      when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.mobile]);
      
      final item = FakeOfflineQueueItem(
        id: 2, 
        entityType: 'ENROLLMENT', 
        payloadJson: '{"enrollment_id": "e2"}'
      );
      
      when(() => mockDb.getPendingQueueItems()).thenAnswer((_) async => [item]);
      when(() => mockEnrollmentWriter.sync(any())).thenThrow(Exception('Sync failed'));
      when(() => mockDb.updateQueueItemStatus(any(), any(), retryCount: any(named: 'retryCount'), nextRetryAt: any(named: 'nextRetryAt'), errorMessage: any(named: 'errorMessage'))).thenAnswer((_) async {});

      // Act
      await service.processQueue();

      // Assert
      verify(() => mockDb.updateQueueItemStatus(
        2, 
        'PENDING', 
        retryCount: 1,
        nextRetryAt: any(named: 'nextRetryAt'),
        errorMessage: any(named: 'errorMessage')
      )).called(1);
    });
  });
}
