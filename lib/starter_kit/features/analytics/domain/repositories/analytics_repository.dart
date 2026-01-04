import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/analytics_event.dart';

/// Abstract repository for analytics operations
abstract class AnalyticsRepository {
  /// Initialize analytics services
  Future<Either<Failure, void>> initialize();

  /// Log a custom event
  Future<Either<Failure, void>> logEvent(AnalyticsEvent event);

  /// Set user ID
  Future<Either<Failure, void>> setUserId(String userId);

  /// Set user property
  Future<Either<Failure, void>> setUserProperty(String name, String value);

  /// Track screen view
  Future<Either<Failure, void>> logScreenView(String screenName);

  /// Track retention (app open)
  Future<Either<Failure, void>> trackAppOpen();
}
