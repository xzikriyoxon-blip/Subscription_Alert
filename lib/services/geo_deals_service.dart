import 'dart:ui' as ui;
import '../models/geo_deal.dart';

/// Service for fetching location-based deals.
/// 
/// Provides deals specific to the user's country/region.
class GeoDealsService {
  static final GeoDealsService _instance = GeoDealsService._internal();
  factory GeoDealsService() => _instance;
  GeoDealsService._internal();

  /// Get user's country code from device locale
  String getDeviceCountryCode() {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.countryCode?.toUpperCase() ?? 'US';
  }

  /// Fetch deals for a specific region
  Future<List<GeoDeal>> fetchDealsForRegion(String regionCode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final normalizedCode = regionCode.toUpperCase();
    return _geoDealsData.where((deal) => deal.regionCode == normalizedCode).toList();
  }

  /// Fetch all deals (for premium users or admin view)
  Future<List<GeoDeal>> fetchAllDeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _geoDealsData;
  }

  /// Get deals limited by premium status
  Future<List<GeoDeal>> getDealsForUser({
    required String regionCode,
    required bool isPremium,
  }) async {
    final deals = await fetchDealsForRegion(regionCode);
    
    if (isPremium) {
      return deals;
    }
    
    // Free users only see first 2 deals
    return deals.take(2).toList();
  }

  /// Get all available regions with deals
  List<String> get availableRegions {
    return _geoDealsData.map((d) => d.regionCode).toSet().toList();
  }

  /// Stub data for geo deals
  /// In production, this would be fetched from Firestore or an API
  static final List<GeoDeal> _geoDealsData = [
    // Turkey deals
    GeoDeal(
      id: 'tr_netflix_1',
      title: 'Netflix Turkey - Cheapest in Europe',
      description: 'Get Netflix at the lowest price in Europe. Standard plan at ₺99.99/month.',
      regionCode: 'TR',
      regionName: 'Turkey',
      price: 99.99,
      currency: 'TRY',
      serviceName: 'Netflix',
      category: DealCategory.streaming,
      url: 'https://www.netflix.com/tr/',
      discountText: 'Best Value',
      discountPercent: 70,
      isVerified: true,
      flag: '🇹🇷',
    ),
    GeoDeal(
      id: 'tr_spotify_1',
      title: 'Spotify Premium Turkey',
      description: 'Spotify Premium at ₺57.99/month. One of the cheapest globally.',
      regionCode: 'TR',
      regionName: 'Turkey',
      price: 57.99,
      currency: 'TRY',
      serviceName: 'Spotify',
      category: DealCategory.music,
      url: 'https://www.spotify.com/tr/premium/',
      discountText: '80% cheaper than US',
      discountPercent: 80,
      isVerified: true,
      flag: '🇹🇷',
    ),
    GeoDeal(
      id: 'tr_youtube_1',
      title: 'YouTube Premium Turkey',
      description: 'YouTube Premium with ad-free videos and YouTube Music at ₺57.99/month.',
      regionCode: 'TR',
      regionName: 'Turkey',
      price: 57.99,
      currency: 'TRY',
      serviceName: 'YouTube Premium',
      category: DealCategory.streaming,
      url: 'https://www.youtube.com/premium',
      discountText: 'Save 75%',
      discountPercent: 75,
      isVerified: true,
      flag: '🇹🇷',
    ),

    // India deals
    GeoDeal(
      id: 'in_netflix_1',
      title: 'Netflix India Mobile Plan',
      description: 'Netflix Mobile plan at just ₹149/month. Perfect for mobile viewing.',
      regionCode: 'IN',
      regionName: 'India',
      price: 149,
      currency: 'INR',
      serviceName: 'Netflix',
      category: DealCategory.streaming,
      url: 'https://www.netflix.com/in/',
      discountText: 'Mobile Only',
      discountPercent: 85,
      isVerified: true,
      flag: '🇮🇳',
    ),
    GeoDeal(
      id: 'in_spotify_1',
      title: 'Spotify Premium India',
      description: 'Spotify Premium at ₹119/month. One of the lowest prices worldwide.',
      regionCode: 'IN',
      regionName: 'India',
      price: 119,
      currency: 'INR',
      serviceName: 'Spotify',
      category: DealCategory.music,
      url: 'https://www.spotify.com/in/premium/',
      discountText: 'Best Price',
      discountPercent: 88,
      isVerified: true,
      flag: '🇮🇳',
    ),
    GeoDeal(
      id: 'in_prime_1',
      title: 'Amazon Prime India',
      description: 'Amazon Prime with Prime Video, Music, and free delivery at ₹299/month.',
      regionCode: 'IN',
      regionName: 'India',
      price: 299,
      currency: 'INR',
      serviceName: 'Amazon Prime',
      category: DealCategory.streaming,
      url: 'https://www.amazon.in/prime',
      discountText: 'All-in-One',
      discountPercent: 60,
      isVerified: true,
      flag: '🇮🇳',
    ),

    // Argentina deals
    GeoDeal(
      id: 'ar_netflix_1',
      title: 'Netflix Argentina',
      description: 'Netflix Standard at ARS 2,499/month. Cheapest Netflix globally.',
      regionCode: 'AR',
      regionName: 'Argentina',
      price: 2499,
      currency: 'ARS',
      serviceName: 'Netflix',
      category: DealCategory.streaming,
      url: 'https://www.netflix.com/ar/',
      discountText: 'Cheapest Globally',
      discountPercent: 90,
      isVerified: true,
      flag: '🇦🇷',
    ),
    GeoDeal(
      id: 'ar_spotify_1',
      title: 'Spotify Premium Argentina',
      description: 'Spotify Premium at ARS 1,169/month. Incredible value.',
      regionCode: 'AR',
      regionName: 'Argentina',
      price: 1169,
      currency: 'ARS',
      serviceName: 'Spotify',
      category: DealCategory.music,
      url: 'https://www.spotify.com/ar/premium/',
      discountText: 'Amazing Value',
      discountPercent: 85,
      isVerified: true,
      flag: '🇦🇷',
    ),

    // Uzbekistan deals
    GeoDeal(
      id: 'uz_uzum_1',
      title: 'Uzum Nasiya - Buy Now Pay Later',
      description: 'Shop on Uzum with installment payments. 0% interest for up to 12 months.',
      regionCode: 'UZ',
      regionName: 'Uzbekistan',
      price: null,
      currency: 'UZS',
      serviceName: 'Uzum Nasiya',
      category: DealCategory.other,
      url: 'https://uzum.uz',
      discountText: '0% Interest',
      isVerified: true,
      flag: '🇺🇿',
    ),
    GeoDeal(
      id: 'uz_beeline_1',
      title: 'Beeline TV Streaming',
      description: 'Local streaming service with Uzbek and international content.',
      regionCode: 'UZ',
      regionName: 'Uzbekistan',
      price: 25000,
      currency: 'UZS',
      serviceName: 'Beeline TV',
      category: DealCategory.streaming,
      url: 'https://beeline.uz',
      discountText: 'Local Content',
      isVerified: true,
      flag: '🇺🇿',
    ),

    // United States deals
    GeoDeal(
      id: 'us_hulu_1',
      title: 'Hulu + Live TV Bundle',
      description: 'Hulu with Live TV, Disney+, and ESPN+ bundled together.',
      regionCode: 'US',
      regionName: 'United States',
      price: 76.99,
      currency: 'USD',
      serviceName: 'Hulu',
      category: DealCategory.streaming,
      url: 'https://www.hulu.com',
      discountText: 'Best Bundle',
      isVerified: true,
      flag: '🇺🇸',
    ),
    GeoDeal(
      id: 'us_peacock_1',
      title: 'Peacock Premium',
      description: 'NBCUniversal streaming with live sports, news, and originals.',
      regionCode: 'US',
      regionName: 'United States',
      price: 7.99,
      currency: 'USD',
      serviceName: 'Peacock',
      category: DealCategory.streaming,
      url: 'https://www.peacocktv.com',
      discountText: 'Affordable',
      isVerified: true,
      flag: '🇺🇸',
    ),
  ];
}
