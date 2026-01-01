import 'package:dio/dio.dart';
import 'package:tiktok_scraper/tiktok_scraper.dart';
import '../../../../../core/helpers/dio_helper.dart';
import '../../../../../core/utils/app_strings.dart';
import 'package:tiktok_scraper/enums.dart';
import '../../models/tiktok_video_model.dart';
import '../../models/video_data_model.dart';

abstract class TiktokVideoBaseRemoteDataSource {
  Future<TiktokVideoModel> getVideo(String videoLink);

  Future<String> saveVideo({
    required String videoLink,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  });
}

class TiktokVideoRemoteDataSource implements TiktokVideoBaseRemoteDataSource {
  final DioHelper dioHelper;

  TiktokVideoRemoteDataSource({required this.dioHelper});

  @override
  Future<TiktokVideoModel> getVideo(String videoLink) async {
    try {
      final video = await TiktokScraper.getVideoInfo(
        videoLink,
        source: ScrapeVideoSource.TikDownloader,
      );

      // Prefer links that aren't on the TikTok CDN for better compatibility
      String downloadUrl = video.downloadUrls.isNotEmpty
          ? video.downloadUrls.first
          : "";

      for (var url in video.downloadUrls) {
        if (!url.contains("tiktok.com") && url.startsWith("http")) {
          downloadUrl = url;
          break;
        }
      }

      return TiktokVideoModel(
        code: 0,
        msg: "success",
        processedTime: 0.0,
        videoData: VideoDataModel(
          id: video.id,
          duration: video.duration,
          title: video.description,
          originCover: video.thumbnail,
          playVideo: downloadUrl,
          wmPlayVideo: video.downloadUrls.length > 1
              ? video.downloadUrls.last
              : downloadUrl,
          music: video.audioUrl,
          playCount: 0,
          downloadCount: 0,
          authorName: video.author.name,
        ),
      );
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<String> saveVideo({
    required String videoLink,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await dioHelper.download(
        savePath: savePath,
        downloadLink: videoLink,
        onReceiveProgress: onReceiveProgress,
      );
      return AppStrings.downloadSuccess;
    } catch (error) {
      rethrow;
    }
  }
}
