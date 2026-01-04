/// Result type for error handling
///
/// Provides a type-safe way to handle success/failure without exceptions.
///
/// Usage:
/// ```dart
/// Result<User> result = await fetchUser();
/// result.when(
///   success: (user) => print(user.name),
///   failure: (error) => print(error),
/// );
/// ```

sealed class Result<T> {
  const Result();

  /// Create a successful result
  factory Result.success(T value) = Success<T>;

  /// Create a failure result
  factory Result.failure(String error, [StackTrace? stackTrace]) = Failure<T>;

  /// Pattern matching on result
  R when<R>({
    required R Function(T value) success,
    required R Function(String error, StackTrace? stackTrace) failure,
  });

  /// Check if result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get value or null
  T? get valueOrNull;

  /// Get error or null
  String? get errorOrNull;
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(String error, StackTrace? stackTrace) failure,
  }) {
    return success(value);
  }

  @override
  T? get valueOrNull => value;

  @override
  String? get errorOrNull => null;
}

class Failure<T> extends Result<T> {
  final String error;
  final StackTrace? stackTrace;

  const Failure(this.error, [this.stackTrace]);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(String error, StackTrace? stackTrace) failure,
  }) {
    return failure(error, stackTrace);
  }

  @override
  T? get valueOrNull => null;

  @override
  String? get errorOrNull => error;
}
