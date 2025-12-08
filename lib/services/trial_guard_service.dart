import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import 'notification_service.dart';
import 'firestore_service.dart';

/// Service for monitoring free trial subscriptions and sending expiration warnings.
///
/// Trial Guard provides early warnings before a free trial converts to a paid subscription.
/// - FREE users: Get a single notification 1 day before trial ends
/// - PREMIUM users: Get notifications at 3 days and 1 day before trial ends
class TrialGuardService {
  final NotificationService _notificationService;
  final FirestoreService _firestoreService;

  TrialGuardService({
    required NotificationService notificationService,
    required FirestoreService firestoreService,
  })  : _notificationService = notificationService,
        _firestoreService = firestoreService;

  /// Checks all trial subscriptions for a user and sends appropriate warnings.
  ///
  /// This should be called:
  /// - When the app starts
  /// - Periodically (e.g., once per day)
  /// - When subscriptions are loaded/refreshed
  Future<TrialCheckResult> checkAndSendTrialWarnings({
    required String userId,
    required List<Subscription> subscriptions,
    required bool isPremium,
  }) async {
    final result = TrialCheckResult();

    // Filter to only trial subscriptions that haven't been cancelled
    final trialSubscriptions = subscriptions
        .where((s) => s.isTrial && !s.isCancelled && s.trialEndsAt != null)
        .toList();

    if (trialSubscriptions.isEmpty) {
      debugPrint('TrialGuard: No active trials found');
      return result;
    }

    debugPrint(
        'TrialGuard: Checking ${trialSubscriptions.length} trial subscriptions');

    for (final subscription in trialSubscriptions) {
      final warnings = await _checkSubscriptionTrial(
        userId: userId,
        subscription: subscription,
        isPremium: isPremium,
      );

      result.warningsSent += warnings;
      if (warnings > 0) {
        result.subscriptionsWarned.add(subscription.name);
      }
    }

    debugPrint('TrialGuard: Sent ${result.warningsSent} warnings');
    return result;
  }

