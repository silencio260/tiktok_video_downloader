import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/analytics_event.dart';
import '../../domain/entities/ad_revenue_event.dart';
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
  Future<Either<Failure, void>> logAdRevenue(AdRevenueEvent event) async {
    for (final source in _dataSources) {
      await source.logAdRevenue(event);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logRetentionEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    for (final source in _dataSources) {
      await source.logRetentionEvent(eventName, parameters);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logUserSegmentEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    for (final source in _dataSources) {
      await source.logUserSegmentEvent(eventName, parameters);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> logTargetingEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    for (final source in _dataSources) {
      await source.logTargetingEvent(eventName, parameters);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> recordFlutterError(
    dynamic error,
    dynamic stack, {
    bool fatal = false,
  }) async {
    for (final source in _dataSources) {
      await source.recordFlutterError(error, stack, fatal: fatal);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> recordError(
    dynamic error,
    dynamic stack, {
    bool fatal = false,
  }) async {
    for (final source in _dataSources) {
      await source.recordError(error, stack, fatal: fatal);
    }
    return const Right(null);
  }
}
