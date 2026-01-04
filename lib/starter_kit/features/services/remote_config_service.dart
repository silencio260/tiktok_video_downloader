import '../../core/base_feature.dart';

/// Firebase Remote Config service
///
/// Provides feature flags and remote configuration.
///
/// Usage:
/// ```dart
/// final remoteConfig = RemoteConfigService();
/// await remoteConfig.initialize();
///
/// final enabled = remoteConfig.getBool('feature_enabled');
/// final limit = remoteConfig.getInt('daily_limit', defaultValue: 3);
/// ```
class RemoteConfigService extends BaseFeature {
  final Map<String, dynamic> _defaults;
  Map<String, dynamic> _values = {};

  /// Callback to fetch config from Firebase
  /// Inject your Firebase Remote Config implementation
  final Future<Map<String, dynamic>> Function()? fetchConfig;

  RemoteConfigService({Map<String, dynamic>? defaults, this.fetchConfig})
    : _defaults = defaults ?? {};

  @override
  Future<void> onInitialize() async {
    _values = Map.from(_defaults);

    if (fetchConfig != null) {
      await refresh();
    }
  }

  /// Refresh config from remote
  Future<void> refresh() async {
    if (fetchConfig == null) return;

    try {
      final remote = await fetchConfig!();
      _values = {..._defaults, ...remote};
      print('RemoteConfigService: Fetched ${remote.length} values');
    } catch (e) {
      print('RemoteConfigService: Fetch failed: $e');
    }
  }

  /// Get a string value
  String getString(String key, {String defaultValue = ''}) {
    return _values[key]?.toString() ??
        _defaults[key]?.toString() ??
        defaultValue;
  }

  /// Get a bool value
  bool getBool(String key, {bool defaultValue = false}) {
    final value = _values[key] ?? _defaults[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  /// Get an int value
  int getInt(String key, {int defaultValue = 0}) {
    final value = _values[key] ?? _defaults[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Get a double value
  double getDouble(String key, {double defaultValue = 0.0}) {
    final value = _values[key] ?? _defaults[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Check if a key exists
  bool hasKey(String key) {
    return _values.containsKey(key) || _defaults.containsKey(key);
  }

  /// Get all current values (for debugging)
  Map<String, dynamic> getAllValues() => Map.from(_values);

  @override
  Future<void> onDispose() async {}
}