  /// Checks a single subscription's trial status and sends warnings if needed.
  /// Returns the number of warnings sent.
  Future<int> _checkSubscriptionTrial({
    required String userId,
    required Subscription subscription,
    required bool isPremium,
  }) async {
    if (subscription.trialEndsAt == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trialEnd = DateTime(
      subscription.trialEndsAt!.year,
      subscription.trialEndsAt!.month,
      subscription.trialEndsAt!.day,
    );

    final daysUntilEnd = trialEnd.difference(today).inDays;
    int warningsSent = 0;

    debugPrint(
        'TrialGuard: ${subscription.name} - Trial ends in $daysUntilEnd days');

    if (isPremium) {
      // Premium users get 3-day and 1-day warnings
      warningsSent += await _checkPremiumWarnings(
        userId: userId,
        subscription: subscription,
        daysUntilEnd: daysUntilEnd,
      );
    } else {
      // Free users get only 1-day warning
      warningsSent += await _checkBasicWarning(
        userId: userId,
        subscription: subscription,
        daysUntilEnd: daysUntilEnd,
      );
    }

    return warningsSent;
  }

  /// Checks and sends basic (free user) warning - 1 day before.
  Future<int> _checkBasicWarning({
    required String userId,
    required Subscription subscription,
    required int daysUntilEnd,
  }) async {
    // Send warning 1 day before trial ends
    if (daysUntilEnd == 1 && !subscription.trialWarningSentBasic) {
      await _sendTrialWarningNotification(
        subscription: subscription,
        title: 'Trial ending soon',
        body: 'Your free trial for ${subscription.name} ends tomorrow.',
      );

      // Update the flag in Firestore
      await _updateSubscriptionWarningFlag(
        userId: userId,
        subscription: subscription,
        updates: {'trialWarningSentBasic': true},
      );

      debugPrint('TrialGuard: Sent basic warning for ${subscription.name}');
      return 1;
    }

    return 0;
  }

  /// Checks and sends premium user warnings - 3 days and 1 day before.
  Future<int> _checkPremiumWarnings({
    required String userId,
    required Subscription subscription,
    required int daysUntilEnd,
  }) async {
    int warningsSent = 0;

    // 3-day warning
    if (daysUntilEnd == 3 && !subscription.trialWarningSentPremium3d) {
      await _sendTrialWarningNotification(
        subscription: subscription,
        title: 'Trial ending in 3 days',
        body:
            'Your free trial for ${subscription.name} ends in 3 days. Cancel now if you don\'t want to be charged.',
      );

      await _updateSubscriptionWarningFlag(
        userId: userId,
        subscription: subscription,
        updates: {'trialWarningSentPremium3d': true},
      );

      debugPrint(
          'TrialGuard: Sent 3-day premium warning for ${subscription.name}');
      warningsSent++;
    }

    // 1-day warning (premium gets this too)
    if (daysUntilEnd == 1 && !subscription.trialWarningSentPremium1d) {
      await _sendTrialWarningNotification(
        subscription: subscription,
        title: 'Trial ending tomorrow',
        body:
            'Your free trial for ${subscription.name} ends tomorrow. Cancel now to avoid charges.',
      );

      await _updateSubscriptionWarningFlag(
        userId: userId,
        subscription: subscription,
        updates: {'trialWarningSentPremium1d': true},
      );

      debugPrint(
          'TrialGuard: Sent 1-day premium warning for ${subscription.name}');
      warningsSent++;
    }

    return warningsSent;
  }

  /// Sends a trial warning notification.
  Future<void> _sendTrialWarningNotification({
    required Subscription subscription,
    required String title,
    required String body,
  }) async {
    try {
      await _notificationService.showNotification(
        id: _generateNotificationId(subscription.id, 'trial'),
        title: title,
        body: body,
        payload: 'subscription:${subscription.id}',
      );
    } catch (e) {
      debugPrint('TrialGuard: Error sending notification: $e');
    }
  }

  /// Updates warning flags in Firestore.
  Future<void> _updateSubscriptionWarningFlag({
    required String userId,
    required Subscription subscription,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestoreService.updateSubscriptionFields(
        userId,
        subscription.id,
        updates,
      );
    } catch (e) {
      debugPrint('TrialGuard: Error updating warning flag: $e');
    }
  }

  /// Generates a unique notification ID for trial warnings.
  int _generateNotificationId(String subscriptionId, String type) {
    // Create a hash-based ID that's consistent for the same subscription
    final combined = '${subscriptionId}_$type';
    return combined.hashCode.abs() % 100000 + 50000; // Range: 50000-149999
  }

  /// Resets all trial warning flags for a subscription.
  /// Call this when the trial end date is changed.
  Future<void> resetTrialWarnings({
    required String userId,
    required String subscriptionId,
  }) async {
    try {
      await _firestoreService.updateSubscriptionFields(
        userId,
        subscriptionId,
        {
          'trialWarningSentBasic': false,
          'trialWarningSentPremium3d': false,
          'trialWarningSentPremium1d': false,
        },
      );
      debugPrint(
          'TrialGuard: Reset warning flags for subscription $subscriptionId');
    } catch (e) {
      debugPrint('TrialGuard: Error resetting warning flags: $e');
    }
  }

  /// Gets a summary of all active trials for a user.
  TrialSummary getTrialSummary(List<Subscription> subscriptions) {
    final trials = subscriptions
        .where((s) => s.isTrial && !s.isCancelled && s.trialEndsAt != null)
        .toList();

    if (trials.isEmpty) {
      return TrialSummary(
        totalTrials: 0,
        expiringSoon: 0,
        expired: 0,
        trialsExpiringSoon: [],
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int expiringSoon = 0;
    int expired = 0;
    final trialsExpiringSoon = <Subscription>[];

    for (final trial in trials) {
      final trialEnd = DateTime(
        trial.trialEndsAt!.year,
        trial.trialEndsAt!.month,
        trial.trialEndsAt!.day,
      );
      final daysUntil = trialEnd.difference(today).inDays;

      if (daysUntil < 0) {
        expired++;
      } else if (daysUntil <= 3) {
        expiringSoon++;
        trialsExpiringSoon.add(trial);
      }
    }

    return TrialSummary(
      totalTrials: trials.length,
      expiringSoon: expiringSoon,
      expired: expired,
      trialsExpiringSoon: trialsExpiringSoon,
    );
  }
}

/// Result of checking trials for warnings.
class TrialCheckResult {
  int warningsSent = 0;
  List<String> subscriptionsWarned = [];

  bool get hasWarnings => warningsSent > 0;
}

/// Summary of trial subscriptions.
class TrialSummary {
  final int totalTrials;
  final int expiringSoon;
  final int expired;
  final List<Subscription> trialsExpiringSoon;

  TrialSummary({
    required this.totalTrials,
    required this.expiringSoon,
    required this.expired,
    required this.trialsExpiringSoon,
  });

  bool get hasTrials => totalTrials > 0;
  bool get hasExpiringSoon => expiringSoon > 0;
  bool get hasExpired => expired > 0;
}
