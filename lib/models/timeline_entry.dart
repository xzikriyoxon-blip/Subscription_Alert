/// Type of timeline entry
enum EntryType {
  past,
  today,
  future,
}

/// Model for subscription timeline entries.
/// 
/// Used to display past and future subscription charges
/// in a timeline view.
class TimelineEntry {
  final String subscriptionId;
  final String name;
  final DateTime date;
  final double amount;
  final String currency;
  final EntryType type;
  final String? brandId;
  final String? planName;
  final String cycle;

  const TimelineEntry({
    required this.subscriptionId,
    required this.name,
    required this.date,
    required this.amount,
    required this.currency,
    required this.type,
    this.brandId,
    this.planName,
    required this.cycle,
  });

  /// Check if this entry is today
  bool get isToday => type == EntryType.today;

  /// Check if this entry is in the past
  bool get isPast => type == EntryType.past;
  
  /// Check if this entry is in the future
  bool get isFuture => type == EntryType.future;

  /// Get formatted month/year for grouping
  String get monthYear {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Grouped timeline entries by month
class TimelineMonth {
  final String monthYear;
  final int month;
  final int year;
  final List<TimelineEntry> entries;
  final double totalAmount;
  final bool isFuture;

  TimelineMonth({
    required this.monthYear,
    required this.month,
    required this.year,
    required this.entries,
    required this.totalAmount,
    required this.isFuture,
  });

  /// Check if this month is the current month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }
}

/// Timeline data container
class SubscriptionTimeline {
  final List<TimelineMonth> pastMonths;
  final List<TimelineMonth> futureMonths;
  final TimelineMonth? currentMonth;
  final double totalPastSpend;
  final double totalFutureSpend;

  SubscriptionTimeline({
    required this.pastMonths,
    required this.futureMonths,
    this.currentMonth,
    required this.totalPastSpend,
    required this.totalFutureSpend,
  });

  /// Get all months in chronological order
  List<TimelineMonth> get allMonths {
    final all = <TimelineMonth>[];
    all.addAll(pastMonths);
    if (currentMonth != null) all.add(currentMonth!);
    all.addAll(futureMonths);
    return all;
  }
}
