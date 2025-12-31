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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E), // Dark grey for search
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
            hintText: "Search saved videos",
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 24,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
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
            color: AppColors.white.withOpacity(0.1),
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Vertical orientation
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildVideoCard(items[index]);
      },
    );
  }

  Widget _buildVideoCard(VideoItem item) {
    final fileName = item.path.split('/').last;

    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).pushNamed(Routes.viewVideo, arguments: item.path),
      borderRadius: BorderRadius.circular(24),
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
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            // Text Content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "0:15", // Placeholder duration
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
