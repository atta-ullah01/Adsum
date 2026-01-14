/// Data validation pipeline for ensuring data integrity.
///
/// Implements the validation flow:
/// Input → Sanitize → Validate Schema → Validate Business Rules → Store/Reject

import 'package:adsum/core/errors/error_types.dart';
import 'package:adsum/core/utils/app_logger.dart';

/// Result of validation
class ValidationResult {
  final bool isValid;
  final Map<String, String> fieldErrors;
  final String? message;
  
  const ValidationResult.valid()
      : isValid = true,
        fieldErrors = const {},
        message = null;
  
  const ValidationResult.invalid({
    required this.fieldErrors,
    this.message,
  }) : isValid = false;
  
  factory ValidationResult.fromFieldError(String field, String error) {
    return ValidationResult.invalid(
      fieldErrors: {field: error},
      message: error,
    );
  }
}

/// Data sanitizer - cleans input before validation
class DataSanitizer {
  /// Sanitize a string value
  static String sanitizeString(String? value) {
    if (value == null) return '';
    
    return value
        .trim()
        // Remove control characters
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Sanitize an email
  static String sanitizeEmail(String? value) {
    if (value == null) return '';
    return sanitizeString(value).toLowerCase();
  }
  
  /// Sanitize a map of string values
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, sanitizeString(value));
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, sanitizeMap(value));
      }
      return MapEntry(key, value);
    });
  }
}

/// Schema validator - checks structure and types
abstract class SchemaValidator<T> {
  ValidationResult validate(T data);
}

/// User data validator
class UserValidator extends SchemaValidator<Map<String, dynamic>> {
  @override
  ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Required fields
    if (!_hasNonEmptyString(data, 'user_id')) {
      errors['user_id'] = 'User ID is required';
    }
    
    if (!_hasNonEmptyString(data, 'email')) {
      errors['email'] = 'Email is required';
    } else if (!_isValidEmail(data['email'] as String)) {
      errors['email'] = 'Invalid email format';
    }
    
    if (!_hasNonEmptyString(data, 'full_name')) {
      errors['full_name'] = 'Full name is required';
    }
    
    // Optional field types
    if (data['university_id'] != null && data['university_id'] is! String) {
      errors['university_id'] = 'University ID must be a string';
    }
    
    if (data['settings'] != null && data['settings'] is! Map) {
      errors['settings'] = 'Settings must be an object';
    }
    
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: errors);
  }
  
  bool _hasNonEmptyString(Map<String, dynamic> data, String key) {
    return data[key] is String && (data[key] as String).isNotEmpty;
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email);
  }
}

/// Enrollment data validator
class EnrollmentValidator extends SchemaValidator<Map<String, dynamic>> {
  @override
  ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Required fields
    if (!_hasNonEmptyString(data, 'enrollment_id')) {
      errors['enrollment_id'] = 'Enrollment ID is required';
    }
    
    // Must have either course_code or custom_course
    final hasCourseCode = data['course_code'] is String && 
        (data['course_code'] as String).isNotEmpty;
    final hasCustomCourse = data['custom_course'] is Map;
    
    if (!hasCourseCode && !hasCustomCourse) {
      errors['course'] = 'Either course_code or custom_course is required';
    }
    
    // Validate custom course if present
    if (hasCustomCourse) {
      final customCourse = data['custom_course'] as Map;
      if (!customCourse.containsKey('code') || customCourse['code'] is! String) {
        errors['custom_course.code'] = 'Custom course code is required';
      }
      if (!customCourse.containsKey('name') || customCourse['name'] is! String) {
        errors['custom_course.name'] = 'Custom course name is required';
      }
    }
    
    // Validate target_attendance range
    if (data['target_attendance'] != null) {
      final target = data['target_attendance'];
      if (target is! num || target < 0 || target > 100) {
        errors['target_attendance'] = 'Target attendance must be between 0 and 100';
      }
    }
    
