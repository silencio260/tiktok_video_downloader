/// Starter Kit Plugin
///
/// A reusable, clean-architecture plugin system for Flutter apps.
///
/// All features are lazy-initialized and null-safe. Nothing auto-initializes.
/// API keys and configuration are injected from the root project.
///
/// ## Quick Start
///
/// ```dart
/// // In main.dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize only the features you need
///   await StarterKit.initAnalytics(providers: [FirebaseAnalyticsProvider()]);
///   await StarterKit.initMonetization(
///     checkSubscription: () => RevenueCatService.checkSubscriptionStatus(),
///   );
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// // Features are nullable - safe to call even if not initialized
/// StarterKit.analytics?.logEvent('button_clicked');
///
/// // Check if user is premium
/// if (StarterKit.monetization?.isPremium ?? false) {
///   // Show premium content
/// }
/// ```
library starter_kit;

import 'config/starter_kit_config.dart';
import 'features/analytics/analytics_feature.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/monetization/monetization_feature.dart';
import 'features/services/app_rating_service.dart';
import 'features/services/remote_config_service.dart';
import 'features/services/gdpr_consent_service.dart';
import 'features/services/feedback_service.dart';
import 'features/utils/dev_mode_utils.dart';
import 'features/utils/device_identifier.dart';
import 'features/utils/permission_helper.dart';

// Export all public classes
export 'config/starter_kit_config.dart';
export 'core/base_feature.dart';
export 'core/result.dart';
export 'di/service_locator.dart';

export 'features/analytics/analytics_feature.dart';
export 'features/analytics/providers/analytics_provider.dart';
export 'features/analytics/providers/firebase_analytics_provider.dart';
export 'features/analytics/providers/posthog_provider.dart';

export 'features/monetization/monetization_feature.dart';
export 'features/monetization/subscription_manager.dart';
export 'features/monetization/daily_limit_manager.dart';
export 'features/monetization/ads/ad_manager.dart';
export 'features/monetization/ads/ad_suppression_manager.dart';

export 'features/services/app_rating_service.dart';
export 'features/services/remote_config_service.dart';
export 'features/services/gdpr_consent_service.dart';
export 'features/services/feedback_service.dart';

export 'features/utils/dev_mode_utils.dart';
export 'features/utils/device_identifier.dart';
export 'features/utils/permission_helper.dart';

/// Main facade for the Starter Kit plugin system
///
/// All features are lazily initialized and remain null until explicitly
/// initialized. This allows you to use only the features you need.
///
/// Example:
/// ```dart
/// // Initialize analytics
/// await StarterKit.initAnalytics(providers: [FirebaseAnalyticsProvider()]);
///
/// // Use analytics (null-safe)
/// StarterKit.analytics?.logEvent('test');
///
/// // Or check before using
/// if (StarterKit.analytics != null) {
///   await StarterKit.analytics!.trackAppOpen();
/// }
/// ```
class StarterKit {
  StarterKit._(); // Prevent instantiation

  // ============== FEATURE INSTANCES ==============

  static AnalyticsFeature? _analytics;
  static MonetizationFeature? _monetization;
  static AppRatingService? _rating;
  static RemoteConfigService? _remoteConfig;
  static GdprConsentService? _gdpr;
  static FeedbackService? _feedback;

  // ============== FEATURE GETTERS ==============

  /// Analytics feature (null if not initialized)
  static AnalyticsFeature? get analytics => _analytics;

  /// Monetization feature (null if not initialized)
  static MonetizationFeature? get monetization => _monetization;

  /// App rating service (null if not initialized)
  static AppRatingService? get rating => _rating;

  /// Remote config service (null if not initialized)
  static RemoteConfigService? get remoteConfig => _remoteConfig;

  /// GDPR consent service (null if not initialized)
  static GdprConsentService? get gdpr => _gdpr;

  /// Feedback service (null if not initialized)
  static FeedbackService? get feedback => _feedback;

