import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CenterProgressIndicator extends StatelessWidget {
  final int? percentage;
  const CenterProgressIndicator({super.key, this.percentage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.white),
          if (percentage != null) ...[
            const SizedBox(height: 12),
            Text(
              "$percentage%",
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
