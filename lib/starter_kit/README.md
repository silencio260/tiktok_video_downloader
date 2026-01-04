# Starter Kit Plugin

A reusable, clean-architecture plugin system for Flutter apps. Copy-paste ready into any project.

## Features

| Module | Features |
|--------|----------|
| **Analytics** | Firebase Analytics, PostHog, Retention tracking (D1-D30) |
| **Monetization** | Subscriptions (RevenueCat), AdMob (Banner/Interstitial/Rewarded), Daily limits, Ad suppression |
| **Services** | App rating, Remote config, GDPR consent, Feedback collection |
| **Utils** | Dev mode detection, Device ID, Permissions |

---

## Quick Start

```dart
import 'package:your_app/starter_kit/starter_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only what you need
  await StarterKit.initAnalytics(
    providers: [FirebaseAnalyticsProvider()],
  );

  await StarterKit.initMonetization(
    checkSubscription: () => RevenueCatService.checkSubscriptionStatus(),
    adMobConfig: AdMobConfig(
      bannerAdUnitId: 'ca-app-pub-xxx',
      interstitialAdUnitId: 'ca-app-pub-xxx',
    ),
  );

  runApp(MyApp());
}
```

---

## Null-Safety Pattern

All features are **lazily initialized** and remain `null` until explicitly initialized:

```dart
// Safe to call even if not initialized - returns null
StarterKit.analytics?.logEvent('test');

// Check before using
if (StarterKit.monetization?.isPremium ?? false) {
  // Premium content
}

// Or use null assertion if you're sure it's initialized
await StarterKit.analytics!.trackAppOpen();
```

---

## API Reference

### StarterKit (Main Facade)

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `analytics` | `AnalyticsFeature?` | Analytics feature instance |
| `monetization` | `MonetizationFeature?` | Monetization feature instance |
| `rating` | `AppRatingService?` | App rating service |
| `remoteConfig` | `RemoteConfigService?` | Remote config service |
| `gdpr` | `GdprConsentService?` | GDPR consent handler |
| `feedback` | `FeedbackService?` | Feedback service |
| `isDebugMode` | `bool` | Check if running in debug mode |
| `getDeviceId()` | `Future<String>` | Get unique device identifier |
| `featureStatus` | `Map<String, bool>` | Status of all features |

---

## Analytics Module

### Initialization

```dart
await StarterKit.initAnalytics(
  providers: [
    FirebaseAnalyticsProvider(
      enableAnalytics: true,
      enableCrashlytics: true,
    ),
    PostHogProvider(
      apiKey: 'your_posthog_key',
    ),
  ],
);
```

### AnalyticsFeature

| Method | Parameters | Description |
|--------|------------|-------------|
| `logEvent()` | `String name, [Map<String, dynamic>? params]` | Log custom event |
| `logScreenView()` | `String screenName, [String? screenClass]` | Log screen view |
| `setUserId()` | `String? userId` | Set user ID |
| `setUserProperty()` | `String name, String? value` | Set user property |
| `trackAppOpen()` | - | Track app open + retention |

### RetentionTracker

| Method | Returns | Description |
|--------|---------|-------------|
| `trackAppOpen()` | `Future<void>` | Track app open |
| `getTotalAppOpens()` | `int` | Total app opens |
| `getDaysSinceInstall()` | `int` | Days since first install |
| `hasReturnedOnDay(int)` | `bool` | Check if user returned on specific day |
| `getD7RetentionRate()` | `double` | D7 retention percentage |
| `getEngagementMetrics()` | `Map<String, dynamic>` | Full engagement snapshot |

---

## Monetization Module

### Initialization

```dart
await StarterKit.initMonetization(
  // Inject your RevenueCat check
  checkSubscription: () => RevenueCatService.checkSubscriptionStatus(),
  
  // AdMob configuration
  adMobConfig: AdMobConfig(
    bannerAdUnitId: 'ca-app-pub-xxx',
    interstitialAdUnitId: 'ca-app-pub-xxx',
    rewardedAdUnitId: 'ca-app-pub-xxx',
    testDeviceIds: ['your_test_device_id'],
  ),
  
  // Daily limits for freemium
  dailyLimitConfig: DailyLimitConfig(
    freeActionsPerDay: 5,
  ),
);
```

### MonetizationFeature

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `isPremium` | `bool` | Is user premium? |
| `subscriptions` | `SubscriptionManager?` | Subscription manager |
| `ads` | `AdManager?` | Ad manager |
| `limits` | `DailyLimitManager?` | Daily limit manager |
| `showInterstitial()` | `Future<bool>` | Show interstitial ad |
| `showRewarded()` | `Future<bool>` | Show rewarded ad |
| `canPerformFreeAction()` | `Future<bool>` | Check if free action available |
| `recordFreeAction()` | `Future<bool>` | Record a free action |
| `refreshSubscription()` | `Future<void>` | Refresh subscription status |

### SubscriptionManager

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `isPremium` | `bool` | Premium status |
| `state` | `SubscriptionState` | Immutable state for Bloc |
| `checkSubscriptionStatus()` | `Future<void>` | Check with IAP provider |
| `refresh()` | `Future<void>` | Force refresh |
| `setDebugPremium(bool)` | `Future<void>` | Toggle debug premium (dev only) |

### DailyLimitManager

