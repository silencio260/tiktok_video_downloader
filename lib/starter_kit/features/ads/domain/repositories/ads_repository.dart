import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/ad_reward.dart';
import '../entities/ad_unit.dart';

/// Configuration for the ads service
class AdsConfig {
  final String? bannerAdUnitId;
  final String? interstitialAdUnitId;
  final String? rewardedAdUnitId;
  final String? nativeAdUnitId;
  final String? appOpenAdUnitId;
  final List<String> testDeviceIds;

  const AdsConfig({
    this.bannerAdUnitId,
    this.interstitialAdUnitId,
    this.rewardedAdUnitId,
    this.nativeAdUnitId,
    this.appOpenAdUnitId,
    this.testDeviceIds = const [],
  });

  /// Factory for development with test IDs
  factory AdsConfig.test() => const AdsConfig();
}

/// Abstract repository for Ad operations
///
/// Implement this with different ad mediators:
/// - AdMobRepository
/// - AppLovinRepository (MAX)
/// - IronSourceRepository
/// - UnityAdsRepository
abstract class AdsRepository {
  /// Initialize the ads SDK
  Future<Either<Failure, void>> initialize(AdsConfig config);

  /// Load a banner ad
  Future<Either<Failure, AdUnit>> loadBanner(String adUnitId);

  /// Load an interstitial ad
  Future<Either<Failure, AdUnit>> loadInterstitial(String adUnitId);

  /// Show an interstitial ad
  Future<Either<Failure, bool>> showInterstitial();

  /// Load a rewarded ad
  Future<Either<Failure, AdUnit>> loadRewarded(String adUnitId);

  /// Show a rewarded ad and return the reward
  Future<Either<Failure, AdReward>> showRewarded();

  /// Check if interstitial is ready
  Future<Either<Failure, bool>> isInterstitialReady();

  /// Check if rewarded is ready
  Future<Either<Failure, bool>> isRewardedReady();

  /// Load an app open ad
  Future<Either<Failure, AdUnit>> loadAppOpen(String adUnitId);

  /// Show an app open ad
  Future<Either<Failure, bool>> showAppOpen();

  /// Check if app open ad is ready
  Future<Either<Failure, bool>> isAppOpenReady();

  /// Load a native ad
  Future<Either<Failure, AdUnit>> loadNative(String adUnitId);

  /// Check if native ad is ready
  Future<Either<Failure, bool>> isNativeReady();

  /// Dispose all ads
  Future<Either<Failure, void>> dispose();
}
