import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/regional_price.dart';
import '../models/geo_deal.dart';
import '../models/timeline_entry.dart';
import '../models/wishlist.dart';
import '../models/spend_health.dart';
import '../models/media_favorite.dart';
import '../models/app_usage.dart';
import '../services/regional_price_service.dart';
import '../services/geo_deals_service.dart';
import '../services/timeline_service.dart';
import '../services/wishlist_service.dart';
import '../services/spend_health_service.dart';
import '../services/media_favorites_service.dart';
import '../services/usage_tracker_service.dart';
import '../services/manual_usage_log_service.dart';
import 'subscription_providers.dart';
import 'premium_providers.dart';
import 'auth_provider.dart';

// ============================================================
// Service Providers
// ============================================================

/// Provider for RegionalPriceService singleton
final regionalPriceServiceProvider = Provider<RegionalPriceService>((ref) {
  return RegionalPriceService();
});

/// Provider for GeoDealsService singleton
final geoDealsServiceProvider = Provider<GeoDealsService>((ref) {
  return GeoDealsService();
});

/// Provider for TimelineService singleton
final timelineServiceProvider = Provider<TimelineService>((ref) {
  return TimelineService();
});

/// Provider for WishListService singleton
final wishListServiceProvider = Provider<WishListService>((ref) {
  return WishListService();
});

/// Provider for SpendHealthService singleton
final spendHealthServiceProvider = Provider<SpendHealthService>((ref) {
  return SpendHealthService();
});

/// Provider for MediaFavoritesService singleton
final mediaFavoritesServiceProvider = Provider<MediaFavoritesService>((ref) {
  return MediaFavoritesService();
});

/// Provider for UsageTrackerService singleton
final usageTrackerServiceProvider = Provider<UsageTrackerService>((ref) {
  return UsageTrackerService();
});

/// Provider for ManualUsageLogService singleton
final manualUsageLogServiceProvider = Provider<ManualUsageLogService>((ref) {
  return ManualUsageLogService();
});

// ============================================================
// Regional Price Providers (Premium Only)
// ============================================================

/// Provider for regional price comparison
/// Usage: ref.watch(regionalPriceComparisonProvider('netflix'))
final regionalPriceComparisonProvider =
    FutureProvider.family<RegionalPriceComparison, String>(
        (ref, serviceName) async {
  final service = ref.watch(regionalPriceServiceProvider);
  final baseCurrency = ref.watch(baseCurrencyProvider);
  final exchangeService = ref.watch(exchangeRateServiceProvider);

  // Build exchange rates map from USD base rates for regional price comparison
  // Common currencies used in regional pricing
  final currencies = [
    'USD',
    'TRY',
    'INR',
    'ARS',
    'UZS',
    'PKR',
    'RUB',
    'EGP',
    'IDR',
    'EUR',
    'GBP',
    'JPY',
    'BRL',
    'MXN',
    'KRW'
  ];
  final rates = <String, double>{};

  for (final fromCurrency in currencies) {
    for (final toCurrency in currencies) {
      if (fromCurrency != toCurrency) {
        final rate = await exchangeService.getRate(fromCurrency, toCurrency);
        if (rate != null) {
          rates['${fromCurrency}_$toCurrency'] = rate;
        }
      }
    }
  }

  return service.compareRegionalPrices(
    serviceName: serviceName,
    targetCurrency: baseCurrency,
    exchangeRates: rates,
  );
});

/// Provider for list of supported services for price comparison
final supportedPriceComparisonServicesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(regionalPriceServiceProvider);
  return service.supportedServices;
});

// ============================================================
// Geo Deals Providers
// ============================================================

/// Provider for user's country code (from device or stored preference)
final userCountryCodeProvider = Provider<String>((ref) {
  // First try to get from user profile (if stored)
  // If not available, get from device locale
  final service = ref.watch(geoDealsServiceProvider);
  return service.getDeviceCountryCode();
});

