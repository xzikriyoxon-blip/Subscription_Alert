import '../models/subscription.dart';
import '../models/timeline_entry.dart';

/// Service for generating subscription timeline data.
/// 
/// Converts subscription data into timeline entries for
/// past and future payment visualization.
class TimelineService {
  static final TimelineService _instance = TimelineService._internal();
  factory TimelineService() => _instance;
  TimelineService._internal();

  /// Generate timeline from subscriptions
  /// 
  /// [pastMonths] - How many months of past payments to show
  /// [futureMonths] - How many months of future payments to show
  /// [isPremium] - Premium users see full timeline, free users see limited
  SubscriptionTimeline generateTimeline({
    required List<Subscription> subscriptions,
    int pastMonths = 3,
    int futureMonths = 6,
    bool isPremium = false,
  }) {
    // Apply premium limits
    if (!isPremium) {
      pastMonths = 1;
      futureMonths = 2;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Filter active subscriptions
    final activeSubscriptions = subscriptions
        .where((s) => !s.isCancelled)
        .toList();

    final entries = <TimelineEntry>[];

    // Generate past entries
    for (var monthOffset = -pastMonths; monthOffset <= futureMonths; monthOffset++) {
      final targetMonth = DateTime(now.year, now.month + monthOffset, 1);
      
      for (final sub in activeSubscriptions) {
        final entriesForMonth = _getEntriesForMonth(sub, targetMonth, today);
        entries.addAll(entriesForMonth);
      }
    }

    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    // Group by month
    final monthGroups = <String, List<TimelineEntry>>{};
    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month}';
      monthGroups.putIfAbsent(key, () => []);
      monthGroups[key]!.add(entry);
    }

    // Create TimelineMonth objects
    final allMonths = <TimelineMonth>[];
    double totalPast = 0;
    double totalFuture = 0;

    for (final entry in monthGroups.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthDate = DateTime(year, month, 1);
      
      final isFuture = monthDate.isAfter(DateTime(now.year, now.month, 1));
      final isCurrentMonth = monthDate.year == now.year && monthDate.month == now.month;
      
      final total = entry.value.fold<double>(0, (sum, e) => sum + e.amount);
      
      if (isFuture) {
        totalFuture += total;
      } else if (!isCurrentMonth) {
        totalPast += total;
      }

      allMonths.add(TimelineMonth(
        monthYear: entry.value.first.monthYear,
        month: month,
        year: year,
        entries: entry.value,
        totalAmount: total,
        isFuture: isFuture,
      ));
    }

    // Sort months chronologically
    allMonths.sort((a, b) {
      final dateA = DateTime(a.year, a.month);
      final dateB = DateTime(b.year, b.month);
      return dateA.compareTo(dateB);
    });

    // Split into past, current, future
    final pastMonthsList = allMonths.where((m) => 
        DateTime(m.year, m.month).isBefore(DateTime(now.year, now.month))).toList();
    final futureMonthsList = allMonths.where((m) => 
        DateTime(m.year, m.month).isAfter(DateTime(now.year, now.month))).toList();
    final currentMonth = allMonths.cast<TimelineMonth?>().firstWhere(
        (m) => m != null && m.year == now.year && m.month == now.month, 
        orElse: () => null);

    return SubscriptionTimeline(
      pastMonths: pastMonthsList,
      futureMonths: futureMonthsList,
      currentMonth: currentMonth,
      totalPastSpend: totalPast,
      totalFutureSpend: totalFuture,
    );
  }

  /// Get timeline entries for a subscription in a specific month
  List<TimelineEntry> _getEntriesForMonth(
    Subscription subscription,
    DateTime targetMonth,
    DateTime today,
  ) {
    final entries = <TimelineEntry>[];
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0);

    // Calculate payment dates based on cycle
    DateTime paymentDate = subscription.nextPaymentDate;
    
    // Go back to find the first payment date
    while (paymentDate.isAfter(startOfMonth)) {
      paymentDate = _previousPaymentDate(paymentDate, subscription.cycle);
    }

    // Now go forward to find payments in this month
    while (paymentDate.isBefore(startOfMonth)) {
      paymentDate = _nextPaymentDate(paymentDate, subscription.cycle);
    }

    // Add all payments that fall within this month
    while (!paymentDate.isAfter(endOfMonth)) {
      // Determine entry type
      EntryType type;
      if (paymentDate.year == today.year && 
          paymentDate.month == today.month && 
          paymentDate.day == today.day) {
        type = EntryType.today;
      } else if (paymentDate.isAfter(today)) {
        type = EntryType.future;
      } else {
        type = EntryType.past;
      }
      
      entries.add(TimelineEntry(
        subscriptionId: subscription.id,
        name: subscription.name,
        date: paymentDate,
        amount: subscription.price,
        currency: subscription.currency,
        type: type,
        brandId: subscription.brandId,
        planName: null,
        cycle: subscription.cycle,
      ));

      paymentDate = _nextPaymentDate(paymentDate, subscription.cycle);
    }

    return entries;
  }

  /// Calculate next payment date based on cycle
  DateTime _nextPaymentDate(DateTime current, String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'quarterly':
        return DateTime(current.year, current.month + 3, current.day);
      case 'yearly':
      case 'annual':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return DateTime(current.year, current.month + 1, current.day);
    }
  }

  /// Calculate previous payment date based on cycle
  DateTime _previousPaymentDate(DateTime current, String cycle) {
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return current.subtract(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month - 1, current.day);
      case 'quarterly':
        return DateTime(current.year, current.month - 3, current.day);
      case 'yearly':
      case 'annual':
        return DateTime(current.year - 1, current.month, current.day);
      default:
        return DateTime(current.year, current.month - 1, current.day);
    }
  }

  /// Get summary statistics for timeline
  Map<String, dynamic> getTimelineSummary(SubscriptionTimeline timeline) {
    int totalEntries = 0;
    double totalAmount = 0;
    
    for (final month in timeline.allMonths) {
      totalEntries += month.entries.length;
      totalAmount += month.totalAmount;
    }

    return {
      'totalMonths': timeline.allMonths.length,
      'totalEntries': totalEntries,
      'totalAmount': totalAmount,
      'pastSpend': timeline.totalPastSpend,
      'futureSpend': timeline.totalFutureSpend,
      'averageMonthly': totalAmount / timeline.allMonths.length,
    };
  }
}
