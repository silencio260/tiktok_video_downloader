import 'package:shared_preferences/shared_preferences.dart';

import '../../config/starter_kit_config.dart';
import '../../core/base_feature.dart';

/// Manages daily action limits for freemium apps
///
/// Tracks actions per day and enforces limits for free users.
///
/// Usage:
/// ```dart
/// final limiter = DailyLimitManager(config: DailyLimitConfig(freeActionsPerDay: 5));
/// await limiter.initialize();
///
/// if (await limiter.canPerformAction()) {
///   await limiter.recordAction();
///   // ... do the action
/// } else {
///   // Show paywall
/// }
/// ```
class DailyLimitManager extends BaseFeature {
  final DailyLimitConfig config;

  DailyLimitManager({DailyLimitConfig? config})
    : config = config ?? const DailyLimitConfig();

  /// Callback when limit is reached
  void Function()? onLimitReached;

  @override
  Future<void> onInitialize() async {
    // Nothing special needed
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${config.actionKeyPrefix}${now.year}-${now.month}-${now.day}';
  }

  /// Check if user can perform another action today
  Future<bool> canPerformAction() async {
    final count = await getActionCount();
    return count < config.freeActionsPerDay;
  }

  /// Get remaining actions for today
  Future<int> getRemainingActions() async {
    final count = await getActionCount();
    return (config.freeActionsPerDay - count).clamp(
      0,
      config.freeActionsPerDay,
    );
  }

  /// Get current action count for today
  Future<int> getActionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getTodayKey()) ?? 0;
  }

  /// Record an action (increment counter)
  Future<void> recordAction() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);

    print(
      'DailyLimitManager: Action recorded (${current + 1}/${config.freeActionsPerDay})',
    );

    if (current + 1 >= config.freeActionsPerDay) {
      onLimitReached?.call();
    }
  }

  /// Check limit and record action in one call
  /// Returns true if action was allowed, false if limit reached
  Future<bool> tryRecordAction() async {
    if (await canPerformAction()) {
      await recordAction();
      return true;
    }
    onLimitReached?.call();
    return false;
  }

  /// Reset today's counter (for testing or premium users)
  Future<void> resetToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getTodayKey());
    print('DailyLimitManager: Counter reset');
  }

  @override
  Future<void> onDispose() async {}
}
