import 'package:dartz/dartz.dart';
import 'package:tiktok_video_downloader/starter_kit/core/error/failure.dart';

/// Repository for fetching remote configuration values
abstract class RemoteConfigRepository {
  /// Fetch and activate the latest values
  Future<Either<Failure, void>> fetchAndActivate();

  /// Get a string value
  String getString(String key);

  /// Get a boolean value
  bool getBool(String key);

  /// Get an integer value
  int getInt(String key);

  /// Get a double value
  double getDouble(String key);
}
