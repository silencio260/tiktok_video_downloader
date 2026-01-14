import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../domain/entities/analytics_event.dart';
import '../../domain/entities/ad_revenue_event.dart';
import 'analytics_remote_data_source.dart';

/// Firebase implementation of analytics data source
class FirebaseAnalyticsDataSource implements AnalyticsRemoteDataSource {
  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    _isInitialized = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (!_isInitialized) return;
    final params = Map<String, Object>.from(event.parameters);
    params['platform'] = Platform.operatingSystem;
    await _analytics?.logEvent(name: event.name, parameters: params);
  }

  @override
  Future<void> logAdRevenue(AdRevenueEvent event) async {
    if (!_isInitialized) return;
    // Manual mapping to match Status Saver template's "special" keys
    await _analytics?.logEvent(
      name: 'ad_impression',
      parameters: {
        'ad_platform': event.adSource,
        'ad_unit_id': event.adUnitId,
        'ad_format': event.adFormat ?? 'unknown',
        'value': event.value,
        'valueMicros': event.valueMicros,
        'currency': event.currency,
        'platform': Platform.operatingSystem,
        if (event.adNetwork != null) 'ad_network': event.adNetwork!,
      },
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    await _analytics?.setUserId(id: userId);
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!_isInitialized) return;
    await _analytics?.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (!_isInitialized) return;
    await _analytics?.logScreenView(screenName: screenName);
  }

  @override
  Future<void> logRetentionEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    if (!_isInitialized) return;
    final params = parameters.cast<String, Object>();
    final finalParams = Map<String, Object>.from(params);
    finalParams['platform'] = Platform.operatingSystem;
    await _analytics?.logEvent(name: eventName, parameters: finalParams);
  }

  @override
  Future<void> logUserSegmentEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    if (!_isInitialized) return;
    final params = parameters.cast<String, Object>();
    final finalParams = Map<String, Object>.from(params);
    finalParams['platform'] = Platform.operatingSystem;
    await _analytics?.logEvent(name: eventName, parameters: finalParams);
  }

  @override
  Future<void> logTargetingEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    if (!_isInitialized) return;
    final params = parameters.cast<String, Object>();
    final finalParams = Map<String, Object>.from(params);
    finalParams['platform'] = Platform.operatingSystem;
    await _analytics?.logEvent(name: eventName, parameters: finalParams);
  }

  @override
  Future<void> recordFlutterError(
    dynamic error,
    dynamic stack, {
    bool fatal = false,
  }) async {
    // If error is FlutterErrorDetails, record as fatal if requested
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }

  @override
  Future<void> recordError(
    dynamic error,
    dynamic stack, {
    bool fatal = false,
  }) async {
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }
}
