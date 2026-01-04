import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ad_reward.dart';
import '../../domain/entities/ad_unit.dart';
import '../../domain/repositories/ads_repository.dart';
import 'ads_remote_data_source.dart';

/// AdMob implementation of AdsRemoteDataSource
///
/// To switch to AppLovin MAX or another mediator, create a new class
/// that implements AdsRemoteDataSource and register it in the injector.
class AdMobDataSource implements AdsRemoteDataSource {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AdsConfig? _config;
  bool _isInitialized = false;

  Completer<AdReward>? _rewardedCompleter;

  @override
  Future<void> initialize(AdsConfig config) async {
    try {
      _config = config;
      await MobileAds.instance.initialize();

      // Configure test devices
      if (config.testDeviceIds.isNotEmpty) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: config.testDeviceIds),
        );
      }

      _isInitialized = true;

      // Preload ads
      if (config.interstitialAdUnitId != null) {
        await loadInterstitial(config.interstitialAdUnitId!);
      }
      if (config.rewardedAdUnitId != null) {
        await loadRewarded(config.rewardedAdUnitId!);
      }
    } catch (e) {
      throw ConfigurationException(message: 'Failed to initialize AdMob: $e');
    }
  }

  @override
  Future<AdUnit> loadBanner(String adUnitId) async {
    _ensureInitialized();
    // Banner loading is handled by the widget
    return AdUnit(id: adUnitId, type: AdType.banner, isLoaded: true);
  }

  @override
  Future<AdUnit> loadInterstitial(String adUnitId) async {
    _ensureInitialized();

    final completer = Completer<AdUnit>();

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              // Preload next ad
              if (_config?.interstitialAdUnitId != null) {
                loadInterstitial(_config!.interstitialAdUnitId!);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
          completer.complete(
            AdUnit(id: adUnitId, type: AdType.interstitial, isLoaded: true),
          );
        },
        onAdFailedToLoad: (error) {
          completer.complete(
            AdUnit(
              id: adUnitId,
              type: AdType.interstitial,
              isLoaded: false,
              isFailed: true,
            ),
          );
        },
      ),
    );

    return completer.future;
  }

  @override
  Future<bool> showInterstitial() async {
    _ensureInitialized();

    if (_interstitialAd == null) {
      throw const AdException(message: 'Interstitial ad not loaded');
    }

    await _interstitialAd!.show();
    return true;
  }

  @override
  Future<AdUnit> loadRewarded(String adUnitId) async {
    _ensureInitialized();

    final completer = Completer<AdUnit>();

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              // Preload next ad
              if (_config?.rewardedAdUnitId != null) {
                loadRewarded(_config!.rewardedAdUnitId!);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _rewardedCompleter?.completeError(
                AdException(message: 'Failed to show rewarded ad: $error'),
              );
            },
          );
          completer.complete(
            AdUnit(id: adUnitId, type: AdType.rewarded, isLoaded: true),
          );
        },
        onAdFailedToLoad: (error) {
          completer.complete(
            AdUnit(
              id: adUnitId,
              type: AdType.rewarded,
              isLoaded: false,
              isFailed: true,
            ),
          );
        },
      ),
    );

    return completer.future;
  }

  @override
  Future<AdReward> showRewarded() async {
    _ensureInitialized();

    if (_rewardedAd == null) {
      throw const AdException(message: 'Rewarded ad not loaded');
    }

    _rewardedCompleter = Completer<AdReward>();

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _rewardedCompleter?.complete(
          AdReward(type: reward.type, amount: reward.amount.toInt()),
        );
      },
    );

    return _rewardedCompleter!.future;
  }

  @override
  Future<bool> isInterstitialReady() async {
    return _interstitialAd != null;
  }

  @override
  Future<bool> isRewardedReady() async {
    return _rewardedAd != null;
  }

  @override
  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const ConfigurationException(message: 'AdMob not initialized');
    }
  }
}
