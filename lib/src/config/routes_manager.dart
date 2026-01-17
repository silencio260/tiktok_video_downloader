import 'package:flutter/material.dart';
import 'package:tiktok_video_downloader/src/features/tiktok_downloader/presentation/widgets/downloads_screen/video_player_view.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/tiktok_downloader/presentation/screens/downloader_screen.dart';
import '../features/tiktok_downloader/presentation/screens/downloads_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'package:tiktok_video_downloader/src/features/onboarding/presentation/screens/onboarding_screen.dart';

class Routes {
  static const String splash = "/splash";
  static const String downloader = "/downloader";
  static const String downloads = "/downloads";
  static const String viewVideo = "/viewVideo";
  static const String onboarding = "/onboarding";
  static const String settings = "/settings";
}

class AppRouter {
  static Route? getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      case Routes.downloader:
        return MaterialPageRoute(
          builder: (context) => const DownloaderScreen(),
        );
      case Routes.downloads:
        return MaterialPageRoute(builder: (context) => const DownloadsScreen());
      case Routes.viewVideo:
        return MaterialPageRoute(
          builder:
              (context) =>
                  VideoPlayerView(videoPath: routeSettings.arguments as String),
        );
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case Routes.settings:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
    }
    return null;
  }
}
