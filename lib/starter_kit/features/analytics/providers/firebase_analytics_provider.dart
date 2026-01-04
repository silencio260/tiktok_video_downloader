import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_provider.dart';

/// Firebase Analytics provider implementation
///
/// Wraps Firebase Analytics and Crashlytics.
/// Requires Firebase to be initialized in the root project.
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  FirebaseAnalytics? _analytics;
  bool _isEnabled;
  final bool _enableCrashlytics;

  FirebaseAnalyticsProvider({
    bool enableAnalytics = true,
    bool enableCrashlytics = true,
  }) : _isEnabled = enableAnalytics,
       _enableCrashlytics = enableCrashlytics;

  @override
  Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      try {
        Firebase.app();
        print('FirebaseAnalyticsProvider: Firebase already initialized');
      } catch (e) {
        print(
          'FirebaseAnalyticsProvider: Firebase not initialized - '
          'please initialize Firebase in main.dart',
        );
        return;
      }

      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(_isEnabled);

      if (_enableCrashlytics) {
        _initCrashlytics();
      }

      print('FirebaseAnalyticsProvider: Initialized successfully');
    } catch (e) {
      print('FirebaseAnalyticsProvider: Failed to initialize: $e');
    }
  }

  void _initCrashlytics() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  @override
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      // Convert parameters to Firebase-compatible format
      final Map<String, Object>? params = parameters?.map(
        (key, value) => MapEntry(key, value ?? ''),
      );

      await _analytics!.logEvent(name: name, parameters: params);
    } catch (e) {
      print('FirebaseAnalyticsProvider: Error logging event $name: $e');
    }
  }

  @override
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    if (!_isEnabled || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      print('FirebaseAnalyticsProvider: Error logging screen view: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (_analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
    } catch (e) {
      print('FirebaseAnalyticsProvider: Error setting user ID: $e');
    }
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (_analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      print('FirebaseAnalyticsProvider: Error setting user property: $e');
    }
  }

  /// Log ad impression event
  Future<void> logAdImpression({
    required String adUnitId,
    required String adFormat,
    required double valueMicros,
    required String currency,
  }) async {
    await logEvent('ad_impression', {
      'ad_platform': 'AdMob',
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      'value': valueMicros / 1e6,
      'currency': currency,
    });
  }

  /// Log app open event
  Future<void> logAppOpen() async {
    if (_analytics == null) return;

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      await _analytics!.logAppOpen(parameters: {'platform': platform});
    } catch (e) {
      print('FirebaseAnalyticsProvider: Error logging app open: $e');
    }
  }

  /// Enable or disable collection
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _analytics?.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> dispose() async {
    _analytics = null;
  }
}
