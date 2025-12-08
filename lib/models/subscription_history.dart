import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a historical payment record for a subscription.
/// 
/// Tracks when payments were made and stores details about each payment.
class SubscriptionHistory {
  final String id;
  final String subscriptionId;
  final String subscriptionName;
  final double amount;
  final String currency;
  final DateTime paidDate;
  final String? note;
  final DateTime createdAt;

  SubscriptionHistory({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.amount,
    required this.currency,
    required this.paidDate,
    this.note,
    required this.createdAt,
  });

  /// Creates a SubscriptionHistory from a Firestore document snapshot.
  factory SubscriptionHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionHistory(
      id: doc.id,
      subscriptionId: data['subscriptionId'] as String? ?? '',
      subscriptionName: data['subscriptionName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'USD',
      paidDate: (data['paidDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the SubscriptionHistory to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'subscriptionId': subscriptionId,
      'subscriptionName': subscriptionName,
      'amount': amount,
      'currency': currency,
      'paidDate': Timestamp.fromDate(paidDate),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy with updated fields.
  SubscriptionHistory copyWith({
    String? id,
    String? subscriptionId,
    String? subscriptionName,
    double? amount,
    String? currency,
    DateTime? paidDate,
    String? note,
    DateTime? createdAt,
  }) {
    return SubscriptionHistory(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paidDate: paidDate ?? this.paidDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionHistory(id: $id, subscriptionName: $subscriptionName, '
        'amount: $amount $currency, paidDate: $paidDate)';
  }
}

/// Statistics about subscription history.
class HistoryStats {
  final double totalSpent;
  final double thisMonthSpent;
  final double thisYearSpent;
  final int totalPayments;
  final Map<String, double> spentBySubscription;
  final Map<String, double> spentByCurrency;
  final Map<int, double> spentByMonth; // Month (1-12) -> amount

  HistoryStats({
    required this.totalSpent,
    required this.thisMonthSpent,
    required this.thisYearSpent,
    required this.totalPayments,
    required this.spentBySubscription,
    required this.spentByCurrency,
    required this.spentByMonth,
  });

  factory HistoryStats.empty() {
    return HistoryStats(
      totalSpent: 0,
      thisMonthSpent: 0,
      thisYearSpent: 0,
      totalPayments: 0,
      spentBySubscription: {},
      spentByCurrency: {},
      spentByMonth: {},
    );
  }

  /// Calculate stats from a list of history records.
  factory HistoryStats.fromHistory(List<SubscriptionHistory> history, {String? baseCurrency}) {
    if (history.isEmpty) {
      return HistoryStats.empty();
    }

    final now = DateTime.now();
    double totalSpent = 0;
    double thisMonthSpent = 0;
    double thisYearSpent = 0;
    final spentBySubscription = <String, double>{};
    final spentByCurrency = <String, double>{};
    final spentByMonth = <int, double>{};

    for (final record in history) {
      totalSpent += record.amount;
      
      // This month
      if (record.paidDate.year == now.year && record.paidDate.month == now.month) {
        thisMonthSpent += record.amount;
      }
      
      // This year
      if (record.paidDate.year == now.year) {
        thisYearSpent += record.amount;
        
        // By month
        spentByMonth[record.paidDate.month] = 
            (spentByMonth[record.paidDate.month] ?? 0) + record.amount;
      }
      
      // By subscription
      spentBySubscription[record.subscriptionName] = 
          (spentBySubscription[record.subscriptionName] ?? 0) + record.amount;
      
      // By currency
      spentByCurrency[record.currency] = 
          (spentByCurrency[record.currency] ?? 0) + record.amount;
    }

    return HistoryStats(
      totalSpent: totalSpent,
      thisMonthSpent: thisMonthSpent,
      thisYearSpent: thisYearSpent,
      totalPayments: history.length,
      spentBySubscription: spentBySubscription,
      spentByCurrency: spentByCurrency,
      spentByMonth: spentByMonth,
    );
  }
}
