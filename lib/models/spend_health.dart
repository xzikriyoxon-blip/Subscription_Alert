/// Model for the Spend Health Score feature.
/// 
/// Provides a financial wellness score based on subscription behavior.
class SpendHealthScore {
  final int score;           // 0-100
  final HealthStatus status;
  final List<String> suggestions;
  final List<ScoreFactor> factors;
  final SpendHealthBreakdown breakdown;

  const SpendHealthScore({
    required this.score,
    required this.status,
    required this.suggestions,
    required this.factors,
    required this.breakdown,
  });

  /// Get color for the score
  String get statusColor {
    switch (status) {
      case HealthStatus.excellent:
        return '#4CAF50'; // Green
      case HealthStatus.good:
        return '#8BC34A'; // Light Green
      case HealthStatus.warning:
        return '#FF9800'; // Orange
      case HealthStatus.critical:
        return '#F44336'; // Red
    }
  }
}

/// Factor contributing to the score
class ScoreFactor {
  final String name;
  final int impact;  // Positive or negative points
  final String description;

  const ScoreFactor({
    required this.name,
    required this.impact,
    required this.description,
  });
}

/// Health status categories
enum HealthStatus {
  excellent, // 80-100
  good,      // 60-79
  warning,   // 40-59
  critical,  // 0-39
}

extension HealthStatusExtension on HealthStatus {
  String get label {
    switch (this) {
      case HealthStatus.excellent:
        return 'Excellent';
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.warning:
        return 'Warning';
      case HealthStatus.critical:
        return 'Critical';
    }
  }

  String get emoji {
    switch (this) {
      case HealthStatus.excellent:
        return '🌟';
      case HealthStatus.good:
        return '👍';
      case HealthStatus.warning:
        return '⚠️';
      case HealthStatus.critical:
        return '🚨';
    }
  }

  String get description {
    switch (this) {
      case HealthStatus.excellent:
        return 'Your subscription spending is well managed!';
      case HealthStatus.good:
        return 'You\'re doing well, but there\'s room for improvement.';
      case HealthStatus.warning:
        return 'Consider reviewing your subscriptions to optimize spending.';
      case HealthStatus.critical:
        return 'Your subscription costs need immediate attention.';
    }
  }
}

/// Detailed breakdown of score factors
class SpendHealthBreakdown {
  final int subscriptionCount;
  final int subscriptionPenalty;  // Points deducted for too many subs
  
  final double monthlyTotal;
  final int monthlyTotalPenalty;  // Points deducted for high spending
  
  final int duplicateCategories;
  final int duplicatePenalty;     // Points for duplicate services
  
  final int trialsEndingSoon;
  final int trialsPenalty;        // Points for risky trials
  
  final int unusedSubscriptions;  // Not used in 30+ days (future feature)
  final int unusedPenalty;
  
  final double? monthlyIncome;    // Optional: user-provided income
  final double? incomeRatio;      // subscriptions / income
  final int incomePenalty;

  const SpendHealthBreakdown({
    required this.subscriptionCount,
    required this.subscriptionPenalty,
    required this.monthlyTotal,
    required this.monthlyTotalPenalty,
    required this.duplicateCategories,
    required this.duplicatePenalty,
    required this.trialsEndingSoon,
    required this.trialsPenalty,
    this.unusedSubscriptions = 0,
    this.unusedPenalty = 0,
    this.monthlyIncome,
    this.incomeRatio,
    this.incomePenalty = 0,
  });

  /// Get total penalty points
  int get totalPenalty => 
      subscriptionPenalty + 
      monthlyTotalPenalty + 
      duplicatePenalty + 
      trialsPenalty + 
      unusedPenalty +
      incomePenalty;
}

/// Categories that are considered duplicates when multiple exist
class DuplicateCategories {
  static const List<String> musicServices = [
    'spotify', 'apple_music', 'youtube_music', 'amazon_music', 
    'tidal', 'deezer', 'soundcloud'
  ];
  
  static const List<String> videoStreaming = [
    'netflix', 'amazon_prime', 'disney_plus', 'hbo_max', 
    'hulu', 'paramount_plus', 'peacock', 'apple_tv'
  ];
  
  static const List<String> cloudStorage = [
    'google_one', 'icloud', 'dropbox', 'onedrive', 'box'
  ];
  
  static const List<String> vpnServices = [
    'nordvpn', 'expressvpn', 'surfshark', 'protonvpn', 'cyberghost'
  ];

  static const List<String> newsServices = [
    'nytimes', 'wsj', 'washington_post', 'economist', 'medium'
  ];

  static const Map<String, List<String>> categories = {
    'Music Streaming': musicServices,
    'Video Streaming': videoStreaming,
    'Cloud Storage': cloudStorage,
    'VPN Services': vpnServices,
    'News & Reading': newsServices,
  };

  /// Check which category a service belongs to
  static String? getCategoryForService(String brandId) {
    final id = brandId.toLowerCase();
    for (final entry in categories.entries) {
      if (entry.value.contains(id)) {
        return entry.key;
      }
    }
    return null;
  }
}

/// Spending thresholds for scoring
class SpendingThresholds {
  static const double warningMonthly = 50.0;   // USD
  static const double criticalMonthly = 100.0;  // USD
  
  static const int warningSubscriptionCount = 7;
  static const int criticalSubscriptionCount = 12;
  
  static const double incomeRatioWarning = 0.05;  // 5% of income
  static const double incomeRatioCritical = 0.10; // 10% of income
}
