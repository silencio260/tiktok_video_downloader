import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../starter_kit.dart';

class NativeAdWidget extends StatefulWidget {
  final String? adUnitId;
  final NativeTemplateStyle? templateStyle;

  const NativeAdWidget({super.key, this.adUnitId, this.templateStyle});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId =
        widget.adUnitId ?? StarterKit.adsBloc.state.config?.nativeAdUnitId;

    if (adUnitId == null || adUnitId.isEmpty) {
      debugPrint('NativeAdWidget: No ad unit ID provided');
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      factoryId:
          'adFactoryExample', // This needs to be set up on the native side if not using templates
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAdWidget: Failed to load ad: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle:
          widget.templateStyle ??
          NativeTemplateStyle(
            templateType: TemplateType.small,
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
    if (_nativeAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320,
        minHeight: 90,
        maxWidth: 400,
        maxHeight: 200,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
