import '../utils/analytics_names.dart';
import '../../presentation/bloc/analytics_bloc.dart';
import '../../presentation/bloc/analytics_event.dart';
import '../../domain/entities/ad_revenue_event.dart';

/// Service to simplify logging of standard and custom analytics events
///
/// Uses AnalyticsNames to resolve the actual event names, allowing for
/// dynamic renaming via Remote Config mapping.
class AnalyticsService {
  final AnalyticsBloc _bloc;
  final AnalyticsNames _names = AnalyticsNames.instance;

  AnalyticsService(this._bloc);

  /// Log a completely custom event
  void logEvent(String name, {Map<String, dynamic> parameters = const {}}) {
    _bloc.add(AnalyticsLogEvent(name: name, parameters: parameters));
  }

  /// Log ad revenue
  void logAdRevenue(AdRevenueEvent event) {
    // Specifically mapped for Status Saver consistency
    _bloc.add(AnalyticsLogAdRevenue(event));
  }

  /// Specialized Category Logs
  Future<void> logRetentionEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    _bloc.add(AnalyticsLogRetention(name: eventName, parameters: parameters));
  }

  Future<void> logUserSegmentEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    _bloc.add(AnalyticsLogUserSegment(name: eventName, parameters: parameters));
  }

  Future<void> logTargetingEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    _bloc.add(AnalyticsLogTargeting(name: eventName, parameters: parameters));
  }

  /// Crashlytics & Error Tracking
  void recordFlutterError(dynamic error, dynamic stack, {bool fatal = false}) {
    _bloc.add(
      AnalyticsRecordFlutterError(error: error, stack: stack, fatal: fatal),
    );
  }

  void recordError(dynamic error, dynamic stack, {bool fatal = false}) {
    _bloc.add(AnalyticsRecordError(error: error, stack: stack, fatal: fatal));
  }

  void testCrash() {
    throw const FormatException(
      'StarterKit: Custom format error for Crashlytics testing',
    );
  }

  // --- Standard Events ---

  void logAppOpen() => logEvent(_names.appOpen);

  void logOnboardingComplete() => logEvent(_names.onboardingComplete);

  void logViewPaywall({String? source}) => logEvent(
    _names.viewPaywall,
    parameters: source != null ? {'source': source} : {},
  );

  void logViewPaywallModal() => logEvent(_names.viewPaywallModal);

  void logGotoAppStore() => logEvent(_names.gotoAppStore);

  void logGotoHome() => logEvent(_names.gotoHome);

  void logShowHelp() => logEvent(_names.showHelp);

  void logShareApp() => logEvent(_names.shareApp);

  void logSaveStatus() => logEvent(_names.saveStatus);

  void logDownloadAll() => logEvent(_names.downloadAll);

  void logRemoveAdsClicked() => logEvent(_names.removeAdsClicked);

  void logAutoSaveEnabled() => logEvent(_names.autoSaveEnabled);

  void logAutoSaveDisabled() => logEvent(_names.autoSaveDisabled);

  // --- Permissions ---

  void logRequestNotification() => logEvent(_names.requestNotification);
  void logGrantNotification() => logEvent(_names.grantNotification);
  void logRequestStorage() => logEvent(_names.requestStorage);
  void logGrantStorage() => logEvent(_names.grantStorage);
  void logDeniedStorage() => logEvent(_names.deniedStorage);

  // --- Errors ---

  void logAppError(String message) =>
      logEvent(_names.appError, parameters: {'message': message});

  // --- Rating ---

  void logRatingMaybeLater() => logEvent(_names.ratingMaybeLater);
  void logRatingNever() => logEvent(_names.ratingNever);
  void logRatingSubmitted(int stars) =>
      logEvent(_names.ratingSubmitted, parameters: {'star_count': stars});
  void logRating4Stars() => logEvent(_names.rating4Stars);
  void logRating5Stars() => logEvent(_names.rating5Stars);

  // --- Purchases ---

  void logCustomPurchase({
    required double price,
    required String currency,
    required String productId,
    required String entitlementId,
  }) {
    logEvent(
      _names.customPurchase,
      parameters: {
        'currency': currency,
        'value': price,
        'item_id': productId,
        'item_name': entitlementId,
        'quantity': 1,
      },
    );
  }

  void logPaywallCancelled(String? entitlementId) => logEvent(
    _names.paywallCancelled,
    parameters: entitlementId != null ? {'entitlementId': entitlementId} : {},
  );

  void logPurchasesRestored(String? entitlementId) => logEvent(
    _names.purchasesRestored,
    parameters: entitlementId != null ? {'entitlementId': entitlementId} : {},
  );
}
