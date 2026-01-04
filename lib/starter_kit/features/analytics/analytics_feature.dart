import 'package:shared_preferences/shared_preferences.dart';

import '../../core/base_feature.dart';
import 'providers/analytics_provider.dart';

/// Analytics feature facade
///
/// Delegates to multiple analytics providers (Firebase, PostHog, etc.).
/// All providers are null-safe and optional.
///
/// Usage:
/// ```dart
/// final analytics = AnalyticsFeature();
/// await analytics.initialize(providers: [FirebaseAnalyticsProvider()]);
/// await analytics.logEvent('button_clicked', {'button_id': 'submit'});
/// ```
class AnalyticsFeature extends BaseFeature {
  final List<AnalyticsProvider> _providers = [];
  RetentionTracker? _retentionTracker;

  /// Get the retention tracker (null if not initialized)
  RetentionTracker? get retention => _retentionTracker;

  /// Add analytics providers
  void addProviders(List<AnalyticsProvider> providers) {
    _providers.addAll(providers);
  }

  @override
  Future<void> onInitialize() async {
    for (final provider in _providers) {
      await provider.initialize();
    }

    // Initialize retention tracker
    _retentionTracker = RetentionTracker();
    await _retentionTracker!.initialize();

    // Wire up retention events to analytics
    _retentionTracker!.onRetentionEvent = (eventName, params) async {
      await logEvent(eventName, params);
    };
  }

  /// Log a custom event to all providers
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (!isInitialized) {
      print('AnalyticsFeature: Not initialized, skipping event: $name');
      return;
    }

    for (final provider in _providers) {
      await provider.logEvent(name, parameters);
    }
  }

  /// Log a screen view to all providers
  Future<void> logScreenView(String screenName, [String? screenClass]) async {
    if (!isInitialized) return;

    for (final provider in _providers) {
      await provider.logScreenView(screenName, screenClass);
    }
  }

  /// Set user ID across all providers
  Future<void> setUserId(String? userId) async {
    if (!isInitialized) return;

    for (final provider in _providers) {
      await provider.setUserId(userId);
    }
  }

  /// Set user property across all providers
  Future<void> setUserProperty(String name, String? value) async {
    if (!isInitialized) return;

    for (final provider in _providers) {
      await provider.setUserProperty(name, value);
    }
  }

  /// Track app open (also tracks retention)
  Future<void> trackAppOpen() async {
    if (!isInitialized) return;

    await _retentionTracker?.trackAppOpen();
    await logEvent('app_open');
  }

  @override
  Future<void> onDispose() async {
    for (final provider in _providers) {
      await provider.dispose();
    }
    _providers.clear();
  }
}

/// Retention tracking - standalone, no external state management dependency
///
/// Uses simple callback pattern instead of Bloc/Provider to keep plugin portable.
class RetentionTracker extends BaseFeature {
  static const String _firstInstallKey = 'sk_first_install_date';
  static const String _lastOpenKey = 'sk_last_open_date';
  static const String _totalOpensKey = 'sk_total_app_opens';
  static const String _dailyOpenDatesKey = 'sk_daily_open_dates';

  DateTime? _firstInstallDate;
  DateTime? _lastOpenDate;
  int? _totalAppOpens;
  List<DateTime>? _dailyOpenDates;

  /// Callback for analytics logging - inject your analytics here
  Future<void> Function(String eventName, Map<String, dynamic> params)?
  onRetentionEvent;

  /// Callback when retention state changes - use with Bloc if needed
  void Function(RetentionState state)? onStateChanged;

  @override
  Future<void> onInitialize() async {
    final prefs = await SharedPreferences.getInstance();

    final firstInstallStr = prefs.getString(_firstInstallKey);
    _firstInstallDate =
        firstInstallStr != null ? DateTime.parse(firstInstallStr) : null;

    final lastOpenStr = prefs.getString(_lastOpenKey);
    _lastOpenDate = lastOpenStr != null ? DateTime.parse(lastOpenStr) : null;

    _totalAppOpens = prefs.getInt(_totalOpensKey);

    final dailyStrings = prefs.getStringList(_dailyOpenDatesKey);
    _dailyOpenDates =
        dailyStrings?.map((s) => DateTime.parse(s)).toList() ?? [];
  }

