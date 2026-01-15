import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../starter_kit/features/settings/domain/models/settings_models.dart';
import '../../../../../starter_kit/starter_kit.dart';
import '../../../../../starter_kit/features/services/app_rating/domain/repositories/app_rating_repository.dart';
import '../../../../../starter_kit/features/services/feedback/domain/repositories/feedback_repository.dart';
import '../../../../config/routes_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: StarterKit.settings(
        title: "Settings",
        backgroundColor: AppColors.primaryColor,
        sections: [
          SettingsSection(
            title: "General",
            tiles: [
              SettingsTile(
                title: "Privacy Policy",
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.white,
                onTap: () {
                  _launchUrl(
                    'https://www.google.com',
                  ); // Replace with actual policy URL
                },
              ),
              SettingsTile(
                title: "Share App",
                icon: Icons.share_outlined,
                iconColor: AppColors.white,
                onTap: () {
                  Share.share(
                    'Check out this amazing TikTok Video Downloader!',
                  );
                },
              ),
              SettingsTile(
                title: "Rate Us",
                icon: Icons.star_border_outlined,
                iconColor: AppColors.white,
                onTap: () {
                  // Trigger rating flow
                  final ratingRepo = StarterKit.sl<AppRatingRepository>();
                  ratingRepo.requestReview();
                },
              ),
              SettingsTile(
                title: "Feedback",
                icon: Icons.feedback_outlined,
                iconColor: AppColors.white,
                onTap: () {
                  // Trigger feedback flow
                  _showFeedbackDialog(context);
                },
              ),
            ],
          ),
          SettingsSection(
            title: "About",
            tiles: [
              SettingsTile(
                title: "Version",
                subtitle: _version,
                icon: Icons.info_outline,
                iconColor: AppColors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Send Feedback"),
            content: TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: "Enter your feedback here...",
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (feedbackController.text.isNotEmpty) {
                    final feedbackRepo = StarterKit.sl<FeedbackRepository>();
                    await feedbackRepo.submitFeedback(feedbackController.text);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thanks for your feedback!"),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Send"),
              ),
            ],
          ),
    );
  }
}
