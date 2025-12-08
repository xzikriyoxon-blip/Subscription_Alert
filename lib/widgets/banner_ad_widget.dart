import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// A widget that displays a banner ad at the bottom of a screen.
/// 
/// Automatically handles ad loading and displays a placeholder while loading.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    final bannerAd = _adService.bannerAd;
    
    if (bannerAd == null || !_adService.isBannerAdLoaded) {
      // Return empty container with fixed height to prevent layout shifts
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}

/// A scaffold wrapper that includes a banner ad at the bottom.
/// 
/// Use this instead of regular Scaffold to automatically show banner ads.
class AdScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool showBannerAd;

  const AdScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.showBannerAd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      backgroundColor: backgroundColor,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBannerAd) const BannerAdWidget(),
          if (bottomNavigationBar != null) bottomNavigationBar!,
        ],
      ),
    );
  }
}
