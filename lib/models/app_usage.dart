/// Models for tracking subscription service usage.
/// 
/// Used to monitor how often users engage with their subscriptions.

/// Represents a single app usage entry from the system
class AppUsageEntry {
  final String packageName;
  final String appName;
  final Duration totalTimeInForeground;
  final int launchCount;
  final DateTime firstTimestamp;
  final DateTime lastTimestamp;

  const AppUsageEntry({
    required this.packageName,
    required this.appName,
    required this.totalTimeInForeground,
    required this.launchCount,
    required this.firstTimestamp,
    required this.lastTimestamp,
  });

  /// Create from platform channel data
  factory AppUsageEntry.fromMap(Map<String, dynamic> map) {
    return AppUsageEntry(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      totalTimeInForeground: Duration(milliseconds: map['totalTimeInForeground'] as int? ?? 0),
      launchCount: map['launchCount'] as int? ?? 0,
      firstTimestamp: DateTime.fromMillisecondsSinceEpoch(map['firstTimestamp'] as int? ?? 0),
      lastTimestamp: DateTime.fromMillisecondsSinceEpoch(map['lastTimestamp'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'totalTimeInForeground': totalTimeInForeground.inMilliseconds,
      'launchCount': launchCount,
      'firstTimestamp': firstTimestamp.millisecondsSinceEpoch,
      'lastTimestamp': lastTimestamp.millisecondsSinceEpoch,
    };
  }

  /// Format duration as human readable string
  String get formattedDuration {
    final hours = totalTimeInForeground.inHours;
    final minutes = totalTimeInForeground.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalTimeInForeground.inSeconds}s';
    }
  }
}

/// Usage data for a specific subscription service
class SubscriptionUsage {
  final String subscriptionId;
  final String serviceName;
  final String? brandId;
  final Duration totalUsage;
  final int launchCount;
  final Duration averageDailyUsage;
  final UsageTrend trend;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<DailyUsage> dailyBreakdown;

  const SubscriptionUsage({
    required this.subscriptionId,
    required this.serviceName,
    this.brandId,
    required this.totalUsage,
    required this.launchCount,
    required this.averageDailyUsage,
    required this.trend,
    required this.periodStart,
    required this.periodEnd,
    this.dailyBreakdown = const [],
  });

  /// Format total usage as string
  String get formattedTotalUsage {
    final hours = totalUsage.inHours;
    final minutes = totalUsage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${totalUsage.inSeconds}s';
    }
  }

  /// Format average daily usage
  String get formattedAverageDaily {
    final hours = averageDailyUsage.inHours;
    final minutes = averageDailyUsage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m/day';
    } else if (minutes > 0) {
      return '${minutes}m/day';
    } else {
      return '${averageDailyUsage.inSeconds}s/day';
    }
  }

  /// Calculate value score (usage per dollar spent)
  double calculateValueScore(double monthlyPrice) {
    if (monthlyPrice <= 0) return 0;
    final hoursPerMonth = totalUsage.inMinutes / 60.0;
    return hoursPerMonth / monthlyPrice; // hours per dollar
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'serviceName': serviceName,
      'brandId': brandId,
      'totalUsage': totalUsage.inMilliseconds,
      'launchCount': launchCount,
      'averageDailyUsage': averageDailyUsage.inMilliseconds,
      'trend': trend.name,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) {
    return SubscriptionUsage(
      subscriptionId: json['subscriptionId'] as String,
      serviceName: json['serviceName'] as String,
      brandId: json['brandId'] as String?,
      totalUsage: Duration(milliseconds: json['totalUsage'] as int),
      launchCount: json['launchCount'] as int,
      averageDailyUsage: Duration(milliseconds: json['averageDailyUsage'] as int),
      trend: UsageTrend.values.firstWhere(
        (e) => e.name == json['trend'],
        orElse: () => UsageTrend.stable,
      ),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );
  }
}

/// Usage data for a single day
class DailyUsage {
  final DateTime date;
  final Duration usage;
  final int launches;

  const DailyUsage({
    required this.date,
    required this.usage,
    this.launches = 0,
  });

  String get formattedUsage {
    final hours = usage.inHours;
    final minutes = usage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${usage.inSeconds}s';
    }
  }
}

/// Trend indicator for usage patterns
enum UsageTrend {
  increasing,
  stable,
  decreasing,
  newService, // Not enough data
}

extension UsageTrendExtension on UsageTrend {
  String get label {
    switch (this) {
      case UsageTrend.increasing:
        return 'Increasing';
      case UsageTrend.stable:
        return 'Stable';
      case UsageTrend.decreasing:
        return 'Decreasing';
      case UsageTrend.newService:
        return 'New';
    }
  }

  String get emoji {
    switch (this) {
      case UsageTrend.increasing:
        return '📈';
      case UsageTrend.stable:
        return '➡️';
      case UsageTrend.decreasing:
        return '📉';
      case UsageTrend.newService:
        return '🆕';
    }
  }
}

/// Manual usage log entry (for iOS or manual tracking)
class ManualUsageLog {
  final String id;
  final String subscriptionId;
  final String serviceName;
  final DateTime date;
  final Duration duration;
  final String? notes;
  final DateTime createdAt;

  const ManualUsageLog({
    required this.id,
    required this.subscriptionId,
    required this.serviceName,
    required this.date,
    required this.duration,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'serviceName': serviceName,
      'date': date.toIso8601String(),
      'duration': duration.inMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ManualUsageLog.fromJson(Map<String, dynamic> json) {
    return ManualUsageLog(
      id: json['id'] as String,
      subscriptionId: json['subscriptionId'] as String,
      serviceName: json['serviceName'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(minutes: json['duration'] as int),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// Monthly usage summary for analytics
class MonthlyUsageSummary {
  final int year;
  final int month;
  final Duration totalUsage;
  final Duration averageDailyUsage;
  final int totalLaunches;
  final Map<String, Duration> usageByService;
  final List<SubscriptionUsage> topServices;
  final List<SubscriptionUsage> underusedServices;

  const MonthlyUsageSummary({
    required this.year,
    required this.month,
    required this.totalUsage,
    required this.averageDailyUsage,
    required this.totalLaunches,
    required this.usageByService,
    this.topServices = const [],
    this.underusedServices = const [],
  });

  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String get formattedTotalUsage {
    final hours = totalUsage.inHours;
    final minutes = totalUsage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedAverageDaily {
    final hours = averageDailyUsage.inHours;
    final minutes = averageDailyUsage.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
