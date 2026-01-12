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
    supportEmail:
        'support@gentech.com', // Replace with your actual support email
    posthogApiKey: EnvironmentsVar.posthogApiKey,
    posthogHost: 'https://app.posthog.com',
    feedbackNestApiKey: EnvironmentsVar.feedBackNestApiKey,
    oneSignalAppId: EnvironmentsVar.oneSignalAppId,
    adsConfig: AdsConfig(
      bannerAdUnitId:
          EnvironmentsVar.bannerAdId.isNotEmpty
              ? EnvironmentsVar.bannerAdId
              : null,
      interstitialAdUnitId:
          EnvironmentsVar.interstitialAdId.isNotEmpty
              ? EnvironmentsVar.interstitialAdId
              : null,
      rewardedAdUnitId:
          EnvironmentsVar.rewardedAdId.isNotEmpty
              ? EnvironmentsVar.rewardedAdId
              : null,
      appOpenAdUnitId:
          EnvironmentsVar.appOpenAdId.isNotEmpty
              ? EnvironmentsVar.appOpenAdId
              : null,
      nativeAdUnitId:
          EnvironmentsVar.nativeAdId.isNotEmpty
              ? EnvironmentsVar.nativeAdId
              : null,
    ),
  );

  // Initialize app dependencies
  initApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}
