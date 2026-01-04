import 'package:equatable/equatable.dart';

/// Base failure class for all StarterKit features
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
    : super(message: message);
}

/// Server-side failures
class ServerFailure extends Failure {
  const ServerFailure({String message = 'Server error occurred'})
    : super(message: message);
}

/// Configuration/setup failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure({String message = 'Feature not configured'})
    : super(message: message);
}

/// Feature not initialized failure
class NotInitializedFailure extends Failure {
  const NotInitializedFailure({String message = 'Feature not initialized'})
    : super(message: message);
}

/// Purchase-related failures
class PurchaseFailure extends Failure {
  const PurchaseFailure({required String message}) : super(message: message);
}

/// Ad-related failures
class AdFailure extends Failure {
  const AdFailure({required String message}) : super(message: message);
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unexpected error occurred'})
    : super(message: message);
}
