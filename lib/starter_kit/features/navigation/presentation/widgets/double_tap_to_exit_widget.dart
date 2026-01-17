import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import '../../domain/models/double_tap_config.dart';

/// A customizable wrapper widget that implements double tap to exit functionality
/// with a configurable exit dialog on first back tap.
class DoubleTapToExitWidget extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;
  
  /// Configuration for customizing the exit dialog and behavior
  final DoubleTapExitConfig config;
  
  const DoubleTapToExitWidget({
    Key? key,
    required this.child,
    this.config = const DoubleTapExitConfig(),
  }) : super(key: key);

  Future<bool?> _showExitDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: config.dialogShape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        backgroundColor: config.dialogBackgroundColor,
        title: Text(
          config.dialogTitle,
          style: config.titleTextStyle ??
              TextStyle(
                color: config.titleColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        content: Text(
          config.dialogContent,
          style: config.contentTextStyle ??
              TextStyle(
                color: config.contentColor ?? Colors.white,
                fontSize: 16,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay in app
            style: TextButton.styleFrom(
              foregroundColor: config.cancelButtonTextColor ?? Colors.white,
              backgroundColor: config.cancelButtonColor,
            ),
            child: Text(
              config.cancelButtonText,
              style: config.cancelButtonTextStyle ??
                  TextStyle(
                    color: config.cancelButtonTextColor ?? Colors.white,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close dialog first
              SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // Exit app
            },
            style: TextButton.styleFrom(
              foregroundColor: config.confirmButtonTextColor ?? Colors.white,
              backgroundColor: config.confirmButtonColor,
            ),
            child: Text(
              config.confirmButtonText,
              style: config.confirmButtonTextStyle ??
                  TextStyle(
                    color: config.confirmButtonTextColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapToExit(
      snackBar: SnackBar(
        content: Text(
          config.snackBarMessage ?? 'Tap back again to exit',
          style: config.snackBarTextStyle ??
              TextStyle(
                color: config.snackBarTextColor ?? Colors.white,
              ),
        ),
        backgroundColor: config.snackBarBackgroundColor,
        duration: config.snackBarDuration,
      ),
      child: PopScope(
        canPop: false, // Prevents app from closing automatically
        onPopInvoked: (didPop) async {
          if (didPop) return;

          bool? exitApp = await _showExitDialog(context);
          if (exitApp == true) {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: child,
      ),
    );
  }
}
