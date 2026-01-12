import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../starter_kit.dart';
import '../bloc/ads_bloc.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final String? adUnitId;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner, this.adUnitId});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  String? _currentAdUnitId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoad();
  }

  void _checkAndLoad() {
    final state = StarterKit.adsBloc.state;
    final adUnitId = widget.adUnitId ?? state.config?.bannerAdUnitId;

    if (adUnitId != null &&
        adUnitId.isNotEmpty &&
        adUnitId != _currentAdUnitId) {
      _currentAdUnitId = adUnitId;
      _loadAd(adUnitId);
    }
  }

  void _loadAd(String adUnitId) {
    _bannerAd?.dispose();
    _isLoaded = false;
    _bannerAd = null;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: Failed to load ad: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      bloc: StarterKit.adsBloc,
      builder: (context, state) {
        final newAdUnitId = widget.adUnitId ?? state.config?.bannerAdUnitId;
        if (newAdUnitId != null &&
            newAdUnitId.isNotEmpty &&
            newAdUnitId != _currentAdUnitId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _currentAdUnitId = newAdUnitId;
              _loadAd(newAdUnitId);
            }
          });
        }

        if (_bannerAd == null || !_isLoaded) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
