import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        final status = await Permission.videos.status;
        if (status.isGranted) return true;

        final request = await Permission.videos.request();
        return request.isGranted;
      } else {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        final request = await Permission.storage.request();
        return request.isGranted;
      }
    }
    return true; // iOS permissions handled by Info.plist and gal package
  }
}