/// Provider for geo deals for user's region
final geoDealsProvider = FutureProvider<List<GeoDeal>>((ref) async {
  final service = ref.watch(geoDealsServiceProvider);
  final countryCode = ref.watch(userCountryCodeProvider);
  final isPremium = ref.watch(isPremiumProvider);

  return service.getDealsForUser(
    regionCode: countryCode,
    isPremium: isPremium,
  );
});

/// Provider for all geo deals (premium only)
final allGeoDealsProvider = FutureProvider<List<GeoDeal>>((ref) async {
  final service = ref.watch(geoDealsServiceProvider);
  return service.fetchAllDeals();
});

/// Provider for available regions with deals
final availableGeoRegionsProvider = Provider<List<String>>((ref) {
  final service = ref.watch(geoDealsServiceProvider);
  return service.availableRegions;
});

// ============================================================
// Timeline Providers
// ============================================================

/// Provider for subscription timeline
final subscriptionTimelineProvider = Provider<SubscriptionTimeline>((ref) {
  final service = ref.watch(timelineServiceProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  final isPremium = ref.watch(isPremiumProvider);

  return service.generateTimeline(
    subscriptions: subscriptions,
    pastMonths: isPremium ? 3 : 1,
    futureMonths: isPremium ? 6 : 2,
    isPremium: isPremium,
  );
});

/// Provider for timeline summary statistics
final timelineSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(timelineServiceProvider);
  final timeline = ref.watch(subscriptionTimelineProvider);
  return service.getTimelineSummary(timeline);
});

// ============================================================
// Wishlist Providers
// ============================================================

/// Provider for user's wishlists stream
final wishlistsStreamProvider = StreamProvider<List<WishList>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(wishListServiceProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return service.watchWishlists(userId);
});

/// Provider for user's wishlists (non-stream)
final wishlistsProvider = Provider<List<WishList>>((ref) {
  final wishlistsAsync = ref.watch(wishlistsStreamProvider);
  return wishlistsAsync.valueOrNull ?? [];
});

/// Provider for items in a specific wishlist
/// Usage: ref.watch(wishlistItemsProvider(listId))
final wishlistItemsStreamProvider =
    StreamProvider.family<List<WishListItem>, String>((ref, listId) {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(wishListServiceProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return service.watchItems(userId, listId);
});

/// Provider for checking if user can create more wishlists
final canCreateWishlistProvider = Provider<bool>((ref) {
  final wishlists = ref.watch(wishlistsProvider);
  final isPremium = ref.watch(isPremiumProvider);
  return WishListLimits.canCreateList(wishlists.length, isPremium);
});

/// Provider for wishlist limits info
final wishlistLimitsProvider = Provider<Map<String, dynamic>>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return {
    'maxLists': WishListLimits.maxLists(isPremium),
    'maxItemsPerList': WishListLimits.maxItems(isPremium),
    'isPremium': isPremium,
  };
});

// ============================================================
// Spend Health Providers
// ============================================================

/// Provider for spend health score
final spendHealthScoreProvider = Provider<SpendHealthScore>((ref) {
  final service = ref.watch(spendHealthServiceProvider);
  final subscriptions = ref.watch(subscriptionsProvider);
  final baseCurrency = ref.watch(baseCurrencyProvider);

  return service.calculate(
    subscriptions: subscriptions,
    baseCurrency: baseCurrency,
  );
});

/// Provider for detailed spend health analysis (premium only)
final spendHealthAnalysisProvider = Provider<Map<String, dynamic>?>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  if (!isPremium) return null;

  final service = ref.watch(spendHealthServiceProvider);
  final subscriptions = ref.watch(subscriptionsProvider);

  return service.getDetailedAnalysis(
    subscriptions: subscriptions,
  );
});

/// Provider for spend health status color
final spendHealthColorProvider = Provider<String>((ref) {
  final score = ref.watch(spendHealthScoreProvider);
  return score.statusColor;
});

// ============================================================
// Wishlist Controller
// ============================================================

