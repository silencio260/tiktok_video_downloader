import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_video_downloader/src/core/utils/app_colors.dart';
import 'package:tiktok_video_downloader/starter_kit/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:tiktok_video_downloader/starter_kit/features/services/gdpr/domain/repositories/gdpr_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tiktok_video_downloader/starter_kit/features/services/app_rating/domain/repositories/app_rating_repository.dart';
import 'package:tiktok_video_downloader/starter_kit/features/services/feedback/domain/repositories/feedback_repository.dart';
import 'package:tiktok_video_downloader/starter_kit/features/settings/domain/models/settings_models.dart';
import 'package:tiktok_video_downloader/starter_kit/starter_kit.dart';
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

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', false);
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.onboarding, (route) => false);
    }
  }

  Future<void> _resetGDPR() async {
    final gdprRepo = StarterKit.sl<GdprRepository>();
    await gdprRepo.resetConsent();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GDPR Consent reset.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IapBloc, IapState>(
      bloc: StarterKit.iapBloc,
      builder: (context, iapState) {
        final isPremium = StarterKit.iapBloc.isPremium;

        return StarterKit.settings(
          title: "Settings",
          backgroundColor: AppColors.primaryColor,
          sections: [
            // --- User / Premium Section ---
            SettingsSection(
              title: "Account",
              tiles: [
                if (!isPremium)
                  SettingsTile(
                    title: "Upgrade to Premium",
                    subtitle: "Remove ads & unlock all features",
                    icon: Icons.workspace_premium,
                    iconColor: Colors.amber,
                    onTap: () {
                      // Navigate to Paywall or trigger purchase flow
                      // TODO: Implement Paywall navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paywall Coming Soon')),
                      );
                    },
                  )
                else
                  SettingsTile(
                    title: "Premium Active",
                    subtitle: "You are a premium user",
                    icon: Icons.verified,
                    iconColor: Colors.green,
                    onTap: () {}, // No action needed
                  ),
              ],
            ),

            // --- General Section ---
            SettingsSection(
              title: "General",
              tiles: [
                SettingsTile(
                  title: "Privacy Policy",
                  icon: Icons.privacy_tip_outlined,
                  iconColor: AppColors.white,
                  onTap: () => _launchUrl('https://www.google.com'),
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
                  icon: Icons.star_border,
                  iconColor: AppColors.white,
                  onTap: () {
                    final ratingRepo = StarterKit.sl<AppRatingRepository>();
                    ratingRepo.openStoreListing();
                  },
                ),
                SettingsTile(
                  title: "Feedback",
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.white,
                  onTap: () => _showFeedbackDialog(context),
                ),
              ],
            ),

            // --- Developer Section (Debug Only) ---
            if (kDebugMode)
              SettingsSection(
                title: "Developer Options",
                tiles: [
                  SettingsTile(
                    title: "Reset Onboarding",
                    icon: Icons.restart_alt,
                    iconColor: Colors.orange,
                    onTap: _resetOnboarding,
                  ),
                  SettingsTile(
                    title: "Reset GDPR Consent",
                    icon: Icons.cookie_outlined,
                    iconColor: Colors.orange,
                    onTap: _resetGDPR,
                  ),
                  SettingsTile(
                    title: "Toggle Premium Status (Debug)",
                    icon: Icons.diamond_outlined,
                    iconColor: Colors.purpleAccent,
                    onTap: () {
                      StarterKit.iapBloc.add(const IapDebugTogglePremium());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Toggled Premium Status")),
                      );
                    },
                  ),
                ],
              ),

            // --- About ---
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
        );
      },
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
            backgroundColor: AppColors.cardColor,
            title: const Text(
              "Send Feedback",
              style: TextStyle(color: AppColors.white),
            ),
            content: TextField(
              controller: feedbackController,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: "Enter your feedback here...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF2C2C2C), // Dark grey background
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.white),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (feedbackController.text.isNotEmpty) {
                    final feedbackRepo = StarterKit.sl<FeedbackRepository>();
                    // We use the configured repo (Nest or Email)
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
                child: const Text(
                  "Send",
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
    );
  }
}
