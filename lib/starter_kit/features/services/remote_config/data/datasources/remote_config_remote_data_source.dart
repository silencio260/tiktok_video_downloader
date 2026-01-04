/// Interface for Remote Config provider
abstract class RemoteConfigRemoteDataSource {
  Future<bool> fetchAndActivate();
  String getString(String key);
  bool getBool(String key);
  int getInt(String key);
  double getDouble(String key);
}
