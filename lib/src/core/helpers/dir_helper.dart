import 'dart:io';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class DirHelper {
  static Future<String> getAppPath() async {
    String mainPath = await _getMainPath();
    String appPath = "$mainPath/TikTokVideos";
    await _createPathIfNotExist(appPath);
    return appPath;
  }

  static Future<String> _getMainPath() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      return dir!.path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  static Future<void> _createPathIfNotExist(String path) async {
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
  }

  static Future<void> saveVideoToGallery(videoPath) async {
    await Gal.putVideo(videoPath, album: 'TikTok_downloads');
  }

  static Future<void> removeFileFromDownloadsDir(videoPath) async {
    await File(videoPath).delete();
  }
}
