import 'package:flutter/material.dart';
import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';

import '../../../../../core/utils/app_strings.dart';

class DownloaderBodyInputField extends StatelessWidget {
  final TextEditingController videoLinkController;
  final GlobalKey<FormState> formKey;
  const DownloaderBodyInputField({
    super.key,
    required this.videoLinkController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Form(
        key: formKey,
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: videoLinkController,
                keyboardType: TextInputType.url,
                style: const TextStyle(color: AppColors.white, fontSize: 16),
                cursorColor: AppColors.white,
                validator: (String? value) {
                  if (value!.isEmpty) return AppStrings.videoLinkRequired;
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: AppStrings.inputLinkFieldText,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
