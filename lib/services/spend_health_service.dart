import '../models/subscription.dart';
import '../models/spend_health.dart';
import '../models/subscription_brand.dart';

/// Service for calculating spend health scores.
/// 
/// Analyzes subscription behavior and provides a financial
/// wellness score with actionable suggestions.
class SpendHealthService {
  static final SpendHealthService _instance = SpendHealthService._internal();
  factory SpendHealthService() => _instance;
  SpendHealthService._internal();

  /// Calculate spend health score
  /// 
  /// [subscriptions] - User's subscriptions
  /// [monthlyIncome] - Optional monthly income for ratio calculation
  /// [baseCurrency] - User's base currency for threshold comparison
  SpendHealthScore calculate({
    required List<Subscription> subscriptions,
    double? monthlyIncome,
    String baseCurrency = 'USD',
  }) {
    // Filter active subscriptions
    final activeSubscriptions = subscriptions
        .where((s) => !s.isCancelled)
        .toList();

    // Start with perfect score
    int score = 100;
    final suggestions = <String>[];

    // 1. Subscription count analysis
    final subCount = activeSubscriptions.length;
    int subPenalty = 0;
    
    if (subCount > SpendingThresholds.criticalSubscriptionCount) {
      subPenalty = 20;
      suggestions.add('You have $subCount subscriptions. Consider consolidating or cancelling unused services.');
    } else if (subCount > SpendingThresholds.warningSubscriptionCount) {
      subPenalty = 10;
      suggestions.add('You have $subCount subscriptions. Review if you\'re using all of them regularly.');
    }
    score -= subPenalty;

    // 2. Monthly total analysis
    final monthlyTotal = _calculateMonthlyTotal(activeSubscriptions);
    int monthlyPenalty = 0;
    
    if (monthlyTotal > SpendingThresholds.criticalMonthly) {
      monthlyPenalty = 20;
      suggestions.add('Your monthly subscription spend (\$${monthlyTotal.toStringAsFixed(2)}) is quite high. Look for ways to reduce costs.');
    } else if (monthlyTotal > SpendingThresholds.warningMonthly) {
      monthlyPenalty = 10;
      suggestions.add('Consider reviewing subscriptions with similar features to potentially save money.');
    }
    score -= monthlyPenalty;

    // 3. Duplicate category analysis
    final duplicates = _findDuplicateCategories(activeSubscriptions);
    int duplicatePenalty = duplicates.length * 5;
    duplicatePenalty = duplicatePenalty.clamp(0, 20); // Max 20 points
    
    if (duplicates.isNotEmpty) {
      for (final category in duplicates) {
        suggestions.add('You have multiple $category services. Consider keeping only one.');
      }
    }
    score -= duplicatePenalty;

    // 4. Trial risk analysis
    final trialsEndingSoon = _countTrialsEndingSoon(activeSubscriptions);
    int trialPenalty = 0;
    
    if (trialsEndingSoon > 2) {
      trialPenalty = 10;
      suggestions.add('You have $trialsEndingSoon trials ending soon. Set reminders to cancel unwanted ones.');
    } else if (trialsEndingSoon > 0) {
      trialPenalty = 5;
      suggestions.add('Don\'t forget to review your trial subscriptions before they convert to paid.');
    }
    score -= trialPenalty;

    // 5. Income ratio analysis (if provided)
    int incomePenalty = 0;
    double? incomeRatio;
    
    if (monthlyIncome != null && monthlyIncome > 0) {
      incomeRatio = monthlyTotal / monthlyIncome;
      
      if (incomeRatio > SpendingThresholds.incomeRatioCritical) {
        incomePenalty = 15;
        suggestions.add('Subscriptions are ${(incomeRatio * 100).toStringAsFixed(1)}% of your income. Try to keep it under 5%.');
      } else if (incomeRatio > SpendingThresholds.incomeRatioWarning) {
        incomePenalty = 7;
        suggestions.add('Subscriptions are ${(incomeRatio * 100).toStringAsFixed(1)}% of your income. Consider optimizing.');
      }
    }
    score -= incomePenalty;

    // Ensure score is within bounds
    score = score.clamp(0, 100);

    // Add positive suggestions if score is good
    if (score >= 80 && suggestions.isEmpty) {
      suggestions.add('Great job managing your subscriptions! Keep monitoring for any changes.');
    }

    // Determine status
    final status = _getStatus(score);

    // Create factors list for UI display
    final factors = <ScoreFactor>[];
    
    if (subPenalty > 0) {
      factors.add(ScoreFactor(
        name: 'Subscription Count',
        impact: -subPenalty,
        description: '$subCount active subscriptions',
      ));
    } else {
      factors.add(ScoreFactor(
        name: 'Subscription Count',
        impact: 0,
        description: '$subCount subscriptions - reasonable',
      ));
    }
    
    if (monthlyPenalty > 0) {
      factors.add(ScoreFactor(
        name: 'Monthly Spending',
        impact: -monthlyPenalty,
        description: '\$${monthlyTotal.toStringAsFixed(2)}/month',
      ));
    } else {
      factors.add(ScoreFactor(
        name: 'Monthly Spending',
        impact: 0,
        description: '\$${monthlyTotal.toStringAsFixed(2)}/month - within limits',
      ));
    }
    
    if (duplicatePenalty > 0) {
      factors.add(ScoreFactor(
        name: 'Duplicate Services',
        impact: -duplicatePenalty,
        description: '${duplicates.length} overlapping categories',
      ));
    }
    
    if (trialPenalty > 0) {
      factors.add(ScoreFactor(
        name: 'Expiring Trials',
        impact: -trialPenalty,
        description: '$trialsEndingSoon trials ending soon',
      ));
    }
    
    if (incomePenalty > 0 && incomeRatio != null) {
      factors.add(ScoreFactor(
        name: 'Income Ratio',
        impact: -incomePenalty,
        description: '${(incomeRatio * 100).toStringAsFixed(1)}% of income',
      ));
    } else if (incomeRatio != null) {
      factors.add(ScoreFactor(
        name: 'Income Ratio',
        impact: 0,
        description: '${(incomeRatio * 100).toStringAsFixed(1)}% of income - healthy',
      ));
    }

    // Create breakdown
    final breakdown = SpendHealthBreakdown(
      subscriptionCount: subCount,
      subscriptionPenalty: subPenalty,
      monthlyTotal: monthlyTotal,
      monthlyTotalPenalty: monthlyPenalty,
      duplicateCategories: duplicates.length,
      duplicatePenalty: duplicatePenalty,
      trialsEndingSoon: trialsEndingSoon,
      trialsPenalty: trialPenalty,
      monthlyIncome: monthlyIncome,
      incomeRatio: incomeRatio,
      incomePenalty: incomePenalty,
    );

    return SpendHealthScore(
      score: score,
      status: status,
      suggestions: suggestions,
      factors: factors,
      breakdown: breakdown,
    );
  }

