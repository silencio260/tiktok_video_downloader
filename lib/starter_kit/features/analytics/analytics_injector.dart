import 'package:get_it/get_it.dart';

import 'data/datasources/analytics_remote_data_source.dart';
import 'data/datasources/firebase_analytics_data_source.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/usecases/log_event_usecase.dart';
import 'presentation/bloc/analytics_bloc.dart';

void initAnalyticsFeature(
  GetIt sl, {
  List<AnalyticsRemoteDataSource>? customDataSources,
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

  // Bloc
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(repository: sl(), logEventUseCase: sl()),
  );
}
