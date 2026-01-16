/// Error Classification Taxonomy for Adsum
/// 
/// All application errors inherit from [AppException] for uniform handling.
/// Use these specific types to trigger appropriate recovery strategies.
library;

/// Base exception class for all Adsum errors.
abstract class AppException implements Exception {
  
  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  /// Whether this error can be recovered from automatically
  bool get isRecoverable;
  
  /// User-friendly message for display
  String get displayMessage;
  
  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

/// Network connectivity issues, timeouts, DNS failures
/// Recovery: Auto-retry with backoff → Offline mode
class NetworkException extends AppException {
  
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
    this.isTimeout = false,
  });
  final int? statusCode;
  final bool isTimeout;
  
  @override
  bool get isRecoverable => true;
  
  @override
  String get displayMessage => isTimeout 
      ? 'Connection timed out. Please check your internet.'
      : 'Network error. Working offline.';
      
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

/// Authentication issues: token expired, invalid credentials
/// Recovery: Refresh token → Re-login prompt
class AuthException extends AppException {
  
  const AuthException({
    required super.message,
    required this.type,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final AuthErrorType type;
  
  @override
  bool get isRecoverable => type == AuthErrorType.tokenExpired;
  
  @override
  String get displayMessage {
    switch (type) {
      case AuthErrorType.tokenExpired:
        return 'Session expired. Refreshing...';
      case AuthErrorType.invalidCredentials:
        return 'Invalid credentials. Please sign in again.';
      case AuthErrorType.notAuthenticated:
        return 'Please sign in to continue.';
      case AuthErrorType.insufficientPermissions:
        return "You don't have permission for this action.";
    }
  }
}

enum AuthErrorType {
  tokenExpired,
  invalidCredentials,
  notAuthenticated,
  insufficientPermissions,
}

/// Data integrity issues: corrupted files, schema mismatch
/// Recovery: Restore from backup → Re-sync from cloud
class DataIntegrityException extends AppException {
  
  const DataIntegrityException({
    required super.message,
    required this.type,
    this.affectedEntity,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final DataIntegrityErrorType type;
  final String? affectedEntity;
  
  @override
  bool get isRecoverable => type != DataIntegrityErrorType.migrationFailed;
  
  @override
  String get displayMessage {
    switch (type) {
      case DataIntegrityErrorType.corruptedFile:
        return 'Data file corrupted. Restoring from backup...';
      case DataIntegrityErrorType.schemaMismatch:
        return 'Data format outdated. Updating...';
      case DataIntegrityErrorType.migrationFailed:
        return 'Failed to update data format. Please reinstall.';
      case DataIntegrityErrorType.parseError:
        return 'Could not read data. Restoring...';
    }
  }
}

enum DataIntegrityErrorType {
  corruptedFile,
  schemaMismatch,
  migrationFailed,
  parseError,
}

/// Validation errors: invalid user input, business rule violations
/// Recovery: Reject + show inline error
class ValidationException extends AppException {
  
  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final Map<String, String>? fieldErrors;
  
  @override
  bool get isRecoverable => false; // User must fix input
  
  @override
  String get displayMessage => message;
  
  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;
}

/// System-level errors: storage full, permissions denied
/// Recovery: User guidance dialog
class SystemException extends AppException {
  
  const SystemException({
    required super.message,
    required this.type,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final SystemErrorType type;
  
  @override
  bool get isRecoverable => false; // Requires user action
  
  @override
  String get displayMessage {
    switch (type) {
      case SystemErrorType.storageFull:
        return 'Device storage is full. Please free up space.';
      case SystemErrorType.permissionDenied:
        return 'Permission required. Please enable in Settings.';
      case SystemErrorType.featureUnavailable:
        return 'This feature is not available on your device.';
    }
  }
}

enum SystemErrorType {
  storageFull,
  permissionDenied,
  featureUnavailable,
}

/// Sync-related errors: conflicts, queue failures
/// Recovery: Depends on type
class SyncException extends AppException {
  
  const SyncException({
    required super.message,
    required this.type,
    this.entityId,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  final SyncErrorType type;
  final String? entityId;
  
  @override
  bool get isRecoverable => type != SyncErrorType.deadLetter;
  
  @override
  String get displayMessage {
    switch (type) {
      case SyncErrorType.conflict:
        return 'Sync conflict detected. Please resolve.';
      case SyncErrorType.queueFull:
        return 'Too many pending changes. Please connect to sync.';
      case SyncErrorType.deadLetter:
        return 'Some changes could not be synced. Tap for details.';
      case SyncErrorType.staleData:
        return 'Data may be outdated. Pull to refresh.';
    }
  }
}

enum SyncErrorType {
  conflict,
  queueFull,
  deadLetter,
  staleData,
}

/// Unknown/unexpected errors for crash reporting
/// Recovery: Log + generic error UI + crash report
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
  
  @override
  bool get isRecoverable => false;
  
  @override
  String get displayMessage => 'Something went wrong. Please try again.';
}
