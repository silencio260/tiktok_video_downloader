import 'package:get_it/get_it.dart';

import 'data/datasources/analytics_remote_data_source.dart';
import 'data/datasources/firebase_analytics_data_source.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/usecases/log_event_usecase.dart';
import 'domain/usecases/log_ad_revenue_usecase.dart';
import 'presentation/bloc/analytics_bloc.dart';

import 'data/datasources/posthog_remote_data_source.dart';

void initAnalyticsFeature(
  GetIt sl, {
  List<AnalyticsRemoteDataSource>? customDataSources,
  PostHogRemoteDataSource? postHogRemoteDataSource,
}) {
  // Data Sources
  final sources = customDataSources ?? [FirebaseAnalyticsDataSource()];

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(dataSources: sources),
  );

  // Use Cases
  sl.registerLazySingleton<LogEventUseCase>(
    () => LogEventUseCase(repository: sl()),
  );
  sl.registerLazySingleton<LogAdRevenueUseCase>(
    () => LogAdRevenueUseCase(repository: sl()),
  );

  // Bloc
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(
      repository: sl(),
      logEventUseCase: sl(),
      logAdRevenueUseCase: sl(),
    ),
  );

  // PostHog (Standalone)
  if (postHogRemoteDataSource != null) {
    sl.registerLazySingleton<PostHogRemoteDataSource>(
      () => postHogRemoteDataSource,
    );
  } else {
    sl.registerLazySingleton<PostHogRemoteDataSource>(
      () => PostHogRemoteDataSourceImpl(),
    );
  }
}
