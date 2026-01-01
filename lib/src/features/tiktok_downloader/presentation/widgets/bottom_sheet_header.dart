import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/video_data.dart';

class BottomSheetHeader extends StatelessWidget {
  final VideoData videoData;

  const BottomSheetHeader({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.network(
              videoData.originCover,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child: const Icon(
                  Icons.video_library,
                  color: Colors.white54,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            videoData.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 5,
          ),
        ),
      ],
    );
  }
}
