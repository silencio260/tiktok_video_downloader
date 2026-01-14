import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../starter_kit.dart';
import '../../../../../src/config/environment_vars.dart';
import '../../../analytics/domain/entities/ad_revenue_event.dart';
import '../../domain/services/ad_suppression_manager.dart';
import '../../../iap/presentation/bloc/iap_bloc.dart';
import '../../domain/repositories/ads_repository.dart';
import '../bloc/ads_bloc.dart';

class NativeAdWidget extends StatefulWidget {
  final String? adUnitId;
  final NativeTemplateStyle? templateStyle;
  final double? width;
  final double? height;

  const NativeAdWidget({
    super.key,
    this.adUnitId,
    this.templateStyle,
    this.width,
    this.height,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  String? _currentAdUnitId;
  int _retryCount = 0;
  static const int _maxRetries = 2;
  TemplateType _currentTemplateType = TemplateType.medium;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoad();
  }

  void _checkAndLoad() {
    final state = StarterKit.adsBloc.state;
    final adUnitId = widget.adUnitId ?? state.config?.nativeAdUnitId;

    if (adUnitId != null &&
        adUnitId.isNotEmpty &&
        adUnitId != _currentAdUnitId) {
      _currentAdUnitId = adUnitId;
      _retryCount = 0;
      _currentTemplateType = TemplateType.medium;
      _loadAd(adUnitId);
    }
  }

  void _loadAd(String adUnitId) {
    _nativeAd?.dispose();
    _isLoaded = false;
    _nativeAd = null;

    debugPrint('NativeAdWidget: Loading ad for unit: $adUnitId');

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('NativeAdWidget: Ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _retryCount = 0;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAdWidget: Failed to load ad: $error');
          ad.dispose();

          if (mounted) {
            setState(() {
              _isLoaded = false;
              _nativeAd = null;
            });

            // Retry logic for No Fill (3) or Internal Error (0)
            if (_retryCount < _maxRetries) {
              _retryCount++;

              // If medium fails with internal error, try small template
              if (_currentTemplateType == TemplateType.medium) {
                _currentTemplateType = TemplateType.small;
                debugPrint(
                  'NativeAdWidget: Switching to Small template for retry',
                );
              }

              debugPrint(
                'NativeAdWidget: Retrying load (attempt $_retryCount)...',
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted && _currentAdUnitId != null) {
                  _loadAd(_currentAdUnitId!);
                }
              });
            }
          }
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {
          StarterKit.sl<AdsRepository>().recordAdRevenue(
            AdRevenueEvent(
              value: valueMicros / 1000000.0,
              valueMicros: valueMicros,
              currency: currencyCode,
              adSource: 'AdMob',
              adUnitId: ad.adUnitId,
              adFormat: 'native',
            ),
          );
        },
      ),
      nativeTemplateStyle:
          widget.templateStyle ??
          NativeTemplateStyle(
            templateType: _currentTemplateType,
            mainBackgroundColor: const Color(0xFF1E1E1E),
            cornerRadius: 15.0,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              backgroundColor: const Color(0xFF3B82F6),
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              style: NativeTemplateFontStyle.bold,
              size: 16.0,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white70,
              style: NativeTemplateFontStyle.normal,
              size: 14.0,
            ),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white60,
              style: NativeTemplateFontStyle.normal,
              size: 12.0,
            ),
          ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IapBloc, IapState>(
      bloc: StarterKit.iapBloc,
      builder: (context, iapState) {
        if (StarterKit.iapBloc.isPremium) {
          return const SizedBox.shrink();
        }

        return ListenableBuilder(
          listenable: AdSuppressionManager.instance,
          builder: (context, _) {
            if (AdSuppressionManager.instance.areAdsSuppressed) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<AdsBloc, AdsState>(
              bloc: StarterKit.adsBloc,
              builder: (context, state) {
                final newAdUnitId =
                    widget.adUnitId ?? state.config?.nativeAdUnitId;
                if (newAdUnitId != null &&
                    newAdUnitId.isNotEmpty &&
                    newAdUnitId != _currentAdUnitId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _currentAdUnitId = newAdUnitId;
                      _retryCount = 0;
                      _loadAd(newAdUnitId);
                    }
                  });
                }

                if (_nativeAd == null || !_isLoaded) {
                  // Only show loading placeholder in debug/dev mode
                  if (kDebugMode || EnvironmentsVar.isDeveloperMode) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: widget.width ?? 320,
                      height: widget.height ?? 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white24,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: widget.width ?? 320,
                      minHeight: widget.height ?? 150,
                      maxWidth: widget.width ?? 400,
                      maxHeight: widget.height ?? 320,
                    ),
                    child: AdWidget(ad: _nativeAd!),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
