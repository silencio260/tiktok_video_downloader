/// Environment Variables Configuration
///
/// Access all environment variables through this class.
/// These values are read from compile-time constants passed via --dart-define flags.
/// The actual values are stored in env/dev.json, env/release.json, and env/special_dev.json
///
/// Usage:
///   - Build: flutter run --dart-define=posthog_api_key=your_key
///   - Or set in your IDE run configuration
class EnvironmentsVar {
  EnvironmentsVar._(); // Private constructor to prevent instantiation

  // Version flags
  static const bool foundersVersion = bool.fromEnvironment(
    'founders_version',
    defaultValue: false,
  );

  static const bool specialVersionMode = bool.fromEnvironment(
    'special_version_mode',
    defaultValue: false,
  );

  static const bool developmentMode = bool.fromEnvironment(
    'development_mode',
    defaultValue: false,
  );

  // Firebase API Keys
  static const String firebaseApiKeyAndroid = String.fromEnvironment(
    'firebase_api_key_android',
    defaultValue: '',
  );

  static const String firebaseApiKeyIos = String.fromEnvironment(
    'firebase_api_key_ios',
    defaultValue: '',
  );

  // AdMob Ad Units
  static const String bannerAdId = String.fromEnvironment(
    'banner_ad_id',
    defaultValue: '',
  );

  static const String interstitialAdId = String.fromEnvironment(
    'interstitial_ad_id',
    defaultValue: '',
  );

  static const String appOpenAdId = String.fromEnvironment(
    'app_open_ad_id',
    defaultValue: '',
  );

  static const String rewardedAdId = String.fromEnvironment(
    'rewarded_ad_id',
    defaultValue: '',
  );

  static const String nativeAdId = String.fromEnvironment(
    'native_ad_id',
    defaultValue: '',
  );

  // OneSignal
  static const String oneSignalAppId = String.fromEnvironment(
    'one_signal_app_id',
    defaultValue: '',
  );

  // RevenueCat (IAP)
  static const String revenueCatApiKeyAndroid = String.fromEnvironment(
    'revenue_cat_api_key_android',
    defaultValue: '',
  );

  // PostHog Analytics
  static const String posthogApiKey = String.fromEnvironment(
    'posthog_api_key',
    defaultValue: '',
  );

  // Feedback Nest
  static const String feedBackNestApiKey = String.fromEnvironment(
    'feed_back_nest_api_key',
    defaultValue: '',
  );

  // Helper methods
  static bool get isDeveloperMode => developmentMode;
  static bool get isFoundersVersion => foundersVersion;
  static bool get isSpecialVersionMode => specialVersionMode;

  static bool get hasRevenueCatAndroid => revenueCatApiKeyAndroid.isNotEmpty;
  static bool get hasPosthog => posthogApiKey.isNotEmpty;
  static bool get hasOneSignal => oneSignalAppId.isNotEmpty;
}
