import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';
import 'package:tiktok_video_downloader/src/features/tiktok_downloader/domain/entities/video_item.dart';
import '../../bloc/downloader_bloc/downloader_bloc.dart';
import '../../../../../config/routes_manager.dart';

class DownloadsScreenBody extends StatefulWidget {
  const DownloadsScreenBody({super.key});

  @override
  State<DownloadsScreenBody> createState() => _DownloadsScreenBodyState();
}

class _DownloadsScreenBodyState extends State<DownloadsScreenBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, state) {
        final allDownloads = context.read<DownloaderBloc>().oldDownloads;
        final filteredDownloads = allDownloads.where((item) {
          final fileName = item.path.split('/').last.toLowerCase();
          return fileName.contains(_searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: filteredDownloads.isEmpty
                  ? _buildEmptyState()
                  : _buildDownloadsList(filteredDownloads),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22), // Darker grey for search
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search saved videos...",
            hintStyle: TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: AppColors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            "No videos found",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(List<VideoItem> items) {
    // Basic grouping (In a real app we'd use modified date)
    final todayItems = items.take(3).toList();
    final earlierItems = items.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (todayItems.isNotEmpty) ...[
          _buildSectionHeader("TODAY", "${todayItems.length} videos"),
          const SizedBox(height: 12),
          ...todayItems.map((item) => _buildVideoCard(item)),
        ],
        if (earlierItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader("LAST WEEK", "${earlierItems.length} videos"),
          const SizedBox(height: 12),
          ...earlierItems.map((item) => _buildVideoCard(item)),
        ],
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildVideoCard(VideoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).pushNamed(Routes.viewVideo, arguments: item.path),
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 0.8, // Adjust to match image (approx vertical)
          child: Container(
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
            child: Stack(
              children: [
                // Duration overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "0:15", // Placeholder duration
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Bottom controls
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
