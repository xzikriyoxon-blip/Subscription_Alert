import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';
import '../models/subscription_history.dart';

/// Service class for Firestore database operations.
/// 
/// Handles all CRUD operations for subscriptions stored under
/// the authenticated user's document.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a reference to the subscriptions subcollection for a user.
  CollectionReference<Map<String, dynamic>> _subscriptionsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions');
  }

  /// Returns a reference to the history subcollection for a user.
  CollectionReference<Map<String, dynamic>> _historyRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history');
  }

  /// Watches all subscriptions for a user in real-time.
  /// 
  /// Returns a stream that emits the updated list whenever changes occur.
  Stream<List<Subscription>> watchSubscriptions(String userId) {
    return _subscriptionsRef(userId)
        .orderBy('nextPaymentDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Subscription.fromFirestore(doc))
          .toList();
    });
  }

  /// Fetches all subscriptions for a user once.
  Future<List<Subscription>> getSubscriptions(String userId) async {
    final snapshot = await _subscriptionsRef(userId)
        .orderBy('nextPaymentDate', descending: false)
        .get();
    
    return snapshot.docs
        .map((doc) => Subscription.fromFirestore(doc))
        .toList();
  }

  /// Adds a new subscription for a user.
  /// 
  /// Returns the ID of the newly created document.
  Future<String> addSubscription(
    String userId,
    Subscription subscription,
  ) async {
    final now = DateTime.now();
    final data = subscription.copyWith(
      createdAt: now,
      updatedAt: now,
    ).toFirestore();

    final docRef = await _subscriptionsRef(userId).add(data);
    return docRef.id;
  }

  /// Updates an existing subscription.
  Future<void> updateSubscription(
    String userId,
    Subscription subscription,
  ) async {
    final data = subscription.copyWith(
      updatedAt: DateTime.now(),
    ).toFirestore();

    await _subscriptionsRef(userId).doc(subscription.id).update(data);
  }

  /// Updates specific fields of a subscription without replacing the whole document.
  /// Useful for updating flags like trial warning states.
  Future<void> updateSubscriptionFields(
    String userId,
    String subscriptionId,
    Map<String, dynamic> fields,
  ) async {
    fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _subscriptionsRef(userId).doc(subscriptionId).update(fields);
  }

  /// Deletes a subscription by ID.
  Future<void> deleteSubscription(
    String userId,
    String subscriptionId,
  ) async {
    await _subscriptionsRef(userId).doc(subscriptionId).delete();
  }

  /// Gets a single subscription by ID.
  Future<Subscription?> getSubscription(
    String userId,
    String subscriptionId,
  ) async {
    final doc = await _subscriptionsRef(userId).doc(subscriptionId).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return Subscription.fromFirestore(doc);
  }

  // ==================== HISTORY METHODS ====================

  /// Watches all history records for a user in real-time.
  Stream<List<SubscriptionHistory>> watchHistory(String userId) {
    return _historyRef(userId)
        .orderBy('paidDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionHistory.fromFirestore(doc))
          .toList();
    });
  }

  /// Fetches all history records for a user once.
  Future<List<SubscriptionHistory>> getHistory(String userId) async {
    final snapshot = await _historyRef(userId)
        .orderBy('paidDate', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => SubscriptionHistory.fromFirestore(doc))
        .toList();
  }

  /// Adds a payment record to history.
  Future<String> addHistoryRecord(
    String userId,
    SubscriptionHistory record,
  ) async {
    final data = record.toFirestore();
    final docRef = await _historyRef(userId).add(data);
    return docRef.id;
  }

  /// Deletes a history record.
  Future<void> deleteHistoryRecord(
    String userId,
    String recordId,
  ) async {
    await _historyRef(userId).doc(recordId).delete();
  }

  /// Gets history for a specific subscription.
  Stream<List<SubscriptionHistory>> watchSubscriptionHistory(
    String userId,
    String subscriptionId,
  ) {
    return _historyRef(userId)
        .where('subscriptionId', isEqualTo: subscriptionId)
        .orderBy('paidDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionHistory.fromFirestore(doc))
          .toList();
    });
  }
}
