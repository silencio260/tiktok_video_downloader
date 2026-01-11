part of 'ads_bloc.dart';

abstract class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object?> get props => [];
}

class AdsInitial extends AdsState {
  const AdsInitial();
}

class AdsLoading extends AdsState {
  const AdsLoading();
}

class AdsInitialized extends AdsState {
  const AdsInitialized();
}

class AdsReady extends AdsState {
  final bool isInterstitialReady;
  final bool isRewardedReady;
  final bool isAppOpenReady;
  final bool isNativeReady;

  const AdsReady({
    this.isInterstitialReady = false,
    this.isRewardedReady = false,
    this.isAppOpenReady = false,
    this.isNativeReady = false,
  });

  @override
  List<Object?> get props => [
        isInterstitialReady,
        isRewardedReady,
        isAppOpenReady,
        isNativeReady,
      ];
}

class AdsShowSuccess extends AdsState {
  final AdType type;
  final AdReward? reward;

  const AdsShowSuccess({required this.type, this.reward});

  @override
  List<Object?> get props => [type, reward];
}

class AdsError extends AdsState {
  final String message;

  const AdsError({required this.message});

  @override
  List<Object?> get props => [message];
}
