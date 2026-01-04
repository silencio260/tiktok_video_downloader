import '../../domain/entities/ad_reward.dart';
import '../../domain/entities/ad_unit.dart';
import '../../domain/repositories/ads_repository.dart';

/// Abstract data source for Ad operations
///
/// Implement this interface for different ad mediators:
/// - AdMobDataSource
/// - AppLovinMaxDataSource
/// - IronSourceDataSource
abstract class AdsRemoteDataSource {
  /// Initialize the ads SDK
  Future<void> initialize(AdsConfig config);

  /// Load a banner ad
  Future<AdUnit> loadBanner(String adUnitId);

  /// Load an interstitial ad
  Future<AdUnit> loadInterstitial(String adUnitId);

  /// Show an interstitial ad
  Future<bool> showInterstitial();

  /// Load a rewarded ad
  Future<AdUnit> loadRewarded(String adUnitId);

  /// Show a rewarded ad
  Future<AdReward> showRewarded();

  /// Check if interstitial is ready
  Future<bool> isInterstitialReady();

  /// Check if rewarded is ready
  Future<bool> isRewardedReady();

  /// Dispose all ads
  Future<void> dispose();
}
