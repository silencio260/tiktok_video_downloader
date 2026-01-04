import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/entitlement.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/iap_repository.dart';
import '../datasources/iap_remote_data_source.dart';

/// Implementation of IapRepository using the injected data source
class IapRepositoryImpl implements IapRepository {
  final IapRemoteDataSource remoteDataSource;

  IapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> initialize(String apiKey) async {
    try {
      await remoteDataSource.initialize(apiKey);
      return const Right(null);
    } on ConfigurationException catch (e) {
      return Left(ConfigurationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final status = await remoteDataSource.getSubscriptionStatus();
      return Right(status);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } on ConfigurationException catch (e) {
      return Left(ConfigurationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts(
    List<String> productIds,
  ) async {
    try {
      final products = await remoteDataSource.getProducts(productIds);
      return Right(products);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> purchaseProduct(
    String productId,
  ) async {
    try {
      final status = await remoteDataSource.purchaseProduct(productId);
      return Right(status);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> restorePurchases() async {
    try {
      final status = await remoteDataSource.restorePurchases();
      return Right(status);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Entitlement>>> getEntitlements() async {
    try {
      final entitlements = await remoteDataSource.getEntitlements();
      return Right(entitlements);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEntitlementActive(
    String entitlementId,
  ) async {
    try {
      final isActive = await remoteDataSource.isEntitlementActive(
        entitlementId,
      );
      return Right(isActive);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserId(String userId) async {
    try {
      await remoteDataSource.setUserId(userId);
      return const Right(null);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logOut() async {
    try {
      await remoteDataSource.logOut();
      return const Right(null);
    } on PurchaseException catch (e) {
      return Left(PurchaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