    // Validate stats if present
    if (data['stats'] != null) {
      if (data['stats'] is! Map) {
        errors['stats'] = 'Stats must be an object';
      } else {
        final stats = data['stats'] as Map;
        if (stats['attended'] is num && stats['total_classes'] is num) {
          final attended = (stats['attended'] as num).toInt();
          final total = (stats['total_classes'] as num).toInt();
          if (attended < 0) {
            errors['stats.attended'] = 'Attended cannot be negative';
          }
          if (total < 0) {
            errors['stats.total_classes'] = 'Total classes cannot be negative';
          }
          if (attended > total) {
            errors['stats.attended'] = 'Attended cannot exceed total classes';
          }
        }
      }
    }
    
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: errors);
  }
  
  bool _hasNonEmptyString(Map<String, dynamic> data, String key) {
    return data[key] is String && (data[key] as String).isNotEmpty;
  }
}

/// Attendance log validator
class AttendanceValidator extends SchemaValidator<Map<String, dynamic>> {
  static const validStatuses = ['PRESENT', 'ABSENT', 'PENDING'];
  static const validSources = ['GEOFENCE', 'WIFI', 'MANUAL', 'CROWD_VERIFIED'];
  static const validVerificationStates = ['AUTO_CONFIRMED', 'MANUAL_OVERRIDE', 'PENDING'];
  
  @override
  ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    if (!_hasNonEmptyString(data, 'log_id')) {
      errors['log_id'] = 'Log ID is required';
    }
    
    if (!_hasNonEmptyString(data, 'enrollment_id')) {
      errors['enrollment_id'] = 'Enrollment ID is required';
    }
    
    if (!_hasNonEmptyString(data, 'date')) {
      errors['date'] = 'Date is required';
    } else {
      try {
        DateTime.parse(data['date'] as String);
      } catch (_) {
        errors['date'] = 'Invalid date format (use YYYY-MM-DD)';
      }
    }
    
    if (data['status'] != null && !validStatuses.contains(data['status'])) {
      errors['status'] = 'Status must be one of: ${validStatuses.join(", ")}';
    }
    
    if (data['source'] != null && !validSources.contains(data['source'])) {
      errors['source'] = 'Source must be one of: ${validSources.join(", ")}';
    }
    
    if (data['confidence_score'] != null) {
      final score = data['confidence_score'];
      if (score is! num || score < 0 || score > 100) {
        errors['confidence_score'] = 'Confidence score must be between 0 and 100';
      }
    }
    
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(fieldErrors: errors);
  }
  
  bool _hasNonEmptyString(Map<String, dynamic> data, String key) {
    return data[key] is String && (data[key] as String).isNotEmpty;
  }
}

/// Unified validation service
class DataValidationService {
  final _userValidator = UserValidator();
  final _enrollmentValidator = EnrollmentValidator();
  final _attendanceValidator = AttendanceValidator();
  
  /// Validate and sanitize user data
  Map<String, dynamic> validateUser(Map<String, dynamic> data) {
    final sanitized = DataSanitizer.sanitizeMap(data);
    final result = _userValidator.validate(sanitized);
    
    if (!result.isValid) {
      AppLogger.warn(
        'User validation failed',
        context: {'errors': result.fieldErrors},
      );
      throw ValidationException(
        message: result.message ?? 'Invalid user data',
        fieldErrors: result.fieldErrors,
      );
    }
    
    return sanitized;
  }
  
  /// Validate and sanitize enrollment data
  Map<String, dynamic> validateEnrollment(Map<String, dynamic> data) {
    final sanitized = DataSanitizer.sanitizeMap(data);
    final result = _enrollmentValidator.validate(sanitized);
    
    if (!result.isValid) {
      AppLogger.warn(
        'Enrollment validation failed',
        context: {'errors': result.fieldErrors},
      );
      throw ValidationException(
        message: result.message ?? 'Invalid enrollment data',
        fieldErrors: result.fieldErrors,
      );
    }
    
    return sanitized;
  }
  
  /// Validate and sanitize attendance data
  Map<String, dynamic> validateAttendance(Map<String, dynamic> data) {
    final sanitized = DataSanitizer.sanitizeMap(data);
    final result = _attendanceValidator.validate(sanitized);
    
    if (!result.isValid) {
      AppLogger.warn(
        'Attendance validation failed',
        context: {'errors': result.fieldErrors},
      );
      throw ValidationException(
        message: result.message ?? 'Invalid attendance data',
        fieldErrors: result.fieldErrors,
      );
    }
    
    return sanitized;
  }
}
