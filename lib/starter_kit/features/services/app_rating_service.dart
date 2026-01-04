import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/starter_kit_config.dart';
import '../../core/base_feature.dart';
import '../monetization/ads/ad_suppression_manager.dart';

/// Smart app rating service
///
/// Shows rating dialog at optimal moments based on configurable rules.
///
/// Usage:
/// ```dart
/// final ratingService = AppRatingService(
///   config: AppRatingConfig(
///     minAppOpens: 5,
///     minDaysAfterInstall: 3,
///     playStoreLink: 'https://play.google.com/store/apps/details?id=...',
///   ),
/// );
/// await ratingService.initialize();
///
/// // Call after successful action
/// await ratingService.trackSuccessfulAction(context);
/// ```
class AppRatingService extends BaseFeature {
  static const String _installDateKey = 'sk_rating_install_date';
  static const String _appOpensKey = 'sk_rating_app_opens';
  static const String _neverShowKey = 'sk_rating_never_show';
  static const String _lastShownKey = 'sk_rating_last_shown';
  static const String _successCountKey = 'sk_rating_success_count';

  final AppRatingConfig config;

  /// Callback for rating events (for analytics)
  void Function(RatingEvent event, {int? stars})? onRatingEvent;

  /// Callback to show your custom rating dialog
  /// Return the user's choice
  Future<RatingDialogResult?> Function(BuildContext context)? showRatingDialog;

  /// Callback to show feedback form (for low ratings)
  void Function(BuildContext context)? showFeedbackForm;

  AppRatingService({AppRatingConfig? config})
    : config = config ?? const AppRatingConfig();

  @override
  Future<void> onInitialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Set install date on first run
    if (!prefs.containsKey(_installDateKey)) {
      await prefs.setInt(
        _installDateKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // Increment app opens
    final opens = prefs.getInt(_appOpensKey) ?? 0;
    await prefs.setInt(_appOpensKey, opens + 1);
  }

  /// Track a successful action and maybe show rating
  Future<void> trackSuccessfulAction(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_successCountKey) ?? 0;
    await prefs.setInt(_successCountKey, count + 1);

    // Show after 2 successful actions
    if (count + 1 == 2) {
      await showRatingIfEligible(context, force: true);
    }
  }

  /// Show rating dialog if conditions are met
  Future<void> showRatingIfEligible(
    BuildContext context, {
    bool force = false,
  }) async {
    if (!force && !await _meetsConditions()) return;

    // Suppress ads during rating
    await AdSuppressionManager().withAdsSuppressed(
      reason: 'rating_dialog',
      action: () async {
        final result = await _showDialog(context);
        await _handleResult(context, result);
      },
    );
  }

  Future<bool> _meetsConditions() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user said "never"
    if (prefs.getBool(_neverShowKey) ?? false) return false;

    final installDate = prefs.getInt(_installDateKey) ?? 0;
    final appOpens = prefs.getInt(_appOpensKey) ?? 0;
    final lastShown = prefs.getInt(_lastShownKey) ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final msPerDay = 24 * 60 * 60 * 1000;

    final daysSinceInstall = (now - installDate) ~/ msPerDay;
    final daysSinceLastShown = (now - lastShown) ~/ msPerDay;

    return daysSinceInstall >= config.minDaysAfterInstall &&
        appOpens >= config.minAppOpens &&
        daysSinceLastShown >= config.minDaysBetweenReviews;
  }

  Future<RatingDialogResult?> _showDialog(BuildContext context) async {
    if (showRatingDialog != null) {
      return await showRatingDialog!(context);
    }

    // Default: use in_app_review directly for 5-star prompt
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      return RatingDialogResult(action: RatingAction.submitted, stars: 5);
    }

    return null;
  }

  Future<void> _handleResult(
    BuildContext context,
    RatingDialogResult? result,
  ) async {
    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();

    switch (result.action) {
      case RatingAction.submitted:
        await prefs.setBool(_neverShowKey, true);
        onRatingEvent?.call(RatingEvent.submitted, stars: result.stars);

        if (result.stars != null && result.stars! >= 4) {
          await _launchStore();
        } else if (result.stars != null && result.stars! < 4) {
          showFeedbackForm?.call(context);
        }
        break;

      case RatingAction.later:
        await _snooze(prefs);
        onRatingEvent?.call(RatingEvent.later);
        break;

      case RatingAction.never:
        await prefs.setBool(_neverShowKey, true);
        onRatingEvent?.call(RatingEvent.never);
        break;
    }
  }

  Future<void> _snooze(SharedPreferences prefs) async {
    // Set last shown such that it will be eligible after snoozeDays
    final now = DateTime.now().millisecondsSinceEpoch;
    final msPerDay = 24 * 60 * 60 * 1000;
    final effectiveLastShown =
        now - ((config.minDaysBetweenReviews - config.snoozeDays) * msPerDay);
    await prefs.setInt(_lastShownKey, effectiveLastShown);
  }

  Future<void> _launchStore() async {
    final link = config.playStoreLink ?? config.appStoreLink;
    if (link == null) return;

    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Reset all rating data (for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_installDateKey);
    await prefs.remove(_appOpensKey);
    await prefs.remove(_neverShowKey);
    await prefs.remove(_lastShownKey);
    await prefs.remove(_successCountKey);
  }

  @override
  Future<void> onDispose() async {}
}

enum RatingAction { submitted, later, never }

enum RatingEvent { submitted, later, never }

class RatingDialogResult {
  final RatingAction action;
  final int? stars;

  const RatingDialogResult({required this.action, this.stars});
}
