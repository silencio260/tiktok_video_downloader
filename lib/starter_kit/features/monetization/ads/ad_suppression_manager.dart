/// Ad suppression manager
///
/// Temporarily disables ads during critical user flows like paywalls,
/// rating dialogs, or other important UI.
///
/// Usage:
/// ```dart
/// // Suppress ads during paywall
/// AdSuppressionManager().suppressAds('paywall');
/// await showPaywall();
/// AdSuppressionManager().enableAds('paywall');
///
/// // Or use the helper:
/// await AdSuppressionManager().withAdsSuppressed(
///   reason: 'rating_dialog',
///   action: () async => await showRatingDialog(),
/// );
/// ```
class AdSuppressionManager {
  // Singleton
  static final AdSuppressionManager _instance =
      AdSuppressionManager._internal();
  factory AdSuppressionManager() => _instance;
  AdSuppressionManager._internal();

  final Set<String> _suppressionReasons = {};

  /// Callback when suppression state changes
  void Function(bool suppressed)? onSuppressionChanged;

  /// True if ads are currently suppressed
  bool get areAdsSuppressed => _suppressionReasons.isNotEmpty;

  /// List of active suppression reasons (for debugging)
  List<String> get activeReasons => _suppressionReasons.toList();

  /// Suppress ads for a specific reason
  void suppressAds(String reason) {
    final wasEmpty = _suppressionReasons.isEmpty;
    _suppressionReasons.add(reason);

    if (wasEmpty) {
      print('AdSuppressionManager: Ads suppressed by: $reason');
      onSuppressionChanged?.call(true);
    }
  }

  /// Re-enable ads for a specific reason
  void enableAds(String reason) {
    final removed = _suppressionReasons.remove(reason);

    if (removed && _suppressionReasons.isEmpty) {
      print('AdSuppressionManager: Ads re-enabled');
      onSuppressionChanged?.call(false);
    }
  }

  /// Execute action with ads suppressed, auto-restores after
  Future<T> withAdsSuppressed<T>({
    required String reason,
    required Future<T> Function() action,
  }) async {
    suppressAds(reason);
    try {
      return await action();
    } finally {
      enableAds(reason);
    }
  }

  /// Clear all suppressions (for error recovery)
  void clearAll() {
    if (_suppressionReasons.isNotEmpty) {
      print('AdSuppressionManager: Clearing all suppressions');
      _suppressionReasons.clear();
      onSuppressionChanged?.call(false);
    }
  }

  /// Check if suppressed by specific reason
  bool isSuppressedBy(String reason) => _suppressionReasons.contains(reason);
}
