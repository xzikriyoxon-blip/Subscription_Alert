import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/subscription_history.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

/// Provider for the FirestoreService singleton.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for the NotificationService singleton.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider that streams the current user's subscriptions.
/// 
/// Returns an empty list if the user is not authenticated.
/// Automatically updates when subscriptions change in Firestore.
final subscriptionsStreamProvider = StreamProvider<List<Subscription>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.watchSubscriptions(userId);
});

/// Provider for the list of subscriptions.
/// 
/// Returns the current list of subscriptions or an empty list if loading/error.
final subscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);
  return subscriptionsAsync.valueOrNull ?? [];
});

/// Provider that calculates the total monthly cost of all subscriptions.
/// 
/// Converts yearly subscriptions to their monthly equivalent (yearly / 12).
final totalMonthlyCostProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider);
  
  return subscriptions.fold(0.0, (total, subscription) {
    return total + subscription.monthlyEquivalent;
  });
});

/// Provider that returns subscriptions grouped by status.
final subscriptionsByStatusProvider = Provider<Map<SubscriptionStatus, List<Subscription>>>((ref) {
  final subscriptions = ref.watch(subscriptionsProvider);
  
  return {
    SubscriptionStatus.overdue: subscriptions
        .where((s) => s.status == SubscriptionStatus.overdue)
        .toList(),
    SubscriptionStatus.soon: subscriptions
        .where((s) => s.status == SubscriptionStatus.soon)
        .toList(),
    SubscriptionStatus.active: subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList(),
  };
});

/// Provider that returns the count of overdue subscriptions.
final overdueCountProvider = Provider<int>((ref) {
  final byStatus = ref.watch(subscriptionsByStatusProvider);
  return byStatus[SubscriptionStatus.overdue]?.length ?? 0;
});

/// Provider that returns the count of subscriptions due soon.
final soonCountProvider = Provider<int>((ref) {
  final byStatus = ref.watch(subscriptionsByStatusProvider);
  return byStatus[SubscriptionStatus.soon]?.length ?? 0;
});

/// Controller class for subscription operations.
/// 
/// Handles CRUD operations and notification scheduling.
class SubscriptionController {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;
  final String _userId;

  SubscriptionController({
    required FirestoreService firestoreService,
    required NotificationService notificationService,
    required String userId,
  })  : _firestoreService = firestoreService,
        _notificationService = notificationService,
        _userId = userId;

  /// Adds a new subscription and schedules notifications.
  Future<String> addSubscription(Subscription subscription) async {
    final subscriptionId = await _firestoreService.addSubscription(
      _userId,
      subscription,
    );

    // Create subscription with the new ID for notification scheduling
    final newSubscription = subscription.copyWith(id: subscriptionId);
    
    // Try to schedule notifications, but don't fail the whole operation if it fails
    try {
      await _notificationService.scheduleSubscriptionNotifications(newSubscription);
    } catch (e) {
      // Notification scheduling failed (e.g., exact alarms not permitted)
      // The subscription is still saved successfully
      debugPrint('SubscriptionController: Failed to schedule notifications: $e');
    }

    return subscriptionId;
  }

  /// Updates an existing subscription and reschedules notifications.
  Future<void> updateSubscription(Subscription subscription) async {
    await _firestoreService.updateSubscription(_userId, subscription);
    
    // Cancel old notifications and schedule new ones
    try {
      await _notificationService.cancelSubscriptionNotifications(subscription);
      await _notificationService.scheduleSubscriptionNotifications(subscription);
    } catch (e) {
      // Notification scheduling failed (e.g., exact alarms not permitted)
      debugPrint('SubscriptionController: Failed to reschedule notifications: $e');
    }
  }

  /// Deletes a subscription and cancels its notifications.
  Future<void> deleteSubscription(Subscription subscription) async {
    await _notificationService.cancelSubscriptionNotifications(subscription);
    await _firestoreService.deleteSubscription(_userId, subscription.id);
  }

  /// Reschedules notifications for all subscriptions.
  /// 
  /// Useful when app is opened or after significant time has passed.
  Future<void> rescheduleAllNotifications(List<Subscription> subscriptions) async {
    try {
      await _notificationService.cancelAllNotifications();
      
      for (final subscription in subscriptions) {
        await _notificationService.scheduleSubscriptionNotifications(subscription);
      }
    } catch (e) {
      // Notification scheduling failed (e.g., exact alarms not permitted)
      debugPrint('SubscriptionController: Failed to reschedule all notifications: $e');
    }
  }
}

/// Provider for the SubscriptionController.
/// 
/// Returns null if the user is not authenticated.
final subscriptionControllerProvider = Provider<SubscriptionController?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  if (userId == null) {
    return null;
  }

  return SubscriptionController(
    firestoreService: firestoreService,
    notificationService: notificationService,
    userId: userId,
  );
});

/// Provider that streams the current user's payment history.
final subscriptionHistoryProvider = StreamProvider<List<SubscriptionHistory>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (userId == null) {
    return Stream.value([]);
  }

  return firestoreService.watchHistory(userId);
});

/// Provider for history statistics.
final historyStatsProvider = Provider<HistoryStats>((ref) {
  final historyAsync = ref.watch(subscriptionHistoryProvider);
  final history = historyAsync.valueOrNull ?? [];
  return HistoryStats.fromHistory(history);
});
