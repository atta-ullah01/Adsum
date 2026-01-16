import 'package:adsum/domain/models/user_profile.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling device permission requests.
///
/// Used by Sensor Hub to request and verify:
/// - Location Always (for Geofence)
/// - Activity Recognition (for Motion)
/// - Battery Optimization settings
class PermissionService {
  /// Request Location Always permission (for Geofence).
  ///
  /// Returns true if granted, false if denied.
  /// Opens app settings if permanently denied.
  Future<bool> requestLocationPermission() async {
    // First request "when in use" then upgrade to "always"
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      status = await Permission.locationAlways.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Request Activity Recognition permission (for Motion).
  ///
  /// Returns true if granted, false if denied.
  Future<bool> requestActivityPermission() async {
    final status = await Permission.activityRecognition.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Open Battery Optimization settings.
  ///
  /// User must manually disable optimization for this app.
  /// Returns true (user must confirm manually).
  Future<bool> requestBatteryOptimization() async {
    await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
    return true; // Cannot verify programmatically
  }

  /// Check if Location Always permission is granted.
  Future<bool> isLocationGranted() async {
    return Permission.locationAlways.isGranted;
  }

  /// Check if Activity Recognition permission is granted.
  Future<bool> isActivityGranted() async {
    return Permission.activityRecognition.isGranted;
  }

  /// Verify all enabled permissions are still granted.
  ///
  /// Returns a map of permission status based on user settings.
  Future<Map<String, bool>> checkPermissions(UserSettings settings) async {
    final results = <String, bool>{
      'location': true,
      'activity': true,
      'battery': true, // Cannot check programmatically
    };

    if (settings.sensorGeofenceEnabled) {
      results['location'] = await isLocationGranted();
    }

    if (settings.sensorMotionEnabled) {
      results['activity'] = await isActivityGranted();
    }

    return results;
  }
}
