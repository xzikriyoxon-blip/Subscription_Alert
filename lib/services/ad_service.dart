import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing AdMob advertisements.
/// 
/// Handles banner ads and interstitial ads with proper lifecycle management.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  
  // Banner ad instance
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  
  // Interstitial ad instance
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  
  // Counter for showing interstitial ads
  int _actionCounter = 0;
  static const int _actionsBeforeInterstitial = 3;

  // Test Ad Unit IDs (replace with your real IDs for production)
  static String get _bannerAdUnitId {
    if (kDebugMode) {
      // Test IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // TODO: Replace with your real Ad Unit IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your Android Banner ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your iOS Banner ID
    }
    return '';
  }

  static String get _interstitialAdUnitId {
    if (kDebugMode) {
      // Test IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    // TODO: Replace with your real Ad Unit IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your Android Interstitial ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your iOS Interstitial ID
    }
    return '';
  }

  /// Initialize the Mobile Ads SDK.
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    // Preload ads
    _loadBannerAd();
    _loadInterstitialAd();
  }

  /// Load a banner ad.
  void _loadBannerAd() {
    if (kIsWeb) return;
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          debugPrint('AdMob: Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          debugPrint('AdMob: Banner ad failed to load: ${error.message}');
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadBannerAd);
        },
        onAdOpened: (ad) => debugPrint('AdMob: Banner ad opened'),
        onAdClosed: (ad) => debugPrint('AdMob: Banner ad closed'),
      ),
    );
    
    _bannerAd!.load();
  }

  /// Load an interstitial ad.
  void _loadInterstitialAd() {
    if (kIsWeb) return;
    
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('AdMob: Interstitial ad loaded');
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdLoaded = false;
              _loadInterstitialAd();
              debugPrint('AdMob: Interstitial failed to show: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('AdMob: Interstitial ad failed to load: ${error.message}');
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Get the banner ad if loaded.
  BannerAd? get bannerAd => _isBannerAdLoaded ? _bannerAd : null;
  
  /// Check if banner ad is loaded.
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Show interstitial ad after certain number of actions.
  /// Returns true if ad was shown.
  Future<bool> showInterstitialAdIfReady() async {
    if (kIsWeb) return false;
    
    _actionCounter++;
    
    if (_actionCounter >= _actionsBeforeInterstitial && _isInterstitialAdLoaded) {
      _actionCounter = 0;
      await _interstitialAd?.show();
      return true;
    }
    
    return false;
  }

  /// Force show interstitial ad immediately.
  Future<bool> showInterstitialAd() async {
    if (kIsWeb || !_isInterstitialAdLoaded) return false;
    
    await _interstitialAd?.show();
    return true;
  }

  /// Reset action counter.
  void resetActionCounter() {
    _actionCounter = 0;
  }

  /// Dispose all ads.
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
  }
}
