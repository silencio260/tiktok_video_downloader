import 'package:flutter/material.dart';
import '../../../../../config/routes_manager.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';

class DownloaderScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DownloaderScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.settings_outlined, color: AppColors.white),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.settings);
        },
      ),
      title: Text(
        AppStrings.appName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.downloads);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
