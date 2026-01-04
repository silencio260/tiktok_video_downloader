import 'package:flutter/material.dart';

import '../../core/base_feature.dart';

/// In-app feedback service
///
/// Captures user feedback before they leave bad reviews.
///
/// Usage:
/// ```dart
/// final feedback = FeedbackService();
/// await feedback.initialize();
///
/// // Show after low rating
/// await feedback.showFeedbackForm(context);
/// ```
class FeedbackService extends BaseFeature {
  /// Callback to submit feedback (inject your backend)
  Future<void> Function(FeedbackData data)? submitFeedback;

  /// Callback to show custom feedback UI
  Future<FeedbackData?> Function(BuildContext context)? showFeedbackUI;

  /// Callback for feedback events (for analytics)
  void Function(FeedbackEvent event)? onFeedbackEvent;

  @override
  Future<void> onInitialize() async {
    // Nothing special needed
  }

  /// Show feedback form and submit
  Future<void> showFeedbackForm(
    BuildContext context, {
    String? category,
  }) async {
    onFeedbackEvent?.call(FeedbackEvent.formOpened);

    FeedbackData? data;

    if (showFeedbackUI != null) {
      data = await showFeedbackUI!(context);
    } else {
      data = await _showDefaultDialog(context, category);
    }

    if (data != null && data.message.isNotEmpty) {
      await _submitFeedback(data);
    } else {
      onFeedbackEvent?.call(FeedbackEvent.formCancelled);
    }
  }

  Future<FeedbackData?> _showDefaultDialog(
    BuildContext context,
    String? category,
  ) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Feedback'),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tell us how we can improve...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Send'),
              ),
            ],
          ),
    );

    if (result == null || result.isEmpty) return null;

    return FeedbackData(
      message: result,
      category: category,
      timestamp: DateTime.now(),
    );
  }

  Future<void> _submitFeedback(FeedbackData data) async {
    try {
      if (submitFeedback != null) {
        await submitFeedback!(data);
      }
      onFeedbackEvent?.call(FeedbackEvent.submitted);
      print('FeedbackService: Feedback submitted');
    } catch (e) {
      onFeedbackEvent?.call(FeedbackEvent.submitFailed);
      print('FeedbackService: Submit failed: $e');
    }
  }

  @override
  Future<void> onDispose() async {}
}

class FeedbackData {
  final String message;
  final String? category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const FeedbackData({
    required this.message,
    this.category,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'message': message,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    ...?metadata,
  };
}

enum FeedbackEvent { formOpened, formCancelled, submitted, submitFailed }
