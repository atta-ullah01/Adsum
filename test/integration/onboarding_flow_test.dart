
import 'package:adsum/core/router/router.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/data/repositories/repositories.dart';
import 'package:adsum/domain/models/user_profile.dart';
import 'package:adsum/presentation/pages/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/providers/auth_provider.dart';
import 'package:adsum/data/sources/local/json_file_service.dart';

// Fake Repository to capture saved user
class FakeUserRepository extends UserRepository {
  FakeUserRepository() : super(JsonFileService()); 

  UserProfile? savedUser;

  @override
  Future<void> saveUser(UserProfile user) async {
    savedUser = user;
  }
}

// Fake Auth Notifier
class FakeAuthNotifier extends AuthNotifier {
  @override
  void loginAsUser() {
    state = User.mock();
  }
}

void main() {
  testWidgets('AuthPage Flow: Select University, Skip Hostel, Default Section A', (WidgetTester tester) async {
    final fakeUserRepo = FakeUserRepository();

    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
        GoRoute(path: '/ocr', builder: (_, __) => const Scaffold(body: Text('OCR Page', key: Key('ocr_page')))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeUserRepo),
          authProvider.overrideWith(() => FakeAuthNotifier()),
          // Use real SharedDataRepository as it has mock data we rely on
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    // Initial state is loading (SharedDataRepository has 500ms delay)
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Wait for data to load
    await tester.pump(const Duration(seconds: 1)); 
    await tester.pumpAndSettle();

    // 1. Verify University Dropdown exists
    expect(find.text('Select University'), findsOneWidget);
    expect(find.text('Select Hostel'), findsNothing); // Hidden until uni selected

    // 2. Select University - Tap the dropdown icon
    await tester.tap(find.byKey(const Key('dropdown_university')));
    await tester.pumpAndSettle();
    
    // Tap on option (e.g., IIT Delhi) - This is inside the menu, so finding by text is fine (menu items don't have our keys usually unless passed)
    // DropdownMenuItem creates an Item.
    await tester.tap(find.text('IIT Delhi').last);
    await tester.pumpAndSettle();

    // 3. Verify Hostel Dropdown Appears
    expect(find.byKey(const Key('dropdown_hostel')), findsOneWidget);

    // 4. Verify we can skip Hostel (it is optional)

    // 5. Verify Section defaults to 'A' (Leave Section empty)

    // 6. Tap Continue (Manual scroll to avoid finding ambiguous Scrollables)
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Continue').first, warnIfMissed: false);
    await tester.pump(); // Start async process

    // 7. Verify Save User Logic
    expect(fakeUserRepo.savedUser, isNotNull);
    expect(fakeUserRepo.savedUser!.universityId, 'iit_delhi');
    expect(fakeUserRepo.savedUser!.defaultSection, 'A');
    // homeHostelId might be null if we skipped it, let's check our logic
    // In AuthPage: homeHostelId: _selectedHostelId (nullable in UserProfile?)
    expect(fakeUserRepo.savedUser!.homeHostelId, isNull);
    expect(fakeUserRepo.savedUser!.fullName, 'Student'); // Default name

    // 8. Verify Navigation to OCR Page (WizardOcrPage)
    // We need to define the WizardOcrPage in the test routes to verify its content
    // But currently the route builder just returns a Scaffold
    // Let's verify we reached the right route path '/ocr' first. 
    // Since we mocked the route builder as Text('OCR Page'), we verify that text.
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ocr_page')), findsOneWidget);

    // Ideally, we would test the WizardOcrPage widget itself here.
    // For now, let's just confirm the flow up to this point is correct.
    // To rigorously test the new WizardOcrPage, we should replace the mock route builder with the actual widget.
  });
}
