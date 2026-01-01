import 'package:dio/dio.dart';

import '../../container_injector.dart';
import '../api/interceptors.dart';

class DioHelper {
  final Dio dio;

  DioHelper({required this.dio}) {
    dio.options = BaseOptions(
      receiveDataWhenStatusError: true,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Range': 'bytes=0-',
        'Accept-Language': 'en-US,en;q=0.9',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
    dio.interceptors.add(sl<LogInterceptor>());
    dio.interceptors.add(sl<AppInterceptors>());
  }

  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParams,
  }) async {
    return await dio.get(path, queryParameters: queryParams);
  }

  Future<Response> download({
    required String downloadLink,
    required String savePath,
    Map<String, dynamic>? queryParams,
    ProgressCallback? onReceiveProgress,
  }) async {
    final bool isTikTokLink = downloadLink.contains('tiktok.com');

    return await dio.download(
      downloadLink,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: Options(
        headers: {
          if (isTikTokLink) ...{
            'Referer': 'https://www.tiktok.com/',
            'Origin': 'https://www.tiktok.com',
          },
        },
      ),
    );
  }
}
