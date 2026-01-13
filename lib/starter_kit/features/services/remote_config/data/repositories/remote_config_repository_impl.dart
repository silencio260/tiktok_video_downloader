import 'package:dartz/dartz.dart';

import 'package:tiktok_video_downloader/starter_kit/core/error/failure.dart';
import '../../domain/repositories/remote_config_repository.dart';
import '../datasources/remote_config_remote_data_source.dart';

class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  final RemoteConfigRemoteDataSource dataSource;

  RemoteConfigRepositoryImpl({required this.dataSource});

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await dataSource.setDefaults(defaults);
  }

  Future<Either<Failure, void>> fetchAndActivate() async {
    try {
      await dataSource.fetchAndActivate();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  String getString(String key) => dataSource.getString(key);

  @override
  bool getBool(String key) => dataSource.getBool(key);

  @override
  int getInt(String key) => dataSource.getInt(key);

  @override
  double getDouble(String key) => dataSource.getDouble(key);
}