/// Controller for wishlist operations
class WishlistController {
  final WishListService _service;
  final String _userId;
  final bool _isPremium;

  WishlistController({
    required WishListService service,
    required String userId,
    required bool isPremium,
  })  : _service = service,
        _userId = userId,
        _isPremium = isPremium;

  Future<WishList> createWishlist(String name, {String? description}) {
    return _service.createWishlist(
      userId: _userId,
      name: name,
      description: description,
      isPremium: _isPremium,
    );
  }

  Future<void> updateWishlist(String listId,
      {String? name, String? description}) {
    return _service.updateWishlist(
      userId: _userId,
      listId: listId,
      name: name,
      description: description,
    );
  }

  Future<void> deleteWishlist(String listId) {
    return _service.deleteWishlist(_userId, listId);
  }

  Future<WishListItem> addItem({
    required String listId,
    required String serviceName,
    String? brandId,
    String? note,
    String? estimatedPrice,
    String? currency,
    String? category,
    String? imageUrl,
  }) {
    return _service.addItem(
      userId: _userId,
      listId: listId,
      serviceName: serviceName,
      brandId: brandId,
      note: note,
      estimatedPrice: estimatedPrice,
      currency: currency,
      category: category,
      imageUrl: imageUrl,
      isPremium: _isPremium,
    );
  }

  Future<void> deleteItem(String listId, String itemId) {
    return _service.deleteItem(
      userId: _userId,
      listId: listId,
      itemId: itemId,
    );
  }

  Future<void> moveItem(String fromListId, String toListId, String itemId) {
    return _service.moveItem(
      userId: _userId,
      fromListId: fromListId,
      toListId: toListId,
      itemId: itemId,
      isPremium: _isPremium,
    );
  }
}

/// Provider for wishlist controller
final wishlistControllerProvider = Provider<WishlistController?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(wishListServiceProvider);
  final isPremium = ref.watch(isPremiumProvider);

  if (userId == null) return null;

  return WishlistController(
    service: service,
    userId: userId,
    isPremium: isPremium,
  );
});

// ============================================================
// Media Favorites Providers
// ============================================================

/// StateNotifier for managing media favorites with reactive updates
class MediaFavoritesNotifier extends StateNotifier<List<MediaFavorite>> {
  final MediaFavoritesService _service;

  MediaFavoritesNotifier(this._service) : super([]) {
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    state = _service.getAll();
  }

  /// Check if an item is favorited
  bool isFavorite(String id) => _service.isFavorite(id);

  /// Check if video is favorited
  bool isVideoFavorite(int tmdbId, String mediaType) =>
      _service.isVideoFavorite(tmdbId, mediaType);

  /// Check if song is favorited
  bool isSongFavorite(int trackId) => _service.isSongFavorite(trackId);

  /// Toggle favorite for a video (movie/TV show)
  Future<bool> toggleVideoFavorite({
    required int tmdbId,
    required String title,
    required String mediaType,
    String? posterPath,
    String? year,
    double? rating,
  }) async {
    final favorite = MediaFavorite.fromStreamingContent(
      tmdbId: tmdbId,
      title: title,
      mediaType: mediaType,
      posterPath: posterPath,
      year: year,
      rating: rating,
    );
    final result = await _service.toggleFavorite(favorite);
    state = _service.getAll();
    return result;
  }

  /// Toggle favorite for a song
  Future<bool> toggleSongFavorite({
    required int trackId,
    required String title,
    required String artistName,
    required String albumName,
    String? albumCover,
    int? duration,
  }) async {
    final favorite = MediaFavorite.fromMusicTrack(
      trackId: trackId,
      title: title,
      artistName: artistName,
      albumName: albumName,
      albumCover: albumCover,
      duration: duration,
    );
    final result = await _service.toggleFavorite(favorite);
    state = _service.getAll();
    return result;
  }

  /// Remove a favorite
  Future<void> removeFavorite(String id) async {
    await _service.removeFavorite(id);
    state = _service.getAll();
  }

