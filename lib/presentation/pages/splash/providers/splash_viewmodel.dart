import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashState {
  checking,
  authenticated,
  unauthenticated,
  error,
}

class SplashViewModel extends AutoDisposeNotifier<SplashState> {
  @override
  SplashState build() {
    _initSession();
    return SplashState.checking;
  }

  Future<void> _initSession() async {
    // Artificial delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final seeder = ref.read(mockDataSeederProvider);
      // Force seed for dev env if enabled
      const enableSeeding = bool.fromEnvironment('ENABLE_SEEDING', defaultValue: true);
      if (kDebugMode && enableSeeding) {
         await seeder.seedActionItems();
         await seeder.seedEvents();
         await seeder.seedWork();
         await seeder.seedAttendance();
      }

      if (!await seeder.isSeeded()) {
         await seeder.seedAllData();
      }

      final userRepo = ref.read(userRepositoryProvider);
      final user = await userRepo.getUser();

      if (user != null) {
        ref.read(authProvider.notifier).loginAsUser(user);
        state = SplashState.authenticated;
      } else {
        state = SplashState.unauthenticated;
      }
    } catch (e) {
      debugPrint('Splash Session Check Error: $e');
      // state = SplashState.error; // Or fallback to unauthenticated?
      // Let's fallback to unauthenticated to not block user
      state = SplashState.unauthenticated;
    }
  }
}

final splashViewModelProvider = NotifierProvider.autoDispose<SplashViewModel, SplashState>(SplashViewModel.new);
