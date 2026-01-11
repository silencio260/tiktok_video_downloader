import 'package:flutter/material.dart';

import 'src/config/environment_vars.dart';
import 'starter_kit/starter_kit.dart';
import 'starter_kit/features/ads/domain/repositories/ads_repository.dart';
import 'starter_kit/features/ads/presentation/bloc/ads_bloc.dart';
import 'starter_kit/features/analytics/data/datasources/posthog_remote_data_source.dart';
import 'starter_kit/features/analytics/presentation/bloc/analytics_event.dart';
import 'starter_kit/features/services/push_notifications/domain/repositories/push_notifications_repository.dart';

/// Initialize StarterKit with all features
Future<void> initializeStarterKit() async {
  await _initializeStarterKitCore();
  await _initializePostHog();
  _initializeAnalytics();
  await _initializeAds();
  await _initializeOneSignal();
}

/// Initialize StarterKit core (Analytics, Ads, IAP, Services)
Future<void> _initializeStarterKitCore() async {
  await StarterKit.initialize(
    postHogDataSource: EnvironmentsVar.hasPosthog
        ? PostHogRemoteDataSourceImpl()
        : null,
    feedbackNestApiKey: EnvironmentsVar.feedBackNestApiKey.isNotEmpty
        ? EnvironmentsVar.feedBackNestApiKey
        : null,
  );
}

/// Initialize PostHog Analytics
Future<void> _initializePostHog() async {
  if (EnvironmentsVar.hasPosthog && StarterKit.postHog != null) {
    await StarterKit.postHog!.initialize(
      apiKey: EnvironmentsVar.posthogApiKey,
      host: 'https://app.posthog.com',
    );
  }
}

/// Initialize Analytics (Firebase)
void _initializeAnalytics() {
  StarterKit.analyticsBloc.add(const AnalyticsInitialize());
}

/// Initialize Ads with ad unit IDs from environment variables
Future<void> _initializeAds() async {
  if (EnvironmentsVar.bannerAdId.isNotEmpty ||
      EnvironmentsVar.interstitialAdId.isNotEmpty ||
      EnvironmentsVar.rewardedAdId.isNotEmpty ||
      EnvironmentsVar.appOpenAdId.isNotEmpty ||
      EnvironmentsVar.nativeAdId.isNotEmpty) {
    StarterKit.adsBloc.add(
      AdsInitialize(
        config: AdsConfig(
          bannerAdUnitId: EnvironmentsVar.bannerAdId.isNotEmpty
              ? EnvironmentsVar.bannerAdId
              : null,
          interstitialAdUnitId: EnvironmentsVar.interstitialAdId.isNotEmpty
              ? EnvironmentsVar.interstitialAdId
              : null,
          rewardedAdUnitId: EnvironmentsVar.rewardedAdId.isNotEmpty
              ? EnvironmentsVar.rewardedAdId
              : null,
          appOpenAdUnitId: EnvironmentsVar.appOpenAdId.isNotEmpty
              ? EnvironmentsVar.appOpenAdId
              : null,
          nativeAdUnitId: EnvironmentsVar.nativeAdId.isNotEmpty
              ? EnvironmentsVar.nativeAdId
              : null,
        ),
      ),
    );
  }
}

/// Initialize OneSignal Push Notifications
Future<void> _initializeOneSignal() async {
  if (EnvironmentsVar.hasOneSignal) {
    try {
      final pushRepo = StarterKit.sl<PushNotificationsRepository>();
      await pushRepo.initialize(EnvironmentsVar.oneSignalAppId);
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('OneSignal initialization error: $e');
    }
  }
}
