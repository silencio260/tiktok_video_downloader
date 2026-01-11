import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/ad_reward.dart';
import '../../domain/entities/ad_unit.dart';
import '../../domain/repositories/ads_repository.dart';
import '../datasources/ads_remote_data_source.dart';

/// Implementation of AdsRepository using the injected data source
class AdsRepositoryImpl implements AdsRepository {
  final AdsRemoteDataSource remoteDataSource;

  AdsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> initialize(AdsConfig config) async {
    try {
      await remoteDataSource.initialize(config);
      return const Right(null);
    } on ConfigurationException catch (e) {
      return Left(ConfigurationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdUnit>> loadBanner(String adUnitId) async {
    try {
      final adUnit = await remoteDataSource.loadBanner(adUnitId);
      return Right(adUnit);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdUnit>> loadInterstitial(String adUnitId) async {
    try {
      final adUnit = await remoteDataSource.loadInterstitial(adUnitId);
      return Right(adUnit);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> showInterstitial() async {
    try {
      final result = await remoteDataSource.showInterstitial();
      return Right(result);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdUnit>> loadRewarded(String adUnitId) async {
    try {
      final adUnit = await remoteDataSource.loadRewarded(adUnitId);
      return Right(adUnit);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdReward>> showRewarded() async {
    try {
      final reward = await remoteDataSource.showRewarded();
      return Right(reward);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInterstitialReady() async {
    try {
      final ready = await remoteDataSource.isInterstitialReady();
      return Right(ready);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isRewardedReady() async {
    try {
      final ready = await remoteDataSource.isRewardedReady();
      return Right(ready);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdUnit>> loadAppOpen(String adUnitId) async {
    try {
      final adUnit = await remoteDataSource.loadAppOpen(adUnitId);
      return Right(adUnit);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> showAppOpen() async {
    try {
      final result = await remoteDataSource.showAppOpen();
      return Right(result);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAppOpenReady() async {
    try {
      final ready = await remoteDataSource.isAppOpenReady();
      return Right(ready);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdUnit>> loadNative(String adUnitId) async {
    try {
      final adUnit = await remoteDataSource.loadNative(adUnitId);
      return Right(adUnit);
    } on AdException catch (e) {
      return Left(AdFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isNativeReady() async {
    try {
      final ready = await remoteDataSource.isNativeReady();
      return Right(ready);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await remoteDataSource.dispose();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
