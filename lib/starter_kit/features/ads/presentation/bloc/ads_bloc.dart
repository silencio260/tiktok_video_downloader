import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ad_reward.dart';
import '../../domain/entities/ad_unit.dart';
import '../../domain/usecases/show_interstitial_usecase.dart';
import '../../domain/usecases/show_rewarded_usecase.dart';
import '../../domain/usecases/show_app_open_usecase.dart';
import '../../domain/repositories/ads_repository.dart';
import '../../../analytics/domain/entities/ad_revenue_event.dart';

part 'ads_event.dart';
part 'ads_state.dart';

/// Ads Bloc for managing ad display
class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final AdsRepository adsRepository;
  final ShowInterstitialUseCase showInterstitialUseCase;
  final ShowRewardedUseCase showRewardedUseCase;
  final ShowAppOpenUseCase showAppOpenUseCase;
  final void Function(AdRevenueEvent)? onPaidEvent;

  AdsBloc({
    required this.adsRepository,
    required this.showInterstitialUseCase,
    required this.showRewardedUseCase,
    required this.showAppOpenUseCase,
    this.onPaidEvent,
  }) : super(const AdsInitial()) {
    on<AdsInitialize>(_onInitialize);
    on<AdsLoadInterstitial>(_onLoadInterstitial);
    on<AdsShowInterstitial>(_onShowInterstitial);
    on<AdsLoadRewarded>(_onLoadRewarded);
    on<AdsShowRewarded>(_onShowRewarded);
    on<AdsLoadAppOpen>(_onLoadAppOpen);
    on<AdsShowAppOpen>(_onShowAppOpen);
    on<AdsLoadNative>(_onLoadNative);
  }

  Future<void> _onInitialize(
    AdsInitialize event,
    Emitter<AdsState> emit,
  ) async {
    emit(const AdsLoading());
    final result = await adsRepository.initialize(event.config);
    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (_) => emit(const AdsInitialized()),
    );
  }

  Future<void> _onLoadInterstitial(
    AdsLoadInterstitial event,
    Emitter<AdsState> emit,
  ) async {
    final result = await adsRepository.loadInterstitial(event.adUnitId);
    result.fold((failure) => emit(AdsError(message: failure.message)), (
      _,
    ) async {
      final ready = await _checkReadyStatus();
      emit(ready);
    });
  }

  Future<void> _onShowInterstitial(
    AdsShowInterstitial event,
    Emitter<AdsState> emit,
  ) async {
    final result = await showInterstitialUseCase();
    result.fold((failure) => emit(AdsError(message: failure.message)), (shown) {
      if (shown) {
        emit(const AdsShowSuccess(type: AdType.interstitial));
      }
    });
  }

  Future<void> _onLoadRewarded(
    AdsLoadRewarded event,
    Emitter<AdsState> emit,
  ) async {
    final result = await adsRepository.loadRewarded(event.adUnitId);
    result.fold((failure) => emit(AdsError(message: failure.message)), (
      _,
    ) async {
      final ready = await _checkReadyStatus();
      emit(ready);
    });
  }

  Future<void> _onShowRewarded(
    AdsShowRewarded event,
    Emitter<AdsState> emit,
  ) async {
    final result = await showRewardedUseCase();
    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (reward) => emit(AdsShowSuccess(type: AdType.rewarded, reward: reward)),
    );
  }

  Future<void> _onLoadAppOpen(
    AdsLoadAppOpen event,
    Emitter<AdsState> emit,
  ) async {
    final result = await adsRepository.loadAppOpen(event.adUnitId);
    result.fold((failure) => emit(AdsError(message: failure.message)), (
      _,
    ) async {
      final ready = await _checkReadyStatus();
      emit(ready);
    });
  }

  Future<void> _onShowAppOpen(
    AdsShowAppOpen event,
    Emitter<AdsState> emit,
  ) async {
    final result = await showAppOpenUseCase();
    result.fold((failure) => emit(AdsError(message: failure.message)), (shown) {
      if (shown) {
        emit(const AdsShowSuccess(type: AdType.appOpen));
      }
    });
  }

  Future<void> _onLoadNative(
    AdsLoadNative event,
    Emitter<AdsState> emit,
  ) async {
    final result = await adsRepository.loadNative(event.adUnitId);
    result.fold((failure) => emit(AdsError(message: failure.message)), (
      _,
    ) async {
      final ready = await _checkReadyStatus();
      emit(ready);
    });
  }

  Future<AdsReady> _checkReadyStatus() async {
    final interstitial = await adsRepository.isInterstitialReady();
    final rewarded = await adsRepository.isRewardedReady();
    final appOpen = await adsRepository.isAppOpenReady();
    final native = await adsRepository.isNativeReady();

    return AdsReady(
      isInterstitialReady: interstitial.getOrElse(() => false),
      isRewardedReady: rewarded.getOrElse(() => false),
      isAppOpenReady: appOpen.getOrElse(() => false),
      isNativeReady: native.getOrElse(() => false),
    );
  }
}
