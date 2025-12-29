import 'package:flutter/material.dart';

import '../../../../../core/utils/app_colors.dart';

class DownloaderBodyLogo extends StatelessWidget {
  const DownloaderBodyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cloud_download_rounded,
            size: 40,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
