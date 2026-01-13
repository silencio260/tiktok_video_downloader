import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'remote_config_remote_data_source.dart';

/// Firebase Implementation of Remote Config Data Source
class FirebaseRemoteConfigDataSource implements RemoteConfigRemoteDataSource {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _remoteConfig.setDefaults(defaults);
  }

  @override
  Future<bool> fetchAndActivate() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    return await _remoteConfig.fetchAndActivate();
  }

  @override
  String getString(String key) => _remoteConfig.getString(key);

  @override
  bool getBool(String key) => _remoteConfig.getBool(key);

  @override
  int getInt(String key) => _remoteConfig.getInt(key);

  @override
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
