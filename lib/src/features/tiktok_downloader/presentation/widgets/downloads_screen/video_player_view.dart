import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/utils/app_colors.dart';

class VideoPlayerView extends StatefulWidget {
  final String videoPath;
  const VideoPlayerView({super.key, required this.videoPath});

  @override
  VideoPlayerViewState createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: true,
          allowFullScreen: true,
          allowPlaybackSpeedChanging: false,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.pink,
            handleColor: AppColors.pink,
            backgroundColor: AppColors.grey.withOpacity(0.2),
            bufferedColor: AppColors.grey.withOpacity(0.1),
          ),
        );
        setState(() {}); // Refresh to show video
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    if (_videoPlayerController.value.isInitialized) {
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: Chewie(controller: _chewieController),
                    )
                  : const CircularProgressIndicator(color: AppColors.white),
            ),
            // Header Controls
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.black,
                      child: Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Share.shareXFiles([XFile(widget.videoPath)]);
                    },
                    child: const CircleAvatar(
                      backgroundColor: AppColors.black,
                      child: Icon(Icons.share, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
