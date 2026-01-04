import 'package:get_it/get_it.dart';

import 'features/ads/ads_injector.dart';
import 'features/ads/data/datasources/ads_remote_data_source.dart';
import 'features/ads/presentation/bloc/ads_bloc.dart';
import 'features/analytics/analytics_injector.dart';
import 'features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/iap/iap_injector.dart';
import 'features/iap/data/datasources/iap_remote_data_source.dart';
import 'features/iap/presentation/bloc/iap_bloc.dart';
import 'features/services/services_injector.dart';

/// The Facade for the Starter Kit Plugin
///
/// Initializes all dependencies and provides access to Blocs.
///
/// Usage:
/// ```dart
/// await StarterKit.initialize(
///   iapDataSource: RevenueCatDataSource(),
///   adsDataSource: AdMobDataSource(),
/// );
/// ```
class StarterKit {
  static final GetIt _sl = GetIt.asNewInstance();

  /// Access the internal Service Locator if needed
  static GetIt get sl => _sl;

  /// Initialize the Starter Kit
  ///
  /// Provide custom data sources here to swap implementations (e.g. Adapty instead of RevenueCat)
  static Future<void> initialize({
    IapRemoteDataSource? iapDataSource,
    AdsRemoteDataSource? adsDataSource,
    List<AnalyticsRemoteDataSource>? analyticsDataSources,
  }) async {
    // Analytics
    initAnalyticsFeature(_sl, customDataSources: analyticsDataSources);

    // IAP
    initIapFeature(_sl, customDataSource: iapDataSource);

    // Ads
    initAdsFeature(_sl, customDataSource: adsDataSource);

    // Services
    initServicesFeature(_sl);
  }

  // --- Bloc Accessors ---

  /// Create a new IapBloc - remember to provide the necessary events
  static IapBloc get iapBloc => _sl<IapBloc>();

  /// Create a new AdsBloc
  static AdsBloc get adsBloc => _sl<AdsBloc>();

  /// Create a new AnalyticsBloc
  static AnalyticsBloc get analyticsBloc => _sl<AnalyticsBloc>();
}
