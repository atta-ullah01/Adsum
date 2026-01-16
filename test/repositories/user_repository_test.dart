import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('UserRepository', () {
    test('saveUser and getUser work correctly', () async {
      final repo = helper.container.read(userRepositoryProvider);

      const user = UserProfile(
        userId: 'user_001',
        fullName: 'Alice Student',
        email: 'alice@university.edu',
        universityId: 'UNI001',
        defaultSection: 'B',
        settings: UserSettings(themeMode: 'DARK', notificationsEnabled: false),
      );

      await repo.saveUser(user);
      final fetched = await repo.getUser();

      expect(fetched, isNotNull);
      expect(fetched!.userId, 'user_001');
      expect(fetched.fullName, 'Alice Student');
      expect(fetched.defaultSection, 'B');
      expect(fetched.settings.themeMode, 'DARK');
      expect(fetched.settings.notificationsEnabled, false);
    });

    test('updateSettings modifies nested settings object', () async {
      final repo = helper.container.read(userRepositoryProvider);

      await repo.saveUser(const UserProfile(
        userId: 'user_002',
        fullName: 'Bob',
        email: 'bob@example.com',
      ));

      await repo.updateSettings(const UserSettings(
        notificationsEnabled: false,
        googleSyncEnabled: false,
      ));

      final fetched = await repo.getUser();
      expect(fetched!.settings.notificationsEnabled, false);
      expect(fetched.settings.googleSyncEnabled, false);
    });

    test('getUser returns null when no user exists', () async {
      final repo = helper.container.read(userRepositoryProvider);
      final user = await repo.getUser();
      expect(user, isNull);
    });
  });
}
