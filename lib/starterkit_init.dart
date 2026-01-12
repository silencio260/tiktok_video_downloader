import 'package:flutter/material.dart';

import 'starter_kit/starter_kit.dart';
import 'starter_kit/features/ads/domain/repositories/ads_repository.dart';
import 'starter_kit/features/ads/presentation/bloc/ads_bloc.dart';
import 'starter_kit/features/analytics/data/datasources/posthog_remote_data_source.dart';
import 'starter_kit/features/analytics/presentation/bloc/analytics_event.dart';
import 'starter_kit/features/services/push_notifications/domain/repositories/push_notifications_repository.dart';

/// Initialize StarterKit with all features
Future<void> initializeStarterKit({
  required String supportEmail,
  String? posthogApiKey,
  String? posthogHost,
  String? feedbackNestApiKey,
  AdsConfig? adsConfig,
  String? oneSignalAppId,
}) async {
  await _initializeStarterKitCore(
    posthogApiKey: posthogApiKey,
    feedbackNestApiKey: feedbackNestApiKey,
    supportEmail: supportEmail,
  );
  await _initializePostHog(
    posthogApiKey: posthogApiKey,
    posthogHost: posthogHost,
  );
  _initializeAnalytics();
  await _initializeAds(adsConfig: adsConfig);
  await _initializeOneSignal(oneSignalAppId: oneSignalAppId);
}

/// Initialize StarterKit core (Analytics, Ads, IAP, Services)
Future<void> _initializeStarterKitCore({
  String? posthogApiKey,
  String? feedbackNestApiKey,
  required String supportEmail,
}) async {
  await StarterKit.initialize(
    postHogDataSource:
        (posthogApiKey != null && posthogApiKey.isNotEmpty)
            ? PostHogRemoteDataSourceImpl()
            : null,
    feedbackNestApiKey:
        (feedbackNestApiKey != null && feedbackNestApiKey.isNotEmpty)
            ? feedbackNestApiKey
            : null,
    supportEmail: supportEmail,
  );
}

/// Initialize PostHog Analytics
Future<void> _initializePostHog({
  String? posthogApiKey,
  String? posthogHost,
}) async {
  if (posthogApiKey != null &&
      posthogApiKey.isNotEmpty &&
      StarterKit.postHog != null) {
    await StarterKit.postHog!.initialize(
      apiKey: posthogApiKey,
      host: posthogHost ?? 'https://app.posthog.com',
    );
  }
}

/// Initialize Analytics (Firebase)
void _initializeAnalytics() {
  StarterKit.analyticsBloc.add(const AnalyticsInitialize());
}

/// Initialize Ads with ad unit IDs
Future<void> _initializeAds({AdsConfig? adsConfig}) async {
  if (adsConfig != null) {
    StarterKit.adsBloc.add(AdsInitialize(config: adsConfig));
  }
}

/// Initialize OneSignal Push Notifications
Future<void> _initializeOneSignal({String? oneSignalAppId}) async {
  if (oneSignalAppId != null && oneSignalAppId.isNotEmpty) {
    try {
      final pushRepo = StarterKit.sl<PushNotificationsRepository>();
      await pushRepo.initialize(oneSignalAppId);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('OneSignal initialization error: $e');
    }
  }
}
