import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's subscription (e.g., Netflix, Spotify).
/// 
/// Contains all information needed to track and notify about
/// upcoming payment dates, including free trial tracking.
class Subscription {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String cycle; // "monthly", "yearly", "weekly", "quarterly"
  final DateTime nextPaymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? brandId; // ID of the brand for logo and cancellation link
  final bool isCancelled; // Whether the subscription has been cancelled
  final DateTime? cancelledAt; // When the subscription was cancelled
  
  // Trial Guard fields
  final bool isTrial; // Whether this is a free trial
  final DateTime? trialEndsAt; // When the trial ends (only set if isTrial is true)
  final bool trialWarningSentBasic; // For free-user one-time warning (1 day before)
  final bool trialWarningSentPremium3d; // 3-day warning sent (premium)
  final bool trialWarningSentPremium1d; // 1-day warning sent (premium)

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    this.currency = 'UZS',
    required this.cycle,
    required this.nextPaymentDate,
    required this.createdAt,
    required this.updatedAt,
    this.brandId,
    this.isCancelled = false,
    this.cancelledAt,
    this.isTrial = false,
    this.trialEndsAt,
    this.trialWarningSentBasic = false,
    this.trialWarningSentPremium3d = false,
    this.trialWarningSentPremium1d = false,
  });

  /// Creates a Subscription from a Firestore document snapshot.
  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'UZS',
      cycle: data['cycle'] as String? ?? 'monthly',
      nextPaymentDate: (data['nextPaymentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      brandId: data['brandId'] as String?,
      isCancelled: data['isCancelled'] as bool? ?? false,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      isTrial: data['isTrial'] as bool? ?? false,
      trialEndsAt: (data['trialEndsAt'] as Timestamp?)?.toDate(),
      trialWarningSentBasic: data['trialWarningSentBasic'] as bool? ?? false,
      trialWarningSentPremium3d: data['trialWarningSentPremium3d'] as bool? ?? false,
      trialWarningSentPremium1d: data['trialWarningSentPremium1d'] as bool? ?? false,
    );
  }

  /// Converts the Subscription to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'currency': currency,
      'cycle': cycle,
      'nextPaymentDate': Timestamp.fromDate(nextPaymentDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'brandId': brandId,
      'isCancelled': isCancelled,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'isTrial': isTrial,
      'trialEndsAt': trialEndsAt != null ? Timestamp.fromDate(trialEndsAt!) : null,
      'trialWarningSentBasic': trialWarningSentBasic,
      'trialWarningSentPremium3d': trialWarningSentPremium3d,
      'trialWarningSentPremium1d': trialWarningSentPremium1d,
    };
  }

  /// Creates a copy of this Subscription with the given fields replaced.
  /// Use [clearCancelledAt] = true to explicitly set cancelledAt to null.
  /// Use [clearTrialEndsAt] = true to explicitly set trialEndsAt to null.
  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    String? cycle,
    DateTime? nextPaymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brandId,
    bool? isCancelled,
    DateTime? cancelledAt,
    bool clearCancelledAt = false,
    bool? isTrial,
    DateTime? trialEndsAt,
    bool clearTrialEndsAt = false,
    bool? trialWarningSentBasic,
    bool? trialWarningSentPremium3d,
    bool? trialWarningSentPremium1d,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      cycle: cycle ?? this.cycle,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brandId: brandId ?? this.brandId,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: clearCancelledAt ? null : (cancelledAt ?? this.cancelledAt),
      isTrial: isTrial ?? this.isTrial,
      trialEndsAt: clearTrialEndsAt ? null : (trialEndsAt ?? this.trialEndsAt),
      trialWarningSentBasic: trialWarningSentBasic ?? this.trialWarningSentBasic,
      trialWarningSentPremium3d: trialWarningSentPremium3d ?? this.trialWarningSentPremium3d,
      trialWarningSentPremium1d: trialWarningSentPremium1d ?? this.trialWarningSentPremium1d,
    );
  }

  /// Calculates the monthly equivalent cost.
  /// For yearly subscriptions, divides by 12.
  /// For trials, returns 0 until trial ends.
  double get monthlyEquivalent {
    // If it's an active trial, cost is effectively 0
    if (isTrial && trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now())) {
      return 0;
    }
    
    switch (cycle.toLowerCase()) {
      case 'weekly':
        return price * 4.33; // Average weeks per month
      case 'quarterly':
        return price / 3;
      case 'yearly':
      case 'annual':
        return price / 12;
      default: // monthly
        return price;
    }
  }
  
  /// Returns the number of days until the trial ends.
  /// Returns null if not a trial or trial date not set.
  int? get daysUntilTrialEnds {
    if (!isTrial || trialEndsAt == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trialEnd = DateTime(trialEndsAt!.year, trialEndsAt!.month, trialEndsAt!.day);
    return trialEnd.difference(today).inDays;
  }
  
  /// Returns true if the trial has expired.
  bool get isTrialExpired {
    if (!isTrial || trialEndsAt == null) return false;
    return trialEndsAt!.isBefore(DateTime.now());
  }

  /// Returns the status of the subscription based on nextPaymentDate.
  /// - "cancelled" if subscription is cancelled
  /// - "overdue" if the date is in the past
  /// - "soon" if the date is within the next 3 days
  /// - "active" otherwise
  SubscriptionStatus get status {
    if (isCancelled) {
      return SubscriptionStatus.cancelled;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paymentDay = DateTime(
      nextPaymentDate.year,
      nextPaymentDate.month,
      nextPaymentDate.day,
    );

    if (paymentDay.isBefore(today)) {
      return SubscriptionStatus.overdue;
    }

    final difference = paymentDay.difference(today).inDays;
    if (difference <= 3) {
      return SubscriptionStatus.soon;
    }

    return SubscriptionStatus.active;
  }

  @override
  String toString() {
    return 'Subscription(id: $id, name: $name, price: $price $currency, '
        'cycle: $cycle, nextPaymentDate: $nextPaymentDate, cancelled: $isCancelled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Represents the payment status of a subscription.
enum SubscriptionStatus {
  active,
  soon,
  overdue,
  cancelled,
}
