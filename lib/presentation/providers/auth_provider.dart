import 'package:adsum/domain/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {

  const User({
    required this.name,
    required this.isGuest,
    this.profile,
  });

  factory User.guest() {
    return const User(name: 'Guest', isGuest: true);
  }

  factory User.fromProfile(UserProfile profile) {
    return User(
      name: profile.fullName,
      isGuest: false,
      profile: profile,
    );
  }
  final String name;
  final bool isGuest;

  final UserProfile? profile;
}

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() {
    return null; // Initial state
  }

  void loginAsGuest() {
    state = User.guest();
  }

  void loginAsUser(UserProfile profile) {
    state = User.fromProfile(profile);
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
