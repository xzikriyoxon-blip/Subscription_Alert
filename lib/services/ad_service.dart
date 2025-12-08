import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing AdMob advertisements.
/// 
/// Handles banner ads, interstitial ads, and app open ads with proper lifecycle management.
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
  
  // App Open ad instance
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoaded = false;
  DateTime? _appOpenAdLoadTime;
  
  // Counter for showing interstitial ads
  int _actionCounter = 0;
  static const int _actionsBeforeInterstitial = 3;
  
  // Max duration for app open ad validity (4 hours)
  static const Duration _maxAdDuration = Duration(hours: 4);

  // Ad Unit IDs
  static String get _bannerAdUnitId {
    if (kDebugMode) {
      // Test IDs for development
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // Production IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-4484379154109513/4182095614';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4484379154109513/4182095614';
    }
    return '';
  }

  static String get _interstitialAdUnitId {
    if (kDebugMode) {
      // Test IDs for development
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    // Production IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-4484379154109513/6902901371';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4484379154109513/6902901371';
    }
    return '';
  }

  static String get _appOpenAdUnitId {
    if (kDebugMode) {
      // Test IDs for development
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/9257395921';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/5575463023';
      }
    }
    // Production IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-4484379154109513/9314825185';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4484379154109513/9314825185';
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
    _loadAppOpenAd();
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
              _loadInterstitialAd();
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
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Load an app open ad.
  void _loadAppOpenAd() {
    if (kIsWeb) return;
    
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdLoaded = true;
          _appOpenAdLoadTime = DateTime.now();
          debugPrint('AdMob: App Open ad loaded');
          
          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAppOpenAdLoaded = false;
              _loadAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isAppOpenAdLoaded = false;
              _loadAppOpenAd();
              debugPrint('AdMob: App Open ad failed to show: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdLoaded = false;
          debugPrint('AdMob: App Open ad failed to load: ${error.message}');
          Future.delayed(const Duration(minutes: 1), _loadAppOpenAd);
        },
      ),
    );
  }

  /// Check if the app open ad is still valid (not expired).
  bool _isAppOpenAdValid() {
    if (_appOpenAdLoadTime == null) return false;
    return DateTime.now().difference(_appOpenAdLoadTime!) < _maxAdDuration;
  }

  /// Get the banner ad if loaded.
  BannerAd? get bannerAd => _isBannerAdLoaded ? _bannerAd : null;
  
  /// Check if banner ad is loaded.
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Show app open ad when app is opened/resumed.
  Future<bool> showAppOpenAd() async {
    if (kIsWeb) return false;
    
    if (!_isAppOpenAdLoaded || !_isAppOpenAdValid()) {
      _loadAppOpenAd();
      return false;
    }
    
    await _appOpenAd?.show();
    return true;
  }

  /// Show interstitial ad after certain number of actions.
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
    _appOpenAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _appOpenAd = null;
    _isBannerAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isAppOpenAdLoaded = false;
  }
}
