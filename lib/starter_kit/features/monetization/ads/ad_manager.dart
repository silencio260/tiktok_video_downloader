import '../../../config/starter_kit_config.dart';
import '../../../core/base_feature.dart';
import 'ad_suppression_manager.dart';

/// Ad manager for Google AdMob
///
/// Handles banner, interstitial, and rewarded ads.
/// Respects ad suppression and premium status.
///
/// Usage:
/// ```dart
/// final adManager = AdManager(
///   config: AdMobConfig(
///     bannerAdUnitId: 'ca-app-pub-xxx',
///     interstitialAdUnitId: 'ca-app-pub-xxx',
///   ),
///   isPremium: () => subscriptionManager.isPremium,
/// );
///
/// await adManager.showInterstitial();
/// ```
class AdManager extends BaseFeature {
  final AdMobConfig config;
  final bool Function()? isPremium;
  final AdSuppressionManager _suppression = AdSuppressionManager();

  /// Callback for ad events (for analytics)
  void Function(AdEvent event)? onAdEvent;

  AdManager({required this.config, this.isPremium});

  @override
  Future<void> onInitialize() async {
    // In a real implementation, you'd initialize MobileAds.instance here
    // await MobileAds.instance.initialize();
    print('AdManager: Initialized with config');
  }

  bool _shouldShowAds() {
    if (isPremium?.call() == true) {
      print('AdManager: Skipping ad - user is premium');
      return false;
    }
    if (_suppression.areAdsSuppressed) {
      print('AdManager: Skipping ad - ads suppressed');
      return false;
    }
    return true;
  }

  /// Show an interstitial ad
  /// Returns true if ad was shown, false if skipped
  Future<bool> showInterstitial() async {
    if (!isInitialized || !_shouldShowAds()) return false;
    if (config.interstitialAdUnitId == null) {
      print('AdManager: No interstitial ad unit configured');
      return false;
    }

    try {
      // Placeholder - implement with google_mobile_ads
      print('AdManager: Would show interstitial');
      onAdEvent?.call(AdEvent.interstitialShown);
      return true;
    } catch (e) {
      print('AdManager: Error showing interstitial: $e');
      onAdEvent?.call(AdEvent.interstitialFailed);
      return false;
    }
  }

  /// Show a rewarded ad
  /// Returns true if user completed the reward, false otherwise
  Future<bool> showRewarded({void Function()? onRewarded}) async {
    if (!isInitialized || config.rewardedAdUnitId == null) return false;
    // Premium users can skip ads for rewards
    if (isPremium?.call() == true) {
      onRewarded?.call();
      return true;
    }
    if (_suppression.areAdsSuppressed) return false;

    try {
      // Placeholder - implement with google_mobile_ads
      print('AdManager: Would show rewarded ad');
      onAdEvent?.call(AdEvent.rewardedShown);
      onRewarded?.call();
      return true;
    } catch (e) {
      print('AdManager: Error showing rewarded: $e');
      onAdEvent?.call(AdEvent.rewardedFailed);
      return false;
    }
  }

  /// Get banner ad unit ID (for widget construction)
  String? get bannerAdUnitId => _shouldShowAds() ? config.bannerAdUnitId : null;

  /// Suppress ads temporarily
  void suppressAds(String reason) => _suppression.suppressAds(reason);

  /// Re-enable ads
  void enableAds(String reason) => _suppression.enableAds(reason);

  @override
  Future<void> onDispose() async {
    // Dispose any loaded ads
  }
}

/// Ad event types for analytics
enum AdEvent {
  bannerLoaded,
  bannerFailed,
  interstitialLoaded,
  interstitialShown,
  interstitialFailed,
  rewardedLoaded,
  rewardedShown,
  rewardedCompleted,
  rewardedFailed,
}
