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
        title: const Text("My Downloads"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Select",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: const DownloadsScreenBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pop(), // Go back to home/downloader
        backgroundColor: const Color(0xFF2D68FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