  // ============== UTILITY GETTERS ==============

  /// Development mode utilities (always available)
  static DevModeUtils get devMode => DevModeUtils();

  /// Device identifier utility
  static Future<String> getDeviceId() => DeviceIdentifier.getDeviceIdentifier();

  /// Permission helper (always available)
  static PermissionHelper get permissions => PermissionHelper();

  /// Check if running in debug mode
  static bool get isDebugMode => DevModeUtils.isDebugMode;

  // ============== INITIALIZATION ==============

  /// Initialize analytics with providers
  static Future<void> initAnalytics({
    required List<AnalyticsProvider> providers,
  }) async {
    _analytics = AnalyticsFeature();
    _analytics!.addProviders(providers);
    await _analytics!.initialize();
  }

  /// Initialize monetization
  static Future<void> initMonetization({
    String? revenueCatApiKey,
    AdMobConfig? adMobConfig,
    DailyLimitConfig? dailyLimitConfig,
    Future<bool> Function()? checkSubscription,
  }) async {
    _monetization = MonetizationFeature(
      revenueCatApiKey: revenueCatApiKey,
      adMobConfig: adMobConfig,
      dailyLimitConfig: dailyLimitConfig,
      checkSubscription: checkSubscription,
      developmentMode: DevModeUtils.isDebugMode,
    );
    await _monetization!.initialize();
  }

  /// Initialize app rating service
  static Future<void> initRating({AppRatingConfig? config}) async {
    _rating = AppRatingService(config: config);
    await _rating!.initialize();
  }

  /// Initialize remote config
  static Future<void> initRemoteConfig({
    Map<String, dynamic>? defaults,
    Future<Map<String, dynamic>> Function()? fetchConfig,
  }) async {
    _remoteConfig = RemoteConfigService(
      defaults: defaults,
      fetchConfig: fetchConfig,
    );
    await _remoteConfig!.initialize();
  }

  /// Initialize GDPR consent service
  static Future<void> initGdpr({
    Future<bool> Function()? showConsentPrompt,
  }) async {
    _gdpr = GdprConsentService();
    _gdpr!.showConsentPrompt = showConsentPrompt;
    await _gdpr!.initialize();
  }

  /// Initialize feedback service
  static Future<void> initFeedback({
    Future<void> Function(FeedbackData data)? submitFeedback,
  }) async {
    _feedback = FeedbackService();
    _feedback!.submitFeedback = submitFeedback;
    await _feedback!.initialize();
  }

  /// Initialize all features at once (convenience method)
  static Future<void> initialize(StarterKitConfig config) async {
    if (config.firebase != null) {
      // Firebase Analytics is typically set up separately
    }

    if (config.adMob != null || config.revenueCat != null) {
      await initMonetization(
        revenueCatApiKey: config.revenueCat?.apiKey,
        adMobConfig: config.adMob,
      );
    }

    if (config.postHog != null) {
      // PostHog can be added to analytics providers
    }
  }

  // ============== DISPOSAL ==============

  /// Dispose all initialized features
  static Future<void> dispose() async {
    await _analytics?.dispose();
    await _monetization?.dispose();
    await _rating?.dispose();
    await _remoteConfig?.dispose();
    await _gdpr?.dispose();
    await _feedback?.dispose();

    _analytics = null;
    _monetization = null;
    _rating = null;
    _remoteConfig = null;
    _gdpr = null;
    _feedback = null;
  }

  // ============== STATUS ==============

  /// Get status of all features
  static Map<String, bool> get featureStatus => {
    'analytics': _analytics?.isInitialized ?? false,
    'monetization': _monetization?.isInitialized ?? false,
    'rating': _rating?.isInitialized ?? false,
    'remoteConfig': _remoteConfig?.isInitialized ?? false,
    'gdpr': _gdpr?.isInitialized ?? false,
    'feedback': _feedback?.isInitialized ?? false,
  };
}
