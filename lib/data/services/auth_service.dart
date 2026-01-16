import 'package:adsum/core/errors/error_types.dart' as app_error;
import 'package:adsum/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class AuthService {

  AuthService(this._supabase);
  final SupabaseClient _supabase;

  /// Current user or null
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  /// Sign in with Google (OAuth)
  /// 
  /// Returns true if sign-in flow started successfully.
  /// Note: The actual completion happens via deep link callback.
  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In', tags: ['auth']);
      
      // Web uses redirect, Mobile uses deep linking
      // Deep link must be configured in Supabase & AndroidManifest/Info.plist
      const redirectUrl = kIsWeb 
          ? null 
          : 'io.supabase.adsum://login-callback';
          
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      
      return true;
    } catch (e, stack) {
      AppLogger.error('Google Sign-In failed', error: e, stackTrace: stack, tags: ['auth']);
      throw app_error.AuthException(
        message: 'Sign in failed: $e',
        type: app_error.AuthErrorType.invalidCredentials,
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out', tags: ['auth']);
      await _supabase.auth.signOut();
    } catch (e, stack) {
      AppLogger.error('Sign out failed', error: e, stackTrace: stack, tags: ['auth']);
      throw app_error.AuthException(
        message: 'Failed to sign out: $e',
        type: app_error.AuthErrorType.notAuthenticated,
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;
  
  /// Refresh session if needed
  Future<void> refreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return;
      
      if (session.isExpired) {
         await _supabase.auth.refreshSession();
      }
    } catch (e) {
      // Session refresh failed, likely needs re-login
      AppLogger.warn('Session refresh failed', error: e, tags: ['auth']);
    }
  }
}
