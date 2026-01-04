import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../domain/entities/analytics_event.dart';
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
    await _analytics?.logEvent(
      name: event.name,
      parameters: event.parameters.cast<String, Object>(),
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
}
