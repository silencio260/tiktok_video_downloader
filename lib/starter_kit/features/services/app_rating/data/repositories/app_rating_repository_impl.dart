import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failure.dart';
import '../../domain/repositories/app_rating_repository.dart';

class AppRatingRepositoryImpl implements AppRatingRepository {
  final InAppReview _inAppReview = InAppReview.instance;

  static const String _kInstallDate = 'sk_rating_install_date';
  static const String _kAppOpens = 'sk_rating_app_opens';
  static const String _kLastPrompt = 'sk_rating_last_prompt';

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_kInstallDate)) {
        await prefs.setInt(
          _kInstallDate,
          DateTime.now().millisecondsSinceEpoch,
        );
        await prefs.setInt(_kAppOpens, 0);
      }

      final opens = prefs.getInt(_kAppOpens) ?? 0;
      await prefs.setInt(_kAppOpens, opens + 1);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEligibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final installDateMs = prefs.getInt(_kInstallDate) ?? 0;
      final installDate = DateTime.fromMillisecondsSinceEpoch(installDateMs);
      final daysInstalled = DateTime.now().difference(installDate).inDays;
      final appOpens = prefs.getInt(_kAppOpens) ?? 0;

      // Logic: 3 days installed + 5 app opens
      if (daysInstalled >= 3 && appOpens >= 5) {
        if (await _inAppReview.isAvailable()) {
          return const Right(true);
        }
      }
      return const Right(false);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kLastPrompt, DateTime.now().millisecondsSinceEpoch);
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
