import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../../core/helpers/dir_helper.dart';
import '../../../../../core/helpers/permissions_helper.dart';
import '../../../../../core/utils/app_enums.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../domain/entities/download_item.dart';
import '../../../domain/entities/tiktok_video.dart';
import '../../../domain/entities/video_item.dart';
import '../../../domain/entities/video_data.dart';
import '../../../domain/usecases/get_video_usecase.dart';
import '../../../domain/usecases/save_video_usecase.dart';

part 'downloader_event.dart';

part 'downloader_state.dart';

class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  final GetVideoUseCase getVideoUseCase;
  final SaveVideoUseCase saveVideoUseCase;

  DownloaderBloc({
    required this.getVideoUseCase,
    required this.saveVideoUseCase,
  }) : super(DownloaderInitial()) {
    on<LoadOldDownloads>(_loadOldDownloads);
    on<DownloaderGetVideo>(_getVideo);
    on<DownloaderSaveVideo>(_saveVideo);
    on<DownloaderReportProgress>(_onReportProgress);

    // Initial load
    add(LoadOldDownloads());
  }

  List<DownloadItem> newDownloads = [];

  Future<void> _getVideo(
    DownloaderGetVideo event,
    Emitter<DownloaderState> emit,
  ) async {
    emit(const DownloaderGetVideoLoading());
    final result = await getVideoUseCase(event.videoLink);
    result.fold(
      (left) => emit(DownloaderGetVideoFailure(left.message)),
      (right) => emit(DownloaderGetVideoSuccess(right)),
    );
  }

  Future<void> _saveVideo(
    DownloaderSaveVideo event,
    Emitter<DownloaderState> emit,
  ) async {
    bool checkPermissions = await PermissionsHelper.checkPermission();
    if (!checkPermissions) {
      emit(const DownloaderSaveVideoFailure(AppStrings.permissionsRequired));
      return;
    }
    final path = await _generatePath(event.tikTokVideo.videoData!);
    final link = _processLink(event.tikTokVideo.videoData!.playVideo);
    DownloadItem item = DownloadItem(
      video: event.tikTokVideo,
      status: DownloadStatus.downloading,
      path: path,
    );
    int lastPercentage = -1;
    SaveVideoParams params = SaveVideoParams(
      savePath: path,
      videoLink: link,
      onProgress: (received, total) {
        if (total != -1) {
          final int percentage = ((received / total) * 100).floor();
          if (percentage != lastPercentage) {
            lastPercentage = percentage;
            add(DownloaderReportProgress(percentage));
          }
        }
      },
    );
    int index = _checkIfItemIsExistInDownloads(item);
    _addItem(index, item);
    emit(const DownloaderSaveVideoLoading());

    final result = await saveVideoUseCase(params);
    result.fold(
      (failure) {
        _updateItem(index, item.copyWith(status: DownloadStatus.error));
        emit(DownloaderSaveVideoFailure(failure.message));
      },
      (right) async {
        _updateItem(index, item.copyWith(status: DownloadStatus.success));
        await DirHelper.saveVideoToGallery(path);
        add(LoadOldDownloads()); // Refresh the list
        emit(DownloaderSaveVideoSuccess(message: right, path: path));
      },
    );
  }

  void _onReportProgress(
    DownloaderReportProgress event,
    Emitter<DownloaderState> emit,
  ) {
    emit(DownloaderSaveVideoProgress(event.percent));
  }

  String _processLink(String link) {
    // We should not append .mp4 manually as it can break URLs with query parameters
    // and most TikTok CDN links already point to the video binary.
    return link;
  }

  Future<String> _generatePath(VideoData videoData) async {
    final appPath = await DirHelper.getAppPath();
    final String author = videoData.authorName ?? "TikTok";
    final sanitizedAuthor = author.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return "$appPath/${sanitizedAuthor}_${videoData.id}.mp4";
  }

  _updateItem(int index, DownloadItem item) {
    if (index == -1) {
      newDownloads.last = item;
    } else {
      newDownloads[index] = item;
    }
  }

  _addItem(int index, DownloadItem item) {
    if (index == -1) {
      newDownloads.add(item);
    } else {
      newDownloads[index] = item.copyWith(status: DownloadStatus.downloading);
    }
  }

  int _checkIfItemIsExistInDownloads(DownloadItem item) {
    int index = -1;
    for (int i = 0; i < newDownloads.length; i++) {
      if (newDownloads[i].video == item.video) {
        index = i;
        return index;
      }
    }
    return index;
  }

  List<VideoItem> oldDownloads = [];

  Future<void> _loadOldDownloads(
    LoadOldDownloads event,
    Emitter<DownloaderState> emit,
  ) async {
    // Only emit loading if we don't have items yet to make it feel instant on return
    if (oldDownloads.isEmpty) {
      emit(const OldDownloadsLoading());
    }

    final path = await DirHelper.getAppPath();
    final directory = Directory(path);
    if (!await directory.exists()) {
      emit(const OldDownloadsLoadingSuccess(downloads: []));
      return;
    }

    final files = await directory.list().toList();

    // Sort files by modified date descending
    files.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    final List<Future<VideoItem>> futures = [];
    for (final file in files) {
      if (file is File && file.path.endsWith('.mp4')) {
        futures.add(_createVideoItem(file.path));
      }
    }

    oldDownloads = await Future.wait(futures);
    emit(OldDownloadsLoadingSuccess(downloads: oldDownloads));
  }

  Future<VideoItem> _createVideoItem(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      quality: 30,
    );
    return VideoItem(path: videoPath)..thumbnailPath = thumbnailPath;
  }
}
