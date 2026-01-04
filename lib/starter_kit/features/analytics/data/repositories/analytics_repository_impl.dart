import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/analytics_event.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

/// Analytics repository that can aggregate multiple providers
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final List<AnalyticsRemoteDataSource> _dataSources;

  AnalyticsRepositoryImpl({
    required List<AnalyticsRemoteDataSource> dataSources,
  }) : _dataSources = dataSources;

  @override
  Future<Either<Failure, void>> initialize() async {
    for (final source in _dataSources) {
      await source.initialize();
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logEvent(AnalyticsEvent event) async {
    for (final source in _dataSources) {
      await source.logEvent(event);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setUserId(String userId) async {
    for (final source in _dataSources) {
      await source.setUserId(userId);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setUserProperty(
    String name,
    String value,
  ) async {
    for (final source in _dataSources) {
      await source.setUserProperty(name, value);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logScreenView(String screenName) async {
    for (final source in _dataSources) {
      await source.logScreenView(screenName);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> trackAppOpen() async {
    // This could also interact with a local data source for retention tracking
    await logEvent(const AnalyticsEvent(name: 'app_open'));
    return const Right(null);
  }
}
