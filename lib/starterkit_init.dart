import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'starter_kit/core/core_injector.dart';
import 'starter_kit/core/storage/local_storage.dart';
import 'starter_kit/features/analytics/domain/services/retention_tracker.dart';
import 'starter_kit/features/analytics/domain/services/user_targeting_manager.dart';

import 'starter_kit/starter_kit.dart';
import 'starter_kit/features/ads/domain/repositories/ads_repository.dart';
import 'starter_kit/features/analytics/data/datasources/posthog_remote_data_source.dart';
import 'starter_kit/features/analytics/presentation/bloc/analytics_event.dart';
import 'starter_kit/features/services/push_notifications/domain/repositories/push_notifications_repository.dart';
import 'starter_kit/features/services/remote_config/domain/repositories/remote_config_repository.dart';
import 'starter_kit/features/ads/presentation/bloc/ads_bloc.dart';
import 'starter_kit/features/analytics/domain/utils/analytics_names.dart';

/// Initialize StarterKit with all features
Future<void> initializeStarterKit({
  required String supportEmail,
  String? posthogApiKey,
  String? posthogHost,
  String? feedbackNestApiKey,
  AdsConfig? adsConfig,
  String? oneSignalAppId,
  Map<String, dynamic>? remoteConfigDefaults,
}) async {
  await _initializeStarterKitCore(
    posthogApiKey: posthogApiKey,
    feedbackNestApiKey: feedbackNestApiKey,
    supportEmail: supportEmail,
  );

  // Setup Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    StarterKit.analytics.recordFlutterError(
      errorDetails.exception,
      errorDetails.stack,
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    StarterKit.analytics.recordError(error, stack, fatal: true);
    return true;
  };

  // Fetch and activate Remote Config
  final remoteConfig = StarterKit.sl<RemoteConfigRepository>();
  if (remoteConfigDefaults != null) {
    debugPrint('--- Remote Config Defaults ---');
    remoteConfigDefaults.forEach((key, value) {
      debugPrint('$key: $value');
    });
    await remoteConfig.setDefaults(remoteConfigDefaults);
  }

  await remoteConfig.fetchAndActivate();

  // Initialize analytics names from Remote Config
  AnalyticsNames.instance.initialize(remoteConfig);

  // Merge Remote Config with provided AdsConfig
  final finalAdsConfig = _getAdsConfigFromRemoteConfig(adsConfig);

  debugPrint('--- Final Remote Config Values (Fetched) ---');
  debugPrint(
    'min_insta_ad_interval: ${finalAdsConfig.minInterstitialInterval}',
  );
  debugPrint('min_rewarded_ad_interval: ${finalAdsConfig.minRewardedInterval}');
  debugPrint('min_banner_ad_interval: ${finalAdsConfig.minBannerInterval}');
  debugPrint('min_app_open_ad: ${finalAdsConfig.minAppOpenInterval}');
  debugPrint('should_show_app_open_ad: ${finalAdsConfig.shouldShowAppOpenAd}');
  debugPrint(
    'time_before_first_insta_ad: ${finalAdsConfig.timeBeforeFirstInstaAd}',
  );
  debugPrint(
    'time_before_first_rewared_ad: ${finalAdsConfig.timeBeforeFirstRewardedAd}',
  );
  debugPrint('interstitial_ad_id: ${finalAdsConfig.interstitialAdUnitId}');
  debugPrint('rewarded_ad_id: ${finalAdsConfig.rewardedAdUnitId}');
  debugPrint('-------------------------------------------');

  await _initializePostHog(
    posthogApiKey: posthogApiKey,
    posthogHost: posthogHost,
  );
  _initializeAnalytics();

  // Start Retention Tracking & User Targeting
  RetentionTracker.instance.init(StarterKit.sl<LocalStorage>());
  await UserTargetingManager.startTracking(StarterKit.analytics);

  await _initializeAds(adsConfig: finalAdsConfig);
  await _initializeOneSignal(oneSignalAppId: oneSignalAppId);
}

/// Helper to build AdsConfig from Remote Config with fallback to provided config
AdsConfig _getAdsConfigFromRemoteConfig(AdsConfig? baseConfig) {
  final rc = StarterKit.sl<RemoteConfigRepository>();

  // Helper to get RC string or fallback
  String? getRCString(String key, String? fallback) {
    final value = rc.getString(key);
    return value.isNotEmpty ? value : fallback;
  }

  return AdsConfig(
    bannerAdUnitId: getRCString('banner_ad_id', baseConfig?.bannerAdUnitId),
    interstitialAdUnitId: getRCString(
      'interstitial_ad_id',
      baseConfig?.interstitialAdUnitId,
    ),
    rewardedAdUnitId: getRCString(
      'rewarded_ad_id',
      baseConfig?.rewardedAdUnitId,
    ),
    minInterstitialInterval: rc.getInt('min_insta_ad_interval'),
    minRewardedInterval: rc.getInt('min_rewarded_ad_interval'),
    minNativeInterval: rc.getInt('min_native_interval'),
    minAppOpenInterval: rc.getInt('min_app_open_ad'),
    minBannerInterval: rc.getInt('min_banner_ad_interval'),
    shouldShowAppOpenAd: rc.getBool('should_show_app_open_ad'),
    timeBeforeFirstInstaAd: rc.getInt('time_before_first_insta_ad'),
    timeBeforeFirstRewardedAd: rc.getInt('time_before_first_rewared_ad'),
  );
}

/// Initialize StarterKit core (Analytics, Ads, IAP, Services)
Future<void> _initializeStarterKitCore({
  String? posthogApiKey,
  String? feedbackNestApiKey,
  required String supportEmail,
}) async {
  // Core (Storage, etc)
  initCore(StarterKit.sl);

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
