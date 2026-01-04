import 'package:get_it/get_it.dart';
import 'app_rating/data/repositories/app_rating_repository_impl.dart';
import 'app_rating/domain/repositories/app_rating_repository.dart';
import 'feedback/data/repositories/feedback_repository_impl.dart';
import 'feedback/domain/repositories/feedback_repository.dart';
import 'gdpr/data/repositories/gdpr_repository_impl.dart';
import 'gdpr/domain/repositories/gdpr_repository.dart';
import 'remote_config/data/datasources/firebase_remote_config_data_source.dart';
import 'remote_config/data/datasources/remote_config_remote_data_source.dart';
import 'remote_config/data/repositories/remote_config_repository_impl.dart';
import 'remote_config/domain/repositories/remote_config_repository.dart';

/// Initialize Services dependencies
void initServicesFeature(
  GetIt sl, {
  RemoteConfigRemoteDataSource? customRemoteConfigDataSource,
  String supportEmail = 'support@example.com',
}) {
  // --- App Rating ---
  sl.registerLazySingleton<AppRatingRepository>(
    () => AppRatingRepositoryImpl(),
  );

  // --- Remote Config ---
  if (customRemoteConfigDataSource != null) {
    sl.registerLazySingleton<RemoteConfigRemoteDataSource>(
      () => customRemoteConfigDataSource,
    );
  } else {
    sl.registerLazySingleton<RemoteConfigRemoteDataSource>(
      () => FirebaseRemoteConfigDataSource(),
    );
  }
  sl.registerLazySingleton<RemoteConfigRepository>(
    () => RemoteConfigRepositoryImpl(dataSource: sl()),
  );

  // --- GDPR ---
  sl.registerLazySingleton<GdprRepository>(() => GdprRepositoryImpl());

  // --- Feedback ---
  sl.registerLazySingleton<FeedbackRepository>(
    () => EmailFeedbackRepositoryImpl(supportEmail: supportEmail),
  );
}
