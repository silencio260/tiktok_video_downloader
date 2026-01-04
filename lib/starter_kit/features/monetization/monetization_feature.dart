import '../../config/starter_kit_config.dart';
import '../../core/base_feature.dart';
import 'subscription_manager.dart';
import 'daily_limit_manager.dart';
import 'ads/ad_manager.dart';
import 'ads/ad_suppression_manager.dart';

/// Monetization feature facade
///
/// Provides unified access to subscriptions, ads, and limits.
///
/// Usage:
/// ```dart
/// final monetization = MonetizationFeature(
///   revenueCatApiKey: 'your_api_key',
///   adMobConfig: AdMobConfig(...),
/// );
/// await monetization.initialize();
///
/// if (monetization.isPremium) {
///   // Show premium content
/// }
/// ```
class MonetizationFeature extends BaseFeature {
  final String? revenueCatApiKey;
  final AdMobConfig? adMobConfig;
  final DailyLimitConfig? dailyLimitConfig;
  final bool developmentMode;

  /// Inject your RevenueCat check function
  final Future<bool> Function()? checkSubscription;

  SubscriptionManager? _subscriptionManager;
  AdManager? _adManager;
  DailyLimitManager? _dailyLimitManager;

  MonetizationFeature({
    this.revenueCatApiKey,
    this.adMobConfig,
    this.dailyLimitConfig,
    this.checkSubscription,
    this.developmentMode = false,
  });

  /// Subscription manager (null if not configured)
  SubscriptionManager? get subscriptions => _subscriptionManager;

  /// Ad manager (null if not configured)
  AdManager? get ads => _adManager;

  /// Daily limit manager (null if not configured)
  DailyLimitManager? get limits => _dailyLimitManager;

  /// Ad suppression manager (always available)
  AdSuppressionManager get adSuppression => AdSuppressionManager();

  /// Quick check: is user premium?
  bool get isPremium => _subscriptionManager?.isPremium ?? false;

  @override
  Future<void> onInitialize() async {
    // Initialize subscription manager
    if (revenueCatApiKey != null || checkSubscription != null) {
      _subscriptionManager = SubscriptionManager(
        checkSubscription: checkSubscription,
        developmentMode: developmentMode,
      );
      await _subscriptionManager!.initialize();
    }

    // Initialize ad manager
    if (adMobConfig != null) {
      _adManager = AdManager(config: adMobConfig!, isPremium: () => isPremium);
      await _adManager!.initialize();
    }

    // Initialize daily limit manager
    if (dailyLimitConfig != null) {
      _dailyLimitManager = DailyLimitManager(config: dailyLimitConfig);
      await _dailyLimitManager!.initialize();
    }
  }

  /// Show an interstitial ad (respects premium status)
  Future<bool> showInterstitial() async {
    return await _adManager?.showInterstitial() ?? false;
  }

  /// Show a rewarded ad
  Future<bool> showRewarded({void Function()? onRewarded}) async {
    return await _adManager?.showRewarded(onRewarded: onRewarded) ?? false;
  }

  /// Check if free action is available
  Future<bool> canPerformFreeAction() async {
    if (isPremium) return true; // Premium users have no limits
    return await _dailyLimitManager?.canPerformAction() ?? true;
  }

  /// Record a free action
  Future<bool> recordFreeAction() async {
    if (isPremium) return true;
    return await _dailyLimitManager?.tryRecordAction() ?? true;
  }

  /// Refresh subscription status
  Future<void> refreshSubscription() async {
    await _subscriptionManager?.refresh();
  }

  @override
  Future<void> onDispose() async {
    await _subscriptionManager?.dispose();
    await _adManager?.dispose();
    await _dailyLimitManager?.dispose();
  }
}
