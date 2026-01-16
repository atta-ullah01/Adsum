import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsViewModel extends AutoDisposeNotifier<AsyncValue<UserProfile?>> {
  @override
  AsyncValue<UserProfile?> build() {
    return ref.watch(userProfileProvider);
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    // Optimistic update?
    // UserRepo updates instantly but remote might fail.
    // For now, simple await.
    await ref.read(userRepositoryProvider).updateSettings(newSettings);
    // Provider auto-refreshes due to watch? 
    // userProfileProvider is usually a Stream or Future provider. 
    // If it's a Stream, it updates. If Future, we might need refresh.
    // Based on original code: ref.refresh(userProfileProvider);
    ref.refresh(userProfileProvider);
  }

  Future<void> resetData() async {
    await ref.read(userRepositoryProvider).deleteUser();
  }
}

final settingsViewModelProvider = NotifierProvider.autoDispose<SettingsViewModel, AsyncValue<UserProfile?>>(SettingsViewModel.new);
