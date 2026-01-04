/// Analytics provider interface
///
/// Implement this interface to add new analytics backends.

abstract class AnalyticsProvider {
  /// Initialize the analytics provider
  Future<void> initialize();

  /// Log a custom event with optional parameters
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]);

  /// Log a screen view
  Future<void> logScreenView(String screenName, [String? screenClass]);

  /// Set user ID for analytics
  Future<void> setUserId(String? userId);

  /// Set user property
  Future<void> setUserProperty(String name, String? value);

  /// Dispose of resources
  Future<void> dispose();
}
