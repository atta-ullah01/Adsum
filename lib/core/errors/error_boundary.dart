import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_types.dart';
import '../utils/app_logger.dart';

/// Central error handling service with recovery strategies.
/// 
/// Features:
/// - Classifies unknown exceptions into typed errors
/// - Tracks error frequency for circuit breaker
/// - Provides recovery callbacks for different error types
class ErrorBoundaryService {
  final Map<String, _CircuitState> _circuitStates = {};
  
  static const int _circuitBreakerThreshold = 3;
  static const Duration _circuitBreakerCooldown = Duration(minutes: 1);
  
  /// Handle an exception and return appropriate recovery action
  RecoveryAction handleException(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    // Classify the error
    final appError = _classifyError(error, stackTrace);
    
    // Log it
    AppLogger.error(
      appError.message,
      context: {'errorType': appError.runtimeType.toString(), 'context': context},
      error: error,
      stackTrace: stackTrace,
    );
    
    // Check circuit breaker
    final circuitKey = appError.runtimeType.toString();
    if (_isCircuitOpen(circuitKey)) {
      return RecoveryAction(
        type: RecoveryType.circuitOpen,
        message: 'Service temporarily unavailable. Please try again later.',
        error: appError,
      );
    }
    
    // Track for circuit breaker
    _trackError(circuitKey);
    
    // Determine recovery action
    return _determineRecovery(appError);
  }
  
  AppException _classifyError(Object error, StackTrace stackTrace) {
    if (error is AppException) return error;
    
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed host lookup')) {
      return NetworkException(
        message: 'Network connection failed',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Timeout
    if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return NetworkException(
        message: 'Request timed out',
        originalError: error,
        stackTrace: stackTrace,
        isTimeout: true,
      );
    }
    
    // Auth errors
    if (errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('jwt expired') ||
        errorString.contains('invalid token')) {
      return AuthException(
        message: 'Authentication failed',
        type: AuthErrorType.tokenExpired,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Storage errors
    if (errorString.contains('no space left') ||
        errorString.contains('disk quota exceeded')) {
      return SystemException(
        message: 'Storage full',
        type: SystemErrorType.storageFull,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Data corruption
    if (errorString.contains('format') ||
        errorString.contains('unexpected character') ||
        errorString.contains('invalid json')) {
      return DataIntegrityException(
        message: 'Data parsing failed',
        type: DataIntegrityErrorType.parseError,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Unknown
    return UnknownException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  RecoveryAction _determineRecovery(AppException error) {
    if (error is NetworkException) {
      return RecoveryAction(
        type: error.isRecoverable ? RecoveryType.retry : RecoveryType.offlineMode,
        message: error.displayMessage,
        error: error,
        retryDelay: const Duration(seconds: 5),
      );
    }
    
    if (error is AuthException) {
      return RecoveryAction(
        type: error.isRecoverable ? RecoveryType.refreshAuth : RecoveryType.reauthenticate,
        message: error.displayMessage,
        error: error,
      );
    }
    
    if (error is DataIntegrityException) {
      return RecoveryAction(
        type: RecoveryType.restoreBackup,
        message: error.displayMessage,
        error: error,
      );
    }
    
    if (error is ValidationException) {
      return RecoveryAction(
        type: RecoveryType.showError,
        message: error.displayMessage,
        error: error,
      );
    }
    
    if (error is SystemException) {
      return RecoveryAction(
        type: RecoveryType.showGuidance,
        message: error.displayMessage,
        error: error,
      );
    }
    
    if (error is SyncException) {
      return RecoveryAction(
        type: error.type == SyncErrorType.conflict 
            ? RecoveryType.promptUser 
            : RecoveryType.retry,
        message: error.displayMessage,
        error: error,
      );
    }
    
    // Unknown errors
    return RecoveryAction(
      type: RecoveryType.showError,
      message: error.displayMessage,
      error: error,
    );
  }
  
  void _trackError(String key) {
    final state = _circuitStates[key] ?? _CircuitState();
    state.failures++;
    state.lastFailure = DateTime.now();
    _circuitStates[key] = state;
  }
  
  bool _isCircuitOpen(String key) {
    final state = _circuitStates[key];
    if (state == null) return false;
    
    // Reset if cooldown passed
    if (state.lastFailure != null &&
        DateTime.now().difference(state.lastFailure!) > _circuitBreakerCooldown) {
      _circuitStates.remove(key);
      return false;
    }
    
    return state.failures >= _circuitBreakerThreshold;
  }
  
  /// Reset circuit breaker for a specific error type
  void resetCircuit(String key) {
    _circuitStates.remove(key);
  }
  
  /// Reset all circuit breakers
  void resetAllCircuits() {
    _circuitStates.clear();
  }
}

class _CircuitState {
  int failures = 0;
  DateTime? lastFailure;
}

/// Recovery action determined by error boundary
class RecoveryAction {
  final RecoveryType type;
  final String message;
  final AppException error;
  final Duration? retryDelay;
  
  const RecoveryAction({
    required this.type,
    required this.message,
    required this.error,
    this.retryDelay,
  });
}

enum RecoveryType {
  retry,           // Auto-retry with backoff
  offlineMode,     // Switch to offline mode
  refreshAuth,     // Silently refresh token
  reauthenticate,  // Prompt user to re-login
  restoreBackup,   // Restore from backup
  showError,       // Show error to user
  showGuidance,    // Show guidance dialog
  promptUser,      // Prompt user for decision
  circuitOpen,     // Circuit breaker tripped
}

// Riverpod provider
final errorBoundaryProvider = Provider<ErrorBoundaryService>((ref) {
  return ErrorBoundaryService();
});

/// Widget that wraps child with error boundary
class ErrorBoundaryWidget extends ConsumerWidget {
  final Widget child;
  final Widget Function(BuildContext, AppException)? errorBuilder;
  
  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.errorBuilder,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child; // In production, this would use ErrorWidget.builder
  }
}

/// Global error handler for runZonedGuarded
void globalErrorHandler(Object error, StackTrace stack) {
  AppLogger.fatal(
    'Uncaught exception',
    error: error,
    stackTrace: stack,
    tags: ['fatal', 'uncaught'],
  );
  
  // In debug mode, rethrow to see in console
  if (kDebugMode) {
    debugPrint('FATAL: $error\n$stack');
  }
}

/// Flutter error handler
void flutterErrorHandler(FlutterErrorDetails details) {
  AppLogger.error(
    'Flutter error: ${details.summary}',
    error: details.exception,
    stackTrace: details.stack,
    context: {'library': details.library},
    tags: ['flutter', 'framework'],
  );
  
  // Use default handler in debug mode
  if (kDebugMode) {
    FlutterError.dumpErrorToConsole(details);
  }
}
