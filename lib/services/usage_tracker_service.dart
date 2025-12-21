import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/app_usage.dart';
import '../models/subscription.dart';
import 'app_package_mapping.dart';

/// Service for tracking app usage on Android devices.
/// 
/// Uses Android's UsageStatsManager API via a platform channel
/// to get app foreground time and launch counts.
/// 
/// Premium-only feature that requires PACKAGE_USAGE_STATS permission.
class UsageTrackerService {
  static const MethodChannel _channel = MethodChannel('subscription_alert/usage_stats');
  
  static final UsageTrackerService _instance = UsageTrackerService._internal();
  factory UsageTrackerService() => _instance;
  UsageTrackerService._internal();

  bool _permissionGranted = false;

  /// Check if usage tracking is supported on this device
  /// Returns false on web to avoid Platform crash
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Check if we have permission to access usage stats
  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('hasUsagePermission');
      _permissionGranted = result ?? false;
      return _permissionGranted;
    } on MissingPluginException catch (e) {
      debugPrint('UsageTrackerService: Missing platform implementation: $e');
      return false;
    } on PlatformException catch (e) {
      debugPrint('UsageTrackerService: Error checking permission: $e');
      return false;
    }
  }

  /// Request permission to access usage stats
  /// Opens the system settings page for usage access
  Future<bool> requestUsagePermission() async {
    if (!isSupported) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('requestUsagePermission');
      return result ?? false;
    } on MissingPluginException catch (e) {
      debugPrint('UsageTrackerService: Missing platform implementation: $e');
      return false;
    } on PlatformException catch (e) {
      debugPrint('UsageTrackerService: Error requesting permission: $e');
      return false;
    }
  }

  /// Get raw app usage data from the system
  Future<List<AppUsageEntry>> getAppUsage({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!isSupported) return [];
    
    // Check permission first
    if (!_permissionGranted) {
      _permissionGranted = await hasPermission();
      if (!_permissionGranted) {
        debugPrint('UsageTrackerService: No permission to access usage stats');
        return [];
      }
    }

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getAppUsage', {
        'startTime': from.millisecondsSinceEpoch,
        'endTime': to.millisecondsSinceEpoch,
      });

      if (result == null) return [];

      return result
          .map((item) => AppUsageEntry.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on MissingPluginException catch (e) {
      debugPrint('UsageTrackerService: Missing platform implementation: $e');
      return [];
    } on PlatformException catch (e) {
      debugPrint('UsageTrackerService: Error getting app usage: $e');
      return [];
    }
  }

  /// Get usage for subscription-related apps only
  Future<List<AppUsageEntry>> getSubscriptionAppUsage({
    required DateTime from,
    required DateTime to,
  }) async {
    final allUsage = await getAppUsage(from: from, to: to);
    
    return allUsage.where((entry) {
      return AppPackageMapping.isSubscriptionApp(entry.packageName);
    }).toList();
  }

  /// Calculate usage for user's subscriptions
  Future<Map<String, SubscriptionUsage>> calculateSubscriptionUsage({
    required List<Subscription> subscriptions,
    required DateTime from,
    required DateTime to,
  }) async {
    final appUsage = await getAppUsage(from: from, to: to);
    final result = <String, SubscriptionUsage>{};
    final dayCount = to.difference(from).inDays.clamp(1, 365);

    for (final subscription in subscriptions) {
      if (subscription.isCancelled) continue;

      // Get packages that match this subscription
      final packages = _getPackagesForSubscription(subscription);
      if (packages.isEmpty) continue;

      // Find usage for these packages
      Duration totalUsage = Duration.zero;
      int totalLaunches = 0;
      DateTime? firstUsage;
      DateTime? lastUsage;

      for (final entry in appUsage) {
        if (packages.contains(entry.packageName)) {
          totalUsage += entry.totalTimeInForeground;
          totalLaunches += entry.launchCount;
          
          if (firstUsage == null || entry.firstTimestamp.isBefore(firstUsage)) {
            firstUsage = entry.firstTimestamp;
          }
          if (lastUsage == null || entry.lastTimestamp.isAfter(lastUsage)) {
            lastUsage = entry.lastTimestamp;
          }
        }
      }

      if (totalUsage > Duration.zero) {
        final averageDaily = Duration(
          milliseconds: totalUsage.inMilliseconds ~/ dayCount,
        );

        result[subscription.id] = SubscriptionUsage(
          subscriptionId: subscription.id,
          serviceName: subscription.name,
          brandId: subscription.brandId,
          totalUsage: totalUsage,
          launchCount: totalLaunches,
          averageDailyUsage: averageDaily,
          trend: _calculateTrend(totalUsage, dayCount),
          periodStart: from,
          periodEnd: to,
        );
      }
    }

    return result;
  }

  /// Get detailed daily breakdown for a subscription
  Future<List<DailyUsage>> getDailyBreakdown({
    required Subscription subscription,
    required DateTime from,
    required DateTime to,
  }) async {
    final packages = _getPackagesForSubscription(subscription);
    if (packages.isEmpty) return [];

    final result = <DailyUsage>[];
    var currentDate = DateTime(from.year, from.month, from.day);
    final endDate = DateTime(to.year, to.month, to.day);

    while (!currentDate.isAfter(endDate)) {
      final dayStart = currentDate;
      final dayEnd = currentDate.add(const Duration(days: 1));
      
      final dayUsage = await getAppUsage(from: dayStart, to: dayEnd);
      
      Duration totalUsage = Duration.zero;
      int totalLaunches = 0;
      
      for (final entry in dayUsage) {
        if (packages.contains(entry.packageName)) {
          totalUsage += entry.totalTimeInForeground;
          totalLaunches += entry.launchCount;
        }
      }

      result.add(DailyUsage(
        date: currentDate,
        usage: totalUsage,
        launches: totalLaunches,
      ));

      currentDate = dayEnd;
    }

    return result;
  }

  /// Get monthly usage summary
  Future<MonthlyUsageSummary> getMonthlyUsageSummary({
    required List<Subscription> subscriptions,
    required int year,
    required int month,
  }) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    final dayCount = to.day;

    final usageMap = await calculateSubscriptionUsage(
      subscriptions: subscriptions,
      from: from,
      to: to,
    );

    Duration totalUsage = Duration.zero;
    int totalLaunches = 0;
    final usageByService = <String, Duration>{};
    final usageList = <SubscriptionUsage>[];

    for (final usage in usageMap.values) {
      totalUsage += usage.totalUsage;
      totalLaunches += usage.launchCount;
      usageByService[usage.serviceName] = usage.totalUsage;
      usageList.add(usage);
    }

    // Sort by usage to find top and underused services
    usageList.sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
    
    final topServices = usageList.take(5).toList();
    final underused = usageList.where((u) => 
      u.totalUsage.inMinutes < 60 // Less than 1 hour per month
    ).toList();

    return MonthlyUsageSummary(
      year: year,
      month: month,
      totalUsage: totalUsage,
      averageDailyUsage: Duration(milliseconds: totalUsage.inMilliseconds ~/ dayCount),
      totalLaunches: totalLaunches,
      usageByService: usageByService,
      topServices: topServices,
      underusedServices: underused,
    );
  }

  /// Get packages for a subscription based on name and brandId
  List<String> _getPackagesForSubscription(Subscription subscription) {
    final packages = <String>{};

    // Try brand ID first
    if (subscription.brandId != null) {
      packages.addAll(AppPackageMapping.getPackagesForService(subscription.brandId!));
    }

    // Then try name
    packages.addAll(AppPackageMapping.fuzzyMatchPackages(subscription.name));

    return packages.toList();
  }

  /// Calculate usage trend based on total time
  UsageTrend _calculateTrend(Duration totalUsage, int dayCount) {
    if (dayCount < 7) {
      return UsageTrend.newService;
    }
    
    final hoursPerDay = totalUsage.inMinutes / (dayCount * 60);
    
    // These thresholds could be refined based on historical data
    if (hoursPerDay > 1.5) {
      return UsageTrend.increasing;
    } else if (hoursPerDay < 0.25) {
      return UsageTrend.decreasing;
    }
    return UsageTrend.stable;
  }

  /// Get list of all subscription apps installed on device
  Future<List<String>> getInstalledSubscriptionApps() async {
    if (!isSupported) return [];

    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];

      final installedPackages = result.cast<String>().toSet();
      final subscriptionApps = <String>[];

      for (final package in AppPackageMapping.packageToServices.keys) {
        if (installedPackages.contains(package)) {
          subscriptionApps.add(package);
        }
      }

      return subscriptionApps;
    } on PlatformException catch (e) {
      debugPrint('UsageTrackerService: Error getting installed apps: $e');
      return [];
    }
  }

  /// Generate stub data for testing/demo purposes
  Map<String, SubscriptionUsage> generateStubData(List<Subscription> subscriptions) {
    final result = <String, SubscriptionUsage>{};
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    
    // Predefined usage patterns for demo
    final usagePatterns = {
      'netflix': const Duration(hours: 28, minutes: 45),
      'spotify': const Duration(hours: 42, minutes: 30),
      'youtube_premium': const Duration(hours: 15, minutes: 20),
      'disney_plus': const Duration(hours: 8, minutes: 15),
      'hbo_max': const Duration(hours: 5, minutes: 40),
      'amazon_prime_video': const Duration(hours: 12, minutes: 10),
      'apple_music': const Duration(hours: 35, minutes: 0),
      'xbox_game_pass': const Duration(hours: 22, minutes: 30),
      'nordvpn': const Duration(hours: 180, minutes: 0), // VPN runs in background
      'adobe_creative_cloud': const Duration(hours: 45, minutes: 0),
      'notion': const Duration(hours: 18, minutes: 30),
      'slack': const Duration(hours: 65, minutes: 0),
      'microsoft_365': const Duration(hours: 32, minutes: 0),
      'duolingo': const Duration(hours: 4, minutes: 30),
      'headspace': const Duration(hours: 3, minutes: 45),
    };

    for (final subscription in subscriptions) {
      if (subscription.isCancelled) continue;

      final brandId = subscription.brandId?.toLowerCase() ?? 
                      subscription.name.toLowerCase().replaceAll(' ', '_');
      
      // Find matching pattern or generate random
      Duration usage;
      if (usagePatterns.containsKey(brandId)) {
        usage = usagePatterns[brandId]!;
      } else {
        // Random usage between 30 min and 20 hours
        final randomMinutes = (30 + (subscription.name.hashCode % 1170)).abs();
        usage = Duration(minutes: randomMinutes);
      }

      final dayCount = now.day;
      final averageDaily = Duration(milliseconds: usage.inMilliseconds ~/ dayCount);
      
      // Determine trend based on usage amount
      UsageTrend trend;
      if (usage.inHours > 20) {
        trend = UsageTrend.increasing;
      } else if (usage.inHours < 3) {
        trend = UsageTrend.decreasing;
      } else {
        trend = UsageTrend.stable;
      }

      result[subscription.id] = SubscriptionUsage(
        subscriptionId: subscription.id,
        serviceName: subscription.name,
        brandId: subscription.brandId,
        totalUsage: usage,
        launchCount: (usage.inMinutes / 15).round(), // Roughly 1 launch per 15 min
        averageDailyUsage: averageDaily,
        trend: trend,
        periodStart: from,
        periodEnd: now,
      );
    }

    return result;
  }
}
