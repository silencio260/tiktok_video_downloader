import 'package:shared_preferences/shared_preferences.dart';

import '../../core/base_feature.dart';

/// Subscription state for Bloc integration
class SubscriptionState {
  final bool isPremium;
  final bool isInitialized;
  final DateTime? lastChecked;
  final bool debugOverrideEnabled;

  const SubscriptionState({
    this.isPremium = false,
    this.isInitialized = false,
    this.lastChecked,
    this.debugOverrideEnabled = false,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    bool? isInitialized,
    DateTime? lastChecked,
    bool? debugOverrideEnabled,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      isInitialized: isInitialized ?? this.isInitialized,
      lastChecked: lastChecked ?? this.lastChecked,
      debugOverrideEnabled: debugOverrideEnabled ?? this.debugOverrideEnabled,
    );
  }
}

/// Subscription manager for premium state tracking
///
/// Works with RevenueCat or any IAP provider.
/// Uses callback pattern for Bloc integration.
///
/// Usage:
/// ```dart
/// final manager = SubscriptionManager(
///   checkSubscription: () => RevenueCatService.checkSubscriptionStatus(),
/// );
/// await manager.initialize();
/// if (manager.isPremium) { ... }
/// ```
class SubscriptionManager extends BaseFeature {
  static const String _debugPremiumKey = 'sk_debug_premium_override';
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Inject your IAP check function
  final Future<bool> Function()? checkSubscription;

  /// Enable development mode features
  final bool developmentMode;

  SubscriptionState _state = const SubscriptionState();

  /// Callback when subscription state changes
  void Function(SubscriptionState state)? onStateChanged;

  SubscriptionManager({this.checkSubscription, this.developmentMode = false});

  /// Current subscription state
  SubscriptionState get state => _state;

  /// Quick check: is user premium?
  bool get isPremium {
    if (_state.debugOverrideEnabled && developmentMode) {
      return true;
    }
    return _state.isPremium;
  }

  @override
  Future<void> onInitialize() async {
    final prefs = await SharedPreferences.getInstance();
    final debugOverride = prefs.getBool(_debugPremiumKey) ?? false;

    _state = _state.copyWith(debugOverrideEnabled: debugOverride);

    await checkSubscriptionStatus();
  }

  /// Check current subscription status
  Future<void> checkSubscriptionStatus() async {
    // Use cache if recent
    if (_state.isInitialized && _state.lastChecked != null) {
      final sinceLastCheck = DateTime.now().difference(_state.lastChecked!);
      if (sinceLastCheck < _cacheDuration) {
        print('SubscriptionManager: Using cached status');
        return;
      }
    }

    try {
      final hasSubscription = await checkSubscription?.call() ?? false;

      _state = _state.copyWith(
        isPremium: hasSubscription,
        isInitialized: true,
        lastChecked: DateTime.now(),
      );

      print('SubscriptionManager: isPremium = ${_state.isPremium}');
      onStateChanged?.call(_state);
    } catch (e) {
      print('SubscriptionManager: Error checking status: $e');
      _state = _state.copyWith(
        isPremium: false,
        isInitialized: true,
        lastChecked: DateTime.now(),
      );
      onStateChanged?.call(_state);
    }
  }

  /// Force refresh subscription status
  Future<void> refresh() async {
    _state = _state.copyWith(lastChecked: null);
    await checkSubscriptionStatus();
  }

  /// Toggle debug premium (development only)
  Future<void> setDebugPremium(bool enabled) async {
    if (!developmentMode) {
      print('SubscriptionManager: Debug premium only works in dev mode');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugPremiumKey, enabled);

    _state = _state.copyWith(debugOverrideEnabled: enabled);
    onStateChanged?.call(_state);
    print('SubscriptionManager: Debug premium = $enabled');
  }

  /// Reset state
  void reset() {
    _state = const SubscriptionState();
    onStateChanged?.call(_state);
  }

  @override
  Future<void> onDispose() async {}
}
