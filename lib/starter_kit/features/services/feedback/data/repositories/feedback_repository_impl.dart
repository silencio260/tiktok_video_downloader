import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tiktok_video_downloader/starter_kit/core/error/failure.dart';
import 'package:tiktok_video_downloader/starter_kit/features/services/feedback/domain/repositories/feedback_repository.dart';

/// Feedback repository that launches an email client
class EmailFeedbackRepositoryImpl implements FeedbackRepository {
  final String supportEmail;

  EmailFeedbackRepositoryImpl({required this.supportEmail});

  @override
  Future<Either<Failure, void>> submitFeedback(
    String text, {
    String? email,
  }) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: {'subject': 'App Feedback', 'body': text},
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        return const Right(null);
      } else {
        return Left(ConfigurationFailure(message: 'No email client found'));
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