  /// Get favorites by type
  List<MediaFavorite> getByType(MediaType type) => _service.getByType(type);

  /// Get video favorites (movies + TV)
  List<MediaFavorite> get videoFavorites => _service.videoFavorites;

  /// Get song favorites
  List<MediaFavorite> get songFavorites => _service.songFavorites;

  /// Clear all favorites
  Future<void> clearAll() async {
    await _service.clearAll();
    state = [];
  }
}

/// Provider for media favorites notifier
final mediaFavoritesProvider =
    StateNotifierProvider<MediaFavoritesNotifier, List<MediaFavorite>>((ref) {
  final service = ref.watch(mediaFavoritesServiceProvider);
  return MediaFavoritesNotifier(service);
});

/// Provider for video favorites only
final videoFavoritesProvider = Provider<List<MediaFavorite>>((ref) {
  final favorites = ref.watch(mediaFavoritesProvider);
  return favorites
      .where((f) => f.type == MediaType.movie || f.type == MediaType.tv)
      .toList();
});

/// Provider for song favorites only
final songFavoritesProvider = Provider<List<MediaFavorite>>((ref) {
  final favorites = ref.watch(mediaFavoritesProvider);
  return favorites.where((f) => f.type == MediaType.song).toList();
});

// ============================================================
// Usage Tracking Providers (Premium Only)
// ============================================================

/// Provider for checking if usage tracking is supported (Android only)
/// Returns false on web to avoid Platform crash
final usageTrackingSupported = Provider<bool>((ref) {
  if (kIsWeb) return false;
  return Platform.isAndroid;
});

/// Provider for usage permission status
final usagePermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(usageTrackerServiceProvider);
  return service.hasPermission();
});

/// Provider for subscription usage data for the current month
final currentMonthUsageProvider =
    FutureProvider<Map<String, SubscriptionUsage>>((ref) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (!isPremium) return {};

  final isAndroid = ref.watch(usageTrackingSupported);
  final subscriptions = ref.watch(subscriptionsProvider);

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1);
  final to = now;

  if (isAndroid) {
    final service = ref.watch(usageTrackerServiceProvider);
    final hasPermission = await ref.watch(usagePermissionProvider.future);

    if (hasPermission) {
      return service.calculateSubscriptionUsage(
        subscriptions: subscriptions,
        from: from,
        to: to,
      );
    } else {
      // Return stub data for preview/demo
      return service.generateStubData(subscriptions);
    }
  } else {
    // iOS: Use manual logs
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return {};

    final logService = ref.watch(manualUsageLogServiceProvider);
    final result = <String, SubscriptionUsage>{};

    for (final subscription in subscriptions) {
      if (subscription.isCancelled) continue;

      final usage = await logService.getSubscriptionUsageFromLogs(
        userId: userId,
        subscriptionId: subscription.id,
        serviceName: subscription.name,
        brandId: subscription.brandId,
        from: from,
        to: to,
      );

      if (usage != null) {
        result[subscription.id] = usage;
      }
    }

    return result;
  }
});

