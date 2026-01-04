/// Starter Kit Configuration
///
/// All API keys and configuration values are injected from the root project.
/// No values are hard-coded in the plugin.

/// Main configuration class for StarterKit initialization
class StarterKitConfig {
  final FirebaseConfig? firebase;
  final AdMobConfig? adMob;
  final RevenueCatConfig? revenueCat;
  final PostHogConfig? postHog;
  final bool enableDebugMode;

  const StarterKitConfig({
    this.firebase,
    this.adMob,
    this.revenueCat,
    this.postHog,
    this.enableDebugMode = false,
  });
}

/// Firebase configuration
class FirebaseConfig {
  final bool enableAnalytics;
  final bool enableCrashlytics;

  const FirebaseConfig({
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
  });
}

/// AdMob configuration
class AdMobConfig {
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;
  final List<String> testDeviceIds;

  const AdMobConfig({
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
    this.testDeviceIds = const [],
  });
}

/// RevenueCat configuration
class RevenueCatConfig {
  final String apiKey;
  final String? entitlementId;

  const RevenueCatConfig({required this.apiKey, this.entitlementId});
}

/// PostHog configuration
class PostHogConfig {
  final String apiKey;
  final String host;

  const PostHogConfig({
    required this.apiKey,
    this.host = 'https://app.posthog.com',
  });
}

/// App Rating configuration
class AppRatingConfig {
  final int minAppOpens;
  final int minDaysAfterInstall;
  final int minDaysBetweenReviews;
  final int snoozeDays;
  final String? playStoreLink;
  final String? appStoreLink;

  const AppRatingConfig({
    this.minAppOpens = 5,
    this.minDaysAfterInstall = 3,
    this.minDaysBetweenReviews = 7,
    this.snoozeDays = 2,
    this.playStoreLink,
    this.appStoreLink,
  });
}

/// Daily limit configuration
class DailyLimitConfig {
  final int freeActionsPerDay;
  final String actionKeyPrefix;

  const DailyLimitConfig({
    this.freeActionsPerDay = 3,
    this.actionKeyPrefix = 'daily_action_',
  });
}
