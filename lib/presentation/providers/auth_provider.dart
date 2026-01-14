import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String name;
  final bool isGuest;

  const User({
    required this.name,
    required this.isGuest,
  });

  factory User.guest() {
    return const User(name: "Guest", isGuest: true);
  }

  factory User.mock() {
    return const User(name: "Attaullah", isGuest: false);
  }
}

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() {
    return null; // Initial state
  }

  void loginAsGuest() {
    state = User.guest();
  }

  void loginAsUser() {
    state = User.mock();
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
