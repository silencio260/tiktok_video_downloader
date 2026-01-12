import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../starter_kit.dart';
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
      ),
      nativeTemplateStyle:
          widget.templateStyle ??
          NativeTemplateStyle(
            templateType: TemplateType.medium,
            mainBackgroundColor: Colors.white,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.white,
              backgroundColor: Colors.blue,
              style: NativeTemplateFontStyle.normal,
              size: 16.0,
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
    return BlocBuilder<AdsBloc, AdsState>(
      bloc: StarterKit.adsBloc,
      builder: (context, state) {
        final newAdUnitId = widget.adUnitId ?? state.config?.nativeAdUnitId;
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
          return const SizedBox.shrink();
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
  }
}
