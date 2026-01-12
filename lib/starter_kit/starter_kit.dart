import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'features/ads/ads_injector.dart';
import 'features/ads/data/datasources/ads_remote_data_source.dart';
import 'features/ads/presentation/bloc/ads_bloc.dart';
import 'features/analytics/analytics_injector.dart';
import 'features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'features/analytics/data/datasources/posthog_remote_data_source.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_event.dart';
import 'features/iap/iap_injector.dart';
import 'features/iap/data/datasources/iap_remote_data_source.dart';
import 'features/iap/presentation/bloc/iap_bloc.dart';
import 'features/onboarding/domain/models/onboarding_page_model.dart';
import 'features/onboarding/presentation/onboarding_view.dart';
import 'features/services/services_injector.dart';
import 'features/settings/domain/models/settings_models.dart';
import 'features/settings/presentation/settings_view.dart';
import 'features/ads/presentation/widgets/banner_ad_widget.dart';
import 'features/ads/presentation/widgets/native_ad_widget.dart';
import 'features/analytics/presentation/widgets/posthog_wrapper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// The Facade for the Starter Kit Plugin
///
/// Initializes all dependencies and provides access to Blocs and UI Templates.
class StarterKit {
  static final GetIt _sl = GetIt.asNewInstance();

  /// Access the internal Service Locator if needed
  static GetIt get sl => _sl;

  /// Initialize the Starter Kit
  static Future<void> initialize({
    required String supportEmail,
    String? feedbackNestApiKey,
    IapRemoteDataSource? iapDataSource,
    AdsRemoteDataSource? adsDataSource,
    List<AnalyticsRemoteDataSource>? analyticsDataSources,
    PostHogRemoteDataSource? postHogDataSource,
  }) async {
    // Analytics & PostHog
    initAnalyticsFeature(
      _sl,
      customDataSources: analyticsDataSources,
      postHogRemoteDataSource: postHogDataSource,
    );

    // IAP
    initIapFeature(_sl, customDataSource: iapDataSource);

    // Ads
    initAdsFeature(
      _sl,
      customDataSource: adsDataSource,
      onPaidEvent: (revenueEvent) {
        _sl<AnalyticsBloc>().add(AnalyticsLogAdRevenue(revenueEvent));
      },
    );

    // Services
    initServicesFeature(
      _sl,
      supportEmail: supportEmail,
      feedbackNestApiKey: feedbackNestApiKey,
    );
  }

  // --- Bloc Accessors ---

  static IapBloc get iapBloc => _sl<IapBloc>();
  static AdsBloc get adsBloc => _sl<AdsBloc>();
  static AnalyticsBloc get analyticsBloc => _sl<AnalyticsBloc>();

  /// Access PostHog directly if initialized
  static PostHogRemoteDataSource? get postHog {
    try {
      return _sl<PostHogRemoteDataSource>();
    } catch (_) {
      return null;
    }
  }

  // --- UI Template Builders ---

  /// Build a robust Onboarding Screen
  static Widget onboarding({
    required List<OnboardingPageModel> pages,
    OnboardingTemplateType template = OnboardingTemplateType.standard,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
    Function(int)? onPageChange,
    Color activeDotColor = Colors.blue,
    String nextText = 'Next',
    String completeText = 'Start',
  }) {
    return OnboardingView(
      pages: pages,
      templateType: template,
      onComplete: onComplete,
      onSkip: onSkip,
      onPageChange: onPageChange,
      activeDotColor: activeDotColor,
      nextButtonText: nextText,
      completeButtonText: completeText,
    );
  }

  /// Build a robust Settings Screen
  static Widget settings({
    required List<SettingsSection> sections,
    SettingsTemplateType template = SettingsTemplateType.list,
    String title = 'Settings',
    Color? backgroundColor,
  }) {
    return SettingsView(
      sections: sections,
      templateType: template,
      pageTitle: title,
      backgroundColor: backgroundColor,
    );
  }

  // --- Widget Builders ---

  /// Build a Banner Ad Widget
  static Widget bannerAd({AdSize adSize = AdSize.banner, String? adUnitId}) {
    return BannerAdWidget(adSize: adSize, adUnitId: adUnitId);
  }

  /// Build a Native Ad Widget
  static Widget nativeAd({
    String? adUnitId,
    NativeTemplateStyle? templateStyle,
    double? width,
    double? height,
  }) {
    return NativeAdWidget(
      adUnitId: adUnitId,
      templateStyle: templateStyle,
      width: width,
      height: height,
    );
  }

  /// Build a PostHog Wrapper
  static Widget postHogWrapper({
    required Widget child,
    required String apiKey,
    String host = 'https://app.posthog.com',
    bool captureLocalStorage = false,
    bool captureApplicationLifecycleEvents = true,
  }) {
    return PostHogWrapper(
      apiKey: apiKey,
      host: host,
      captureLocalStorage: captureLocalStorage,
      captureApplicationLifecycleEvents: captureApplicationLifecycleEvents,
      child: child,
    );
  }
}
