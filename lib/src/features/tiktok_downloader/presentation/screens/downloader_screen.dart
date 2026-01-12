import 'package:flutter/material.dart';

import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';
import '../widgets/downloader_screen/downloader_screen_app_bar.dart';
import '../widgets/downloader_screen/downloader_screen_body.dart';
import '../../../../../starter_kit/starter_kit.dart';

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: const DownloaderScreenAppBar(),
      body: const DownloaderScreenBody(),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: StarterKit.bannerAd(),
        ),
      ),
    );
  }
}
