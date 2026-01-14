import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bloc_observer.dart';
import 'src/container_injector.dart';
import 'src/my_app.dart';
import 'starterkit_init.dart';
import 'firebase_options.dart';
import 'src/config/environment_vars.dart';
import 'starter_kit/features/ads/domain/repositories/ads_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If it's already initialized, we can safely ignore the error
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  // Initialize StarterKit
  await initializeStarterKit(
    supportEmail: 'support@gentech.com',
    posthogApiKey: EnvironmentsVar.posthogApiKey,
    posthogHost: 'https://app.posthog.com',
    feedbackNestApiKey: EnvironmentsVar.feedBackNestApiKey,
    oneSignalAppId: EnvironmentsVar.oneSignalAppId,
    remoteConfigDefaults: {
      'min_insta_ad_interval': 5,
      'min_rewarded_ad_interval': 12,
      'min_banner_ad_interval': 3,
      'min_app_open_ad': 1,
      'should_show_app_open_ad': true,
      'time_before_first_insta_ad': 5,
      'time_before_first_rewared_ad': 10,
      'min_native_interval': 0,
      'banner_ad_id': 'ca-app-pub-3940256099942544/6300978111',
      'native_ad_id': 'ca-app-pub-3940256099942544/2247696110',
    },
    adsConfig: AdsConfig(
      bannerAdUnitId:
          EnvironmentsVar.bannerAdId.isNotEmpty
              ? EnvironmentsVar.bannerAdId
              : (kDebugMode
                  ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner ID
                  : null),
      interstitialAdUnitId:
          EnvironmentsVar.interstitialAdId.isNotEmpty
              ? EnvironmentsVar.interstitialAdId
              : (kDebugMode
                  ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial ID
                  : null),
      rewardedAdUnitId:
          EnvironmentsVar.rewardedAdId.isNotEmpty
              ? EnvironmentsVar.rewardedAdId
              : (kDebugMode
                  ? 'ca-app-pub-3940256099942544/5224354917' // Test Rewarded ID
                  : null),
      appOpenAdUnitId:
          EnvironmentsVar.appOpenAdId.isNotEmpty
              ? EnvironmentsVar.appOpenAdId
              : (kDebugMode
                  ? 'ca-app-pub-3940256099942544/9257395921' // Test App Open ID
                  : null),
      nativeAdUnitId:
          EnvironmentsVar.nativeAdId.isNotEmpty
              ? EnvironmentsVar.nativeAdId
              : (kDebugMode
                  ? 'ca-app-pub-3940256099942544/2247696110' // Test Native ID
                  : null),
    ),
  );

  // Initialize app dependencies
  initApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
