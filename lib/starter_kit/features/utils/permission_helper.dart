import 'package:permission_handler/permission_handler.dart';

/// Permission helper utilities
///
/// Simplifies common permission requests.
class PermissionHelper {
  /// Request storage permission
  static Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request photos permission (iOS 14+, Android 13+)
  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Request camera permission
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request notification permission
  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request app tracking transparency (iOS only)
  static Future<bool> requestTrackingTransparency() async {
    final status = await Permission.appTrackingTransparency.request();
    return status.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  /// Check if photos permission is granted
  static Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted;
  }

  /// Open app settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Get permission status summary
  static Future<Map<String, bool>> getStatusSummary() async {
    return {
      'storage': await Permission.storage.isGranted,
      'photos': await Permission.photos.isGranted,
      'camera': await Permission.camera.isGranted,
      'notification': await Permission.notification.isGranted,
    };
  }
}
