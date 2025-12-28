import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routes_manager.dart';
import '../../../../core/media_query.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animationTime),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    _timer = Timer.periodic(
      const Duration(milliseconds: AppConstants.navigateTime),
      (timer) => navigateToNextScreen(),
    );
  }

  navigateToNextScreen() {
    _timer.cancel(); // Cancel after first fire? Or periodic implies repeatedly?
    // Usually splash navigates ONCE. periodic is wrong if we intend to navigate once.
    // But let's stick to cancelling in dispose.
    // Code says periodic. If navigateToNextScreen is called repeatedly, pushNamedAndRemoveUntil works?
    // It removes until false, so new route replaces. Repeat push?
    // The conditional `if (mounted)` protects it somewhat.
    // Better to use Timer(duration, callback) instead of periodic if intended once.
    // But adhering to "copy code", I'll just fix the leak. But I'll cancel in navigate too.

    if (mounted) {
      // Cancel timer when navigating to avoid repeated calls if navigation delay?
      _timer.cancel();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.downloader, (route) => false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        width: context.width,
        height: context.height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: FadeTransition(
          opacity: _animation,
          child: const Image(
            width: 100,
            height: 100,
            fit: BoxFit.scaleDown,
            image: AssetImage(AppAssets.tikTokLogo),
          ),
        ),
      ),
    );
  }
}
