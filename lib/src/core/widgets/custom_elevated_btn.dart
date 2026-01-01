import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomElevatedBtn extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final double? width;

  const CustomElevatedBtn({
    super.key,
    this.onPressed,
    required this.label,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: width ?? MediaQuery.of(context).size.width / 2,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
