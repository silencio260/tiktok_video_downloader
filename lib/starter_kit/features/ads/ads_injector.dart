import 'package:get_it/get_it.dart';

import 'data/datasources/admob_data_source.dart';
import 'data/datasources/ads_remote_data_source.dart';
import 'data/repositories/ads_repository_impl.dart';
import 'domain/repositories/ads_repository.dart';
import 'domain/usecases/show_interstitial_usecase.dart';
import 'domain/usecases/show_rewarded_usecase.dart';
import 'domain/usecases/show_app_open_usecase.dart';
import 'presentation/bloc/ads_bloc.dart';

import '../analytics/domain/entities/ad_revenue_event.dart';

/// Initialize Ads feature dependencies
///
/// To use a different Ads provider, replace AdMobDataSource with your implementation
void initAdsFeature(
  GetIt sl, {
  AdsRemoteDataSource? customDataSource,
  void Function(AdRevenueEvent)? onPaidEvent,
}) {
  // Data source - use custom or default to AdMob
  if (customDataSource != null) {
    sl.registerLazySingleton<AdsRemoteDataSource>(() => customDataSource);
  } else {
    sl.registerLazySingleton<AdsRemoteDataSource>(() => AdMobDataSource());
  }

  // Repository
  sl.registerLazySingleton<AdsRepository>(
    () => AdsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton<ShowInterstitialUseCase>(
    () => ShowInterstitialUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ShowRewardedUseCase>(
    () => ShowRewardedUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ShowAppOpenUseCase>(
    () => ShowAppOpenUseCase(repository: sl()),
  );

  // Bloc
  sl.registerLazySingleton<AdsBloc>(
    () => AdsBloc(
      adsRepository: sl(),
      showInterstitialUseCase: sl(),
      showRewardedUseCase: sl(),
      showAppOpenUseCase: sl(),
      onPaidEvent: onPaidEvent,
    ),
  );
}
