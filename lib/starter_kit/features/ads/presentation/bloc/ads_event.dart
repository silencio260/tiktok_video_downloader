part of 'ads_bloc.dart';

abstract class AdsEvent extends Equatable {
  const AdsEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize Ads service
class AdsInitialize extends AdsEvent {
  final AdsConfig config;

  const AdsInitialize({required this.config});

  @override
  List<Object?> get props => [config.bannerAdUnitId];
}

/// Load an interstitial ad
class AdsLoadInterstitial extends AdsEvent {
  final String adUnitId;

  const AdsLoadInterstitial({required this.adUnitId});

  @override
  List<Object?> get props => [adUnitId];
}

/// Show an interstitial ad
class AdsShowInterstitial extends AdsEvent {
  const AdsShowInterstitial();
}

/// Load a rewarded ad
class AdsLoadRewarded extends AdsEvent {
  final String adUnitId;

  const AdsLoadRewarded({required this.adUnitId});

  @override
  List<Object?> get props => [adUnitId];
}

/// Show a rewarded ad
class AdsShowRewarded extends AdsEvent {
  const AdsShowRewarded();
}
