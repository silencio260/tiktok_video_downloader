import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../widgets/downloads_screen/downloads_screen_body.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          "Downloads",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Edit",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SafeArea(child: DownloadsScreenBody()),
    );
  }
}
