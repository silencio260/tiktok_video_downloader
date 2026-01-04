import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:tiktok_video_downloader/starter_kit/core/error/failure.dart';
import 'package:tiktok_video_downloader/starter_kit/core/utils/dev_mode_utils.dart';
import '../../domain/repositories/gdpr_repository.dart';

class GdprRepositoryImpl implements GdprRepository {
  final ConsentInformation _consentInformation = ConsentInformation.instance;

  @override
  Future<Either<Failure, void>> requestConsent() async {
    final Completer<Either<Failure, void>> completer = Completer();

    try {
      final params = ConsentRequestParameters(
        consentDebugSettings:
            DevModeUtils.isDebugMode
                ? ConsentDebugSettings(
                  debugGeography: DebugGeography.debugGeographyEea,
                  testIdentifiers: [
                    'TEST-DEVICE-HASHED-ID',
                  ], // TODO: Make configurable
                )
                : null,
      );

      _consentInformation.requestConsentInfoUpdate(
        params,
        () async {
          try {
            if (await _consentInformation.isConsentFormAvailable()) {
              await _loadAndShowConsentForm();
            }
          } catch (e) {
            debugPrint('GDPR Form Load Error: $e');
          } finally {
            if (!completer.isCompleted) {
              completer.complete(const Right(null));
            }
          }
        },
        (FormError error) {
          if (!completer.isCompleted) {
            debugPrint('GDPR Error: ${error.message}');
            completer.complete(const Right(null));
          }
        },
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(Left(ConfigurationFailure(message: e.toString())));
      }
    }

    return completer.future;
  }

  Future<void> _loadAndShowConsentForm() async {
    final Completer<void> completer = Completer();

    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await _consentInformation.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            if (formError == null) {
              // Check status again if needed, or simply reload/recurse
              // For simplicity in this flow, we'll confirm completion.
              // If enforcing strict required consent, we might recurse here.
              if (!completer.isCompleted) completer.complete();
            } else {
              if (!completer.isCompleted) completer.complete();
            }
          });
        } else {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError formError) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  @override
  Future<Either<Failure, bool>> isConsentGiven() async {
    final status = await _consentInformation.getConsentStatus();
    return Right(status == ConsentStatus.obtained);
  }

  @override
  Future<Either<Failure, void>> resetConsent() async {
    await _consentInformation.reset();
    return const Right(null);
  }
}
