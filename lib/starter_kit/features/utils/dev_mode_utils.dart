/// Development mode utilities
///
/// Detects if app is running in debug/development mode.
class DevModeUtils {
  /// Check if running in debug mode
  static bool get isDebugMode {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  /// Check via dart-define environment variable
  static bool get isFoundersVersion {
    return const bool.fromEnvironment('founders_version', defaultValue: false);
  }

  /// Check via dart-define environment variable
  static bool get isStaging {
    return const bool.fromEnvironment('staging', defaultValue: false);
  }

  /// Get environment name
  static String get environmentName {
    if (isFoundersVersion) return 'founders';
    if (isStaging) return 'staging';
    if (isDebugMode) return 'debug';
    return 'production';
  }

  /// Print debug message only in debug mode
  static void debugLog(String message) {
    if (isDebugMode) {
      print('[DEBUG] $message');
    }
  }
}