  /// Calculate total monthly cost of subscriptions
  double _calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold<double>(0, (total, sub) {
      return total + sub.monthlyEquivalent;
    });
  }

  /// Find duplicate service categories
  List<String> _findDuplicateCategories(List<Subscription> subscriptions) {
    final duplicates = <String>[];
    final categoryCounts = <String, int>{};

    for (final sub in subscriptions) {
      final brandId = sub.brandId?.toLowerCase() ?? sub.name.toLowerCase();
      final category = DuplicateCategories.getCategoryForService(brandId);
      
      if (category != null) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }

    for (final entry in categoryCounts.entries) {
      if (entry.value > 1) {
        duplicates.add(entry.key);
      }
    }

    return duplicates;
  }

  /// Count trials ending in the next 7 days
  int _countTrialsEndingSoon(List<Subscription> subscriptions) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return subscriptions.where((sub) {
      if (!sub.isTrial || sub.trialEndsAt == null) return false;
      return sub.trialEndsAt!.isAfter(now) && sub.trialEndsAt!.isBefore(weekFromNow);
    }).length;
  }

  /// Get health status based on score
  HealthStatus _getStatus(int score) {
    if (score >= 80) return HealthStatus.excellent;
    if (score >= 60) return HealthStatus.good;
    if (score >= 40) return HealthStatus.warning;
    return HealthStatus.critical;
  }

  /// Get detailed analysis for premium users
  Map<String, dynamic> getDetailedAnalysis({
    required List<Subscription> subscriptions,
    double? monthlyIncome,
  }) {
    final activeSubscriptions = subscriptions.where((s) => !s.isCancelled).toList();
    final monthlyTotal = _calculateMonthlyTotal(activeSubscriptions);
    
    // Category breakdown - use brand categories for better classification
    final categorySpending = <String, double>{};
    for (final sub in activeSubscriptions) {
      final category = _getCategoryForSubscription(sub);
      categorySpending[category] = (categorySpending[category] ?? 0) + sub.monthlyEquivalent;
    }

    // Highest cost subscriptions
    final sortedByPrice = List<Subscription>.from(activeSubscriptions)
      ..sort((a, b) => b.monthlyEquivalent.compareTo(a.monthlyEquivalent));
    final highestCost = sortedByPrice.take(3).toList();

    // Yearly projection
    final yearlyProjection = monthlyTotal * 12;

    // Potential savings (if duplicates removed)
    double potentialSavings = 0;
    for (final category in _findDuplicateCategories(activeSubscriptions)) {
      final servicesInCategory = activeSubscriptions.where((sub) {
        final brandId = sub.brandId?.toLowerCase() ?? sub.name.toLowerCase();
        return DuplicateCategories.getCategoryForService(brandId) == category;
      }).toList();
      
      if (servicesInCategory.length > 1) {
        servicesInCategory.sort((a, b) => a.monthlyEquivalent.compareTo(b.monthlyEquivalent));
        // Keep cheapest, sum rest as potential savings
        for (var i = 1; i < servicesInCategory.length; i++) {
          potentialSavings += servicesInCategory[i].monthlyEquivalent;
        }
      }
    }

    return {
      'totalMonthly': monthlyTotal,
      'yearlyProjection': yearlyProjection,
      'activeCount': activeSubscriptions.length,
      'categoryBreakdown': categorySpending,
      'highestCostSubscriptions': highestCost,
      'potentialMonthlySavings': potentialSavings,
      'potentialYearlySavings': potentialSavings * 12,
      'averagePerSubscription': activeSubscriptions.isNotEmpty 
          ? monthlyTotal / activeSubscriptions.length 
          : 0,
    };
  }

  /// Get category for a subscription using brand database
  String _getCategoryForSubscription(Subscription sub) {
    // First try to find the brand in our database
    final brandId = sub.brandId?.toLowerCase();
    if (brandId != null) {
      final brand = SubscriptionBrands.all.where(
        (b) => b.id.toLowerCase() == brandId
      ).firstOrNull;
      if (brand != null) {
        return brand.category;
      }
    }
    
    // Try matching by name
    final nameLower = sub.name.toLowerCase();
    final brandByName = SubscriptionBrands.all.where(
      (b) => b.name.toLowerCase() == nameLower || 
             b.id.toLowerCase() == nameLower.replaceAll(' ', '_')
    ).firstOrNull;
    if (brandByName != null) {
      return brandByName.category;
    }
    
    // Check DuplicateCategories for backward compatibility
    final duplicateCategory = DuplicateCategories.getCategoryForService(
      brandId ?? nameLower.replaceAll(' ', '_')
    );
    if (duplicateCategory != null) {
      // Map DuplicateCategories names to BrandCategory names
      switch (duplicateCategory) {
        case 'Music Streaming':
          return BrandCategory.music;
        case 'Video Streaming':
          return BrandCategory.streaming;
        case 'Cloud Storage':
          return BrandCategory.cloud;
        case 'VPN Services':
          return BrandCategory.vpn;
        case 'News & Reading':
          return BrandCategory.news;
      }
    }
    
    return BrandCategory.other;
  }
}
