import 'package:posthog_flutter/posthog_flutter.dart';

import 'analytics_provider.dart';

/// PostHog analytics provider implementation
///
/// Provides product analytics and feature flags via PostHog.
class PostHogProvider implements AnalyticsProvider {
  final String apiKey;
  final String host;
  bool _isInitialized = false;

  PostHogProvider({
    required this.apiKey,
    this.host = 'https://app.posthog.com',
  });

  @override
  Future<void> initialize() async {
    try {
      // PostHog is typically configured in AndroidManifest/Info.plist
      // This provider wraps the existing instance
      _isInitialized = true;
      print('PostHogProvider: Initialized');
    } catch (e) {
      print('PostHogProvider: Failed to initialize: $e');
    }
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_isInitialized) return;

    try {
      await Posthog().capture(eventName: name, properties: parameters);
    } catch (e) {
      print('PostHogProvider: Error logging event $name: $e');
    }
  }

  @override
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    if (!_isInitialized) return;

    try {
      await Posthog().screen(
        screenName: screenName,
        properties: screenClass != null ? {'screen_class': screenClass} : null,
      );
    } catch (e) {
      print('PostHogProvider: Error logging screen view: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized) return;

    try {
      if (userId != null) {
        await Posthog().identify(userId: userId);
      } else {
        await Posthog().reset();
      }
    } catch (e) {
      print('PostHogProvider: Error setting user ID: $e');
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    // PostHog handles this differently - via identify with properties
    // This is a simplified implementation
    print('PostHogProvider: setUserProperty not directly supported');
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagKey) async {
    if (!_isInitialized) return false;

    try {
      return await Posthog().isFeatureEnabled(flagKey);
    } catch (e) {
      print('PostHogProvider: Error checking feature flag: $e');
      return false;
    }
  }

  /// Get feature flag value
  Future<dynamic> getFeatureFlagValue(String flagKey) async {
    if (!_isInitialized) return null;

    try {
      return await Posthog().getFeatureFlag(flagKey);
    } catch (e) {
      print('PostHogProvider: Error getting feature flag value: $e');
      return null;
    }
  }

  /// Reload feature flags
  Future<void> reloadFeatureFlags() async {
    if (!_isInitialized) return;

    try {
      await Posthog().reloadFeatureFlags();
    } catch (e) {
      print('PostHogProvider: Error reloading feature flags: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}
