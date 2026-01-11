import 'package:dartz/dartz';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failure.dart';
import '../../domain/repositories/push_notifications_repository.dart';

/// OneSignal implementation of PushNotificationsRepository
class OneSignalPushNotificationsRepositoryImpl
    implements PushNotificationsRepository {
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize(String appId) async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      OneSignal.initialize(appId);

      // Request permission for notifications
      OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserId(String userId) async {
    try {
      OneSignal.login(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setEmail(String email) async {
    try {
      OneSignal.User.pushSubscription.setEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setExternalUserId(String externalUserId) async {
    try {
      OneSignal.login(externalUserId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTag(String key, String value) async {
    try {
      OneSignal.User.pushSubscription.addTag(key, value);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTags(Map<String, String> tags) async {
    try {
      OneSignal.User.pushSubscription.addTags(tags);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTag(String key) async {
    try {
      OneSignal.User.pushSubscription.removeTag(key);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTags(List<String> keys) async {
    try {
      OneSignal.User.pushSubscription.removeTags(keys);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getPlayerId() async {
    try {
      final subscription = OneSignal.User.pushSubscription;
      final id = subscription.id;
      return Right(id);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enable() async {
    try {
      OneSignal.User.pushSubscription.optIn();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disable() async {
    try {
      OneSignal.User.pushSubscription.optOut();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEnabled() async {
    try {
      final subscription = OneSignal.User.pushSubscription;
      final isOptedIn = subscription.optedIn;
      return Right(isOptedIn ?? false);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
