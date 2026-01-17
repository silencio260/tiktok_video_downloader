import 'package:flutter/material.dart';

import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';
import '../widgets/downloader_screen/downloader_screen_app_bar.dart';
import '../widgets/downloader_screen/downloader_screen_body.dart';
import '../../../../../starter_kit/starter_kit.dart';
import '../../../../../starter_kit/features/navigation/domain/models/double_tap_config.dart';

class DownloaderScreen extends StatelessWidget {
  const DownloaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StarterKit.doubleTapToExit(
      config: DoubleTapExitConfig(
        dialogTitle: "Exit App",
        dialogContent: "Are you sure you want to leave?",
        confirmButtonText: "Yes",
        cancelButtonText: "No",
        dialogBackgroundColor: AppColors.cardColor,
        titleColor: AppColors.white,
        contentColor: AppColors.white,
        confirmButtonTextColor: AppColors.white,
        cancelButtonTextColor: Colors.grey,
        snackBarMessage: 'Tap back again to exit',
        snackBarBackgroundColor: AppColors.black,
        snackBarTextColor: AppColors.white,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: const DownloaderScreenAppBar(),
        body: const DownloaderScreenBody(),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: StarterKit.bannerAd(),
          ),
        ),
      ),
    );
  }
}
