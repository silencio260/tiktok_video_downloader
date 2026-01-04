import 'package:shared_preferences/shared_preferences.dart';

import '../../core/base_feature.dart';

/// GDPR consent handler
///
/// Manages user consent for data collection and personalized ads.
///
/// Usage:
/// ```dart
/// final gdpr = GdprConsentService();
/// await gdpr.initialize();
///
/// if (!gdpr.hasConsent) {
///   await gdpr.showConsentDialog(context);
/// }
/// ```
class GdprConsentService extends BaseFeature {
  static const String _consentKey = 'sk_gdpr_consent';
  static const String _consentDateKey = 'sk_gdpr_consent_date';

  bool _hasConsent = false;
  DateTime? _consentDate;

  /// Callback for consent events (for analytics)
  void Function(bool granted)? onConsentChanged;

  /// Callback to show your consent UI - return true if granted
  Future<bool> Function()? showConsentPrompt;

  /// Check if user has given consent
  bool get hasConsent => _hasConsent;

  /// Date when consent was given
  DateTime? get consentDate => _consentDate;

  @override
  Future<void> onInitialize() async {
    final prefs = await SharedPreferences.getInstance();

    _hasConsent = prefs.getBool(_consentKey) ?? false;

    final dateStr = prefs.getString(_consentDateKey);
    _consentDate = dateStr != null ? DateTime.parse(dateStr) : null;

    print('GdprConsentService: hasConsent = $_hasConsent');
  }

  /// Request consent from user
  Future<bool> requestConsent() async {
    if (showConsentPrompt == null) {
      print('GdprConsentService: No consent prompt configured');
      return false;
    }

    final granted = await showConsentPrompt!();
    await setConsent(granted);
    return granted;
  }

  /// Set consent status programmatically
  Future<void> setConsent(bool granted) async {
    final prefs = await SharedPreferences.getInstance();

    _hasConsent = granted;
    await prefs.setBool(_consentKey, granted);

    if (granted) {
      _consentDate = DateTime.now();
      await prefs.setString(_consentDateKey, _consentDate!.toIso8601String());
    }

    onConsentChanged?.call(granted);
    print('GdprConsentService: Consent set to $granted');
  }

  /// Reset consent (for testing or if user requests)
  Future<void> resetConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentKey);
    await prefs.remove(_consentDateKey);

    _hasConsent = false;
    _consentDate = null;

    print('GdprConsentService: Consent reset');
  }

  @override
  Future<void> onDispose() async {}
}