  /// Get current state (for Bloc integration)
  RetentionState get currentState => RetentionState(
    firstInstallDate: _firstInstallDate,
    lastOpenDate: _lastOpenDate,
    totalAppOpens: _totalAppOpens ?? 0,
    daysSinceInstall: getDaysSinceInstall(),
    d7RetentionRate: getD7RetentionRate(),
  );

  /// Track app open
  Future<void> trackAppOpen() async {
    if (!isInitialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // First install
    if (_firstInstallDate == null) {
      _firstInstallDate = now;
      await prefs.setString(_firstInstallKey, now.toIso8601String());
    }

    // Last open
    _lastOpenDate = now;
    await prefs.setString(_lastOpenKey, now.toIso8601String());

    // Total opens
    _totalAppOpens = (_totalAppOpens ?? 0) + 1;
    await prefs.setInt(_totalOpensKey, _totalAppOpens!);

    // Daily opens
    _dailyOpenDates ??= [];
    if (!_dailyOpenDates!.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    )) {
      _dailyOpenDates!.add(today);
      await prefs.setStringList(
        _dailyOpenDatesKey,
        _dailyOpenDates!.map((d) => d.toIso8601String()).toList(),
      );
    }

    // Notify state change
    onStateChanged?.call(currentState);

    // Log analytics
    if (onRetentionEvent != null) {
      await onRetentionEvent!('retention_app_opened', getEngagementMetrics());
    }
  }

  int getTotalAppOpens() => _totalAppOpens ?? 0;

  int getDaysSinceInstall() {
    if (_firstInstallDate == null) return 0;
    return DateTime.now().difference(_firstInstallDate!).inDays;
  }

  bool hasReturnedOnDay(int day) {
    if (_firstInstallDate == null || _dailyOpenDates == null) return false;
    if (day < 1 || day > 30) return false;

    final targetDate = DateTime(
      _firstInstallDate!.year,
      _firstInstallDate!.month,
      _firstInstallDate!.day + day,
    );

    return _dailyOpenDates!.any(
      (d) =>
          d.year == targetDate.year &&
          d.month == targetDate.month &&
          d.day == targetDate.day,
    );
  }

  double getD7RetentionRate() {
    if (_firstInstallDate == null) return 0.0;
    int activeDays = 0;
    for (int day = 1; day <= 7; day++) {
      if (hasReturnedOnDay(day)) activeDays++;
    }
    return (activeDays / 7.0) * 100.0;
  }

  Map<String, dynamic> getEngagementMetrics() => {
    'total_opens': getTotalAppOpens(),
    'days_since_install': getDaysSinceInstall(),
    'd7_retention_rate': getD7RetentionRate(),
  };

  @override
  Future<void> onDispose() async {}
}

/// Immutable retention state for Bloc integration
class RetentionState {
  final DateTime? firstInstallDate;
  final DateTime? lastOpenDate;
  final int totalAppOpens;
  final int daysSinceInstall;
  final double d7RetentionRate;

  const RetentionState({
    this.firstInstallDate,
    this.lastOpenDate,
    this.totalAppOpens = 0,
    this.daysSinceInstall = 0,
    this.d7RetentionRate = 0.0,
  });

  RetentionState copyWith({
    DateTime? firstInstallDate,
    DateTime? lastOpenDate,
    int? totalAppOpens,
    int? daysSinceInstall,
    double? d7RetentionRate,
  }) {
    return RetentionState(
      firstInstallDate: firstInstallDate ?? this.firstInstallDate,
      lastOpenDate: lastOpenDate ?? this.lastOpenDate,
      totalAppOpens: totalAppOpens ?? this.totalAppOpens,
      daysSinceInstall: daysSinceInstall ?? this.daysSinceInstall,
      d7RetentionRate: d7RetentionRate ?? this.d7RetentionRate,
    );
  }
}
