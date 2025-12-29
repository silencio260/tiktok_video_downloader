import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';

import '../../../../../config/routes_manager.dart';
import '../../../../../core/utils/app_enums.dart';

import '../../../../../core/widgets/build_toast.dart';
import '../../../../../core/widgets/center_indicator.dart';
import '../../bloc/downloader_bloc/downloader_bloc.dart';
import '../../../domain/entities/video_item.dart';
import '../download_bottom_sheet.dart';
import 'downloader_body_logo.dart';

class DownloaderScreenBody extends StatefulWidget {
  const DownloaderScreenBody({super.key});

  @override
  State<DownloaderScreenBody> createState() => _DownloaderScreenBodyState();
}

class _DownloaderScreenBodyState extends State<DownloaderScreenBody> {
  late final TextEditingController _videoLinkController;

  @override
  void initState() {
    super.initState();
    _videoLinkController = TextEditingController();
    context.read<DownloaderBloc>().add(LoadOldDownloads());
  }

  @override
  void dispose() {
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloaderBloc, DownloaderState>(
      listener: (context, state) {
        if (state is DownloaderSaveVideoLoading) {
          Navigator.of(context).popAndPushNamed(Routes.downloads);
        }
        if (state is DownloaderGetVideoFailure) {
          buildToast(msg: state.message, type: ToastType.error);
        }
        if (state is DownloaderGetVideoSuccess &&
            state.tikTokVideo.videoData == null) {
          buildToast(msg: state.tikTokVideo.msg, type: ToastType.error);
        }
        if (state is DownloaderGetVideoSuccess &&
            state.tikTokVideo.videoData != null) {
          buildDownloadBottomSheet(context, state.tikTokVideo);
        }
        if (state is DownloaderSaveVideoSuccess) {
          buildToast(msg: state.message, type: ToastType.success);
        }
        if (state is DownloaderSaveVideoFailure) {
          buildToast(msg: state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        return Container(
          alignment: AlignmentDirectional.topCenter,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const DownloaderBodyLogo(),
                  const SizedBox(height: 24),
                  Text(
                    "Save Video",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Paste a link from TikTok, Reels or Shorts below.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Input Field Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8, // Increased height
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black, // Pure black background
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.1),
                        width: 1.5, // Slightly more pronounced border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _videoLinkController,
                            style: const TextStyle(
                              color: AppColors.white,
                            ), // White text
                            cursorColor: AppColors.white,
                            decoration: const InputDecoration(
                              hintText: "Paste link here...",
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        _buildPasteButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  state is DownloaderGetVideoLoading
                      ? const CenterProgressIndicator()
                      : _buildBodyDownloadBtn(context),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How it works",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 40),
                  _buildRecentDownloadsSection(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasteButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Paste logic could be added here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.content_paste_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Paste",
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyDownloadBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          if (_videoLinkController.text.isNotEmpty) {
            context.read<DownloaderBloc>().add(
              DownloaderGetVideo(_videoLinkController.text),
            );
          } else {
            buildToast(msg: "Please enter a link", type: ToastType.error);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.file_download_outlined),
            const SizedBox(width: 8),
            const Text(
              "Download Video",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionCard(Icons.share, "Share"),
        _buildActionCard(Icons.content_copy, "Copy"),
        _buildActionCard(Icons.folder_open, "Files"),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDownloadsSection(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, state) {
        final List<VideoItem> recentDownloads = context
            .read<DownloaderBloc>()
            .oldDownloads;

        if (recentDownloads.isEmpty) {
          return const SizedBox.shrink();
        }

        final top3 = recentDownloads.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Downloads",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Routes.downloads),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Latest Card
            _buildLatestCard(top3[0]),
            if (top3.length > 1) ...[
              const SizedBox(height: 24),
              const Text(
                "EARLIER",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ...top3.skip(1).map((item) => _buildEarlierItem(item)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLatestCard(VideoItem item) {
    final fileName = item.path.split('/').last;
    final fileSize = (File(item.path).lengthSync() / (1024 * 1024))
        .toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.cardColor,
              image: item.thumbnailPath != null
                  ? DecorationImage(
                      image: FileImage(File(item.thumbnailPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "LATEST",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      "Recently",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDetailItem("SIZE", "$fileSize MB"),
                    const SizedBox(width: 24),
                    _buildDetailItem("TYPE", "MP4"),
                    const Spacer(),
                    const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEarlierItem(VideoItem item) {
    final fileName = item.path.split('/').last;
    final fileSize = (File(item.path).lengthSync() / (1024 * 1024))
        .toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.cardColor,
              image: item.thumbnailPath != null
                  ? DecorationImage(
                      image: FileImage(File(item.thumbnailPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.thumbnailPath == null
                ? const Icon(Icons.video_file_outlined, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$fileSize MB • Recent",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
