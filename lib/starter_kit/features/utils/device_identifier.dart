import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

/// Device identifier utility
///
/// Generates and persists a unique device identifier.
class DeviceIdentifier {
  static const String _deviceIdKey = 'sk_device_identifier';
  static String? _cachedId;

  /// Get unique device identifier
  /// Persists across app reinstalls on Android, may reset on iOS
  static Future<String> getDeviceIdentifier() async {
    if (_cachedId != null) return _cachedId!;

    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    _cachedId = deviceId;
    return deviceId;
  }

  static Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        // Use Android ID if available, otherwise generate UUID
        if (info.id.isNotEmpty) {
          return 'android_${info.id}';
        }
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        // Use identifierForVendor if available
        if (info.identifierForVendor != null) {
          return 'ios_${info.identifierForVendor}';
        }
      }
    } catch (e) {
      print('DeviceIdentifier: Error getting device info: $e');
    }

    // Fallback to UUID
    return 'uuid_${const Uuid().v4()}';
  }

  /// Get device info summary
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = <String, String>{};

    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        info['platform'] = 'android';
        info['model'] = android.model;
        info['brand'] = android.brand;
        info['version'] = android.version.release;
        info['sdk'] = android.version.sdkInt.toString();
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        info['platform'] = 'ios';
        info['model'] = ios.model;
        info['name'] = ios.name;
        info['version'] = ios.systemVersion;
      }
    } catch (e) {
      info['error'] = e.toString();
    }

    return info;
  }

  /// Clear cached identifier (for testing)
  static void clearCache() {
    _cachedId = null;
  }
}
