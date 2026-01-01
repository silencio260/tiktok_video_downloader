import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../../../config/routes_manager.dart';
import '../../../../core/media_query.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/utils/app_strings.dart';

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

  navigateToNextScreen() async {
    _timer.cancel();

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final bool onboardingComplete =
          prefs.getBool('onboarding_complete') ?? false;

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          onboardingComplete ? Routes.downloader : Routes.onboarding,
          (route) => false,
        );
      }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppColors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.cloud_download_rounded,
                    size: 80,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