/// Provider for monthly usage summary
final monthlyUsageSummaryProvider =
    FutureProvider.family<MonthlyUsageSummary?, ({int year, int month})>(
        (ref, params) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (!isPremium) return null;

  final isAndroid = ref.watch(usageTrackingSupported);
  final subscriptions = ref.watch(subscriptionsProvider);

  if (isAndroid) {
    final service = ref.watch(usageTrackerServiceProvider);
    final hasPermission = await ref.watch(usagePermissionProvider.future);

    if (!hasPermission) return null;

    return service.getMonthlyUsageSummary(
      subscriptions: subscriptions,
      year: params.year,
      month: params.month,
    );
  } else {
    // iOS: Calculate from manual logs
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;

    final from = DateTime(params.year, params.month, 1);
    final to = DateTime(params.year, params.month + 1, 0, 23, 59, 59);
    final dayCount = to.day;

    final logService = ref.watch(manualUsageLogServiceProvider);
    final usageMap = await logService.calculateManualUsage(
      userId: userId,
      from: from,
      to: to,
    );

    Duration totalUsage = Duration.zero;
    int totalLaunches = 0;
    final usageByService = <String, Duration>{};
    final usageList = <SubscriptionUsage>[];

    for (final subscription in subscriptions) {
      final duration = usageMap[subscription.id];
      if (duration != null && duration > Duration.zero) {
        totalUsage += duration;
        usageByService[subscription.name] = duration;

        final avgDaily =
            Duration(milliseconds: duration.inMilliseconds ~/ dayCount);
        usageList.add(SubscriptionUsage(
          subscriptionId: subscription.id,
          serviceName: subscription.name,
          brandId: subscription.brandId,
          totalUsage: duration,
          launchCount: 0, // Not tracked in manual logs
          averageDailyUsage: avgDaily,
          trend: UsageTrend.stable,
          periodStart: from,
          periodEnd: to,
        ));
      }
    }

    usageList.sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
    final topServices = usageList.take(5).toList();
    final underused =
        usageList.where((u) => u.totalUsage.inMinutes < 60).toList();

    return MonthlyUsageSummary(
      year: params.year,
      month: params.month,
      totalUsage: totalUsage,
      averageDailyUsage:
          Duration(milliseconds: totalUsage.inMilliseconds ~/ dayCount),
      totalLaunches: totalLaunches,
      usageByService: usageByService,
      topServices: topServices,
      underusedServices: underused,
    );
  }
});

/// Provider for top used subscriptions (sorted by usage)
final topUsedSubscriptionsProvider = Provider<List<SubscriptionUsage>>((ref) {
  final usageAsync = ref.watch(currentMonthUsageProvider);
  final usageMap = usageAsync.valueOrNull ?? {};

  final list = usageMap.values.toList();
  list.sort((a, b) => b.totalUsage.compareTo(a.totalUsage));

  return list.take(5).toList();
});

/// Provider for underused subscriptions (less than 1 hour per month)
final underusedSubscriptionsProvider = Provider<List<SubscriptionUsage>>((ref) {
  final usageAsync = ref.watch(currentMonthUsageProvider);
  final usageMap = usageAsync.valueOrNull ?? {};

  return usageMap.values.where((u) => u.totalUsage.inMinutes < 60).toList();
});

/// StateNotifier for manual usage logging (iOS or manual tracking)
class ManualUsageNotifier extends StateNotifier<List<ManualUsageLog>> {
  final ManualUsageLogService _service;
  final String? _userId;

  ManualUsageNotifier(this._service, this._userId) : super([]) {
    if (_userId != null) {
      _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    if (_userId == null) return;

    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);

    final logs = await _service.getLogs(
      userId: _userId!,
      from: from,
      to: now,
    );

    state = logs;
  }

  Future<ManualUsageLog?> addLog({
    required String subscriptionId,
    required String serviceName,
    required DateTime date,
    required Duration duration,
    String? notes,
  }) async {
    if (_userId == null) return null;

    final log = await _service.addLog(
      userId: _userId!,
      subscriptionId: subscriptionId,
      serviceName: serviceName,
      date: date,
      duration: duration,
      notes: notes,
    );

    state = [log, ...state];
    return log;
  }

  Future<void> deleteLog(String logId) async {
    if (_userId == null) return;

    await _service.deleteLog(userId: _userId!, logId: logId);
    state = state.where((l) => l.id != logId).toList();
  }

  Future<void> refresh() async {
    await _loadLogs();
  }
}

/// Provider for manual usage notifier
final manualUsageProvider =
    StateNotifierProvider<ManualUsageNotifier, List<ManualUsageLog>>((ref) {
  final service = ref.watch(manualUsageLogServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ManualUsageNotifier(service, userId);
});

/// Provider for checking if we should show usage tracking feature
final showUsageTrackingProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return isPremium;
});
