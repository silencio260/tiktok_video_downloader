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
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeAd;
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
      if (config.appOpenAdUnitId != null) {
        await loadAppOpen(config.appOpenAdUnitId!);
      }
      if (config.nativeAdUnitId != null) {
        await loadNative(config.nativeAdUnitId!);
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
  Future<AdUnit> loadAppOpen(String adUnitId) async {
    _ensureInitialized();

    final completer = Completer<AdUnit>();

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
              // Preload next ad
              if (_config?.appOpenAdUnitId != null) {
                loadAppOpen(_config!.appOpenAdUnitId!);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _appOpenAd = null;
            },
          );
          completer.complete(
            AdUnit(id: adUnitId, type: AdType.appOpen, isLoaded: true),
          );
        },
        onAdFailedToLoad: (error) {
          completer.complete(
            AdUnit(
              id: adUnitId,
              type: AdType.appOpen,
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
  Future<bool> showAppOpen() async {
    _ensureInitialized();

    if (_appOpenAd == null) {
      throw const AdException(message: 'App open ad not loaded');
    }

    await _appOpenAd!.show();
    return true;
  }

  @override
  Future<bool> isAppOpenReady() async {
    return _appOpenAd != null;
  }

  @override
  Future<AdUnit> loadNative(String adUnitId) async {
    _ensureInitialized();

    final completer = Completer<AdUnit>();

    // Native ad will be loaded and managed by widgets
    // This method returns a placeholder to indicate the ad unit is ready
    print('---------------> Load Native Ads');
    completer.complete(
      AdUnit(id: adUnitId, type: AdType.native, isLoaded: true),
    );

    return completer.future;
  }

  @override
  Future<bool> isNativeReady() async {
    // Native ads are always ready as they're loaded by widgets
    return true;
  }

  @override
  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _nativeAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _appOpenAd = null;
    _nativeAd = null;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const ConfigurationException(message: 'AdMob not initialized');
    }
  }
}