| Method | Returns | Description |
|--------|---------|-------------|
| `canPerformAction()` | `Future<bool>` | Check if action allowed |
| `recordAction()` | `Future<void>` | Increment counter |
| `tryRecordAction()` | `Future<bool>` | Check and record in one call |
| `getRemainingActions()` | `Future<int>` | Remaining actions today |
| `resetToday()` | `Future<void>` | Reset counter (testing) |

### AdSuppressionManager

| Method | Parameters | Description |
|--------|------------|-------------|
| `suppressAds()` | `String reason` | Suppress ads |
| `enableAds()` | `String reason` | Re-enable ads |
| `withAdsSuppressed()` | `String reason, Future Function() action` | Execute with ads suppressed |
| `areAdsSuppressed` | - | Check if suppressed |

---

## Services Module

### AppRatingService

```dart
await StarterKit.initRating(
  config: AppRatingConfig(
    minAppOpens: 5,
    minDaysAfterInstall: 3,
    minDaysBetweenReviews: 7,
    playStoreLink: 'https://play.google.com/...',
  ),
);

// Track successful action (shows rating after 2)
await StarterKit.rating?.trackSuccessfulAction(context);

// Or manually show if eligible
await StarterKit.rating?.showRatingIfEligible(context);
```

### RemoteConfigService

```dart
await StarterKit.initRemoteConfig(
  defaults: {'feature_enabled': false, 'daily_limit': 3},
  fetchConfig: () => FirebaseRemoteConfig.instance.getAll(),
);

final enabled = StarterKit.remoteConfig?.getBool('feature_enabled');
final limit = StarterKit.remoteConfig?.getInt('daily_limit', defaultValue: 3);
```

### GdprConsentService

```dart
await StarterKit.initGdpr(
  showConsentPrompt: () => showMyConsentDialog(),
);

if (!(StarterKit.gdpr?.hasConsent ?? false)) {
  await StarterKit.gdpr?.requestConsent();
}
```

### FeedbackService

```dart
await StarterKit.initFeedback(
  submitFeedback: (data) => sendToBackend(data.toJson()),
);

// Show feedback form (e.g., after low rating)
await StarterKit.feedback?.showFeedbackForm(context);
```

---

## Utils Module

### DevModeUtils

| Property | Type | Description |
|----------|------|-------------|
| `isDebugMode` | `bool` | Running in debug? |
| `isFoundersVersion` | `bool` | `--dart-define=founders_version=true` |
| `isStaging` | `bool` | `--dart-define=staging=true` |
| `environmentName` | `String` | 'debug', 'staging', 'founders', or 'production' |

### DeviceIdentifier

```dart
final deviceId = await DeviceIdentifier.getDeviceIdentifier();
final info = await DeviceIdentifier.getDeviceInfo();
```

### PermissionHelper

```dart
final granted = await PermissionHelper.requestStorage();
await PermissionHelper.openSettings();
```

---

## Bloc Integration

All stateful features expose immutable state classes for Bloc integration:

```dart
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState());

  Future<void> init() async {
    final manager = StarterKit.monetization?.subscriptions;
    manager?.onStateChanged = (state) => emit(state);
    await manager?.initialize();
  }
}
```

---

## Configuration Classes

### StarterKitConfig

```dart
StarterKitConfig(
  firebase: FirebaseConfig(
    enableAnalytics: true,
    enableCrashlytics: true,
  ),
  adMob: AdMobConfig(
    bannerAdUnitId: 'xxx',
    interstitialAdUnitId: 'xxx',
    rewardedAdUnitId: 'xxx',
  ),
  revenueCat: RevenueCatConfig(
    apiKey: 'xxx',
    entitlementId: 'premium',
  ),
  postHog: PostHogConfig(
    apiKey: 'xxx',
    host: 'https://app.posthog.com',
  ),
  enableDebugMode: false,
)
```

---

## Folder Structure

```
lib/starter_kit/
├── starter_kit.dart           # Main facade + exports
├── README.md                  # This file
├── config/
│   └── starter_kit_config.dart
├── core/
│   ├── base_feature.dart
│   └── result.dart
├── di/
│   └── service_locator.dart
└── features/
    ├── analytics/
    │   ├── analytics_feature.dart
    │   └── providers/
    ├── monetization/
    │   ├── monetization_feature.dart
    │   ├── subscription_manager.dart
    │   ├── daily_limit_manager.dart
    │   └── ads/
    ├── services/
    │   ├── app_rating_service.dart
    │   ├── remote_config_service.dart
    │   ├── gdpr_consent_service.dart
    │   └── feedback_service.dart
    └── utils/
        ├── dev_mode_utils.dart
        ├── device_identifier.dart
        └── permission_helper.dart
```

---

## Required Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # Analytics
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0
  posthog_flutter: ^5.0.0

  # Monetization
  google_mobile_ads: ^6.0.0
  purchases_flutter: ^9.0.0

  # Services
  in_app_review: ^2.0.0
  firebase_remote_config: ^5.0.0

  # Utils
  shared_preferences: ^2.0.0
  device_info_plus: ^11.0.0
  permission_handler: ^11.0.0
  url_launcher: ^6.0.0
  uuid: ^3.0.0
```

---

## Copy-Paste Checklist

1. ✅ Copy `lib/starter_kit/` folder to your project
2. ✅ Add required dependencies to `pubspec.yaml`
3. ✅ Initialize Firebase in `main.dart` before StarterKit
4. ✅ Call `StarterKit.init*()` for features you need
5. ✅ Use null-safe access pattern: `StarterKit.feature?.method()`
