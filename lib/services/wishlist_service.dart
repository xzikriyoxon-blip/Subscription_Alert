import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist.dart';

/// Service for managing wishlists in Firestore.
/// 
/// Handles CRUD operations for wishlists and their items.
/// Path: users/{userId}/wishlists/{listId}/items/{itemId}
class WishListService {
  final FirebaseFirestore _firestore;

  WishListService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get reference to user's wishlists collection
  CollectionReference<Map<String, dynamic>> _wishlistsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('wishlists');
  }

  /// Get reference to items collection within a wishlist
  CollectionReference<Map<String, dynamic>> _itemsRef(String userId, String listId) {
    return _wishlistsRef(userId).doc(listId).collection('items');
  }

  // ==================== WISHLIST OPERATIONS ====================

  /// Watch all wishlists for a user
  Stream<List<WishList>> watchWishlists(String userId) {
    return _wishlistsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => WishList.fromFirestore(doc)).toList();
        });
  }

  /// Get all wishlists for a user
  Future<List<WishList>> getWishlists(String userId) async {
    final snapshot = await _wishlistsRef(userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => WishList.fromFirestore(doc)).toList();
  }

  /// Get a single wishlist
  Future<WishList?> getWishlist(String userId, String listId) async {
    final doc = await _wishlistsRef(userId).doc(listId).get();
    if (!doc.exists) return null;
    return WishList.fromFirestore(doc);
  }

  /// Create a new wishlist
  Future<WishList> createWishlist({
    required String userId,
    required String name,
    String? description,
    required bool isPremium,
  }) async {
    // Check limits for free users
    if (!isPremium) {
      final existing = await getWishlists(userId);
      if (!WishListLimits.canCreateList(existing.length, isPremium)) {
        throw WishListLimitException(
          'Free users can only have ${WishListLimits.freeMaxLists} wishlist. Upgrade to Premium for unlimited lists.',
        );
      }
    }

    final now = DateTime.now();
    final docRef = _wishlistsRef(userId).doc();
    
    final wishlist = WishList(
      id: docRef.id,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      itemCount: 0,
    );

    await docRef.set(wishlist.toFirestore());
    return wishlist;
  }

  /// Update a wishlist
  Future<void> updateWishlist({
    required String userId,
    required String listId,
    String? name,
    String? description,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
    
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;

    await _wishlistsRef(userId).doc(listId).update(updates);
  }

  /// Delete a wishlist and all its items
  Future<void> deleteWishlist(String userId, String listId) async {
    // First delete all items in the wishlist
    final itemsSnapshot = await _itemsRef(userId, listId).get();
    final batch = _firestore.batch();
    
    for (final doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    // Then delete the wishlist itself
    batch.delete(_wishlistsRef(userId).doc(listId));
    
    await batch.commit();
  }

  // ==================== ITEM OPERATIONS ====================

  /// Watch items in a wishlist
  Stream<List<WishListItem>> watchItems(String userId, String listId) {
    return _itemsRef(userId, listId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => WishListItem.fromFirestore(doc)).toList();
        });
  }

  /// Get all items in a wishlist
  Future<List<WishListItem>> getItems(String userId, String listId) async {
    final snapshot = await _itemsRef(userId, listId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => WishListItem.fromFirestore(doc)).toList();
  }

  /// Add item to wishlist
  Future<WishListItem> addItem({
    required String userId,
    required String listId,
    required String serviceName,
    String? brandId,
    String? note,
    String? estimatedPrice,
    String? currency,
    String? category,
    String? imageUrl,
    required bool isPremium,
  }) async {
    // Check item limits for free users
    if (!isPremium) {
      final existingItems = await getItems(userId, listId);
      if (!WishListLimits.canAddItem(existingItems.length, isPremium)) {
        throw WishListLimitException(
          'Free users can only have ${WishListLimits.freeMaxItemsPerList} items per list. Upgrade to Premium for unlimited items.',
        );
      }
    }

    final docRef = _itemsRef(userId, listId).doc();
    
    final item = WishListItem(
      id: docRef.id,
      serviceName: serviceName,
      brandId: brandId,
      note: note,
      estimatedPrice: estimatedPrice,
      currency: currency,
      category: category,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    // Use batch to update item and increment count
    final batch = _firestore.batch();
    batch.set(docRef, item.toFirestore());
    batch.update(_wishlistsRef(userId).doc(listId), {
      'itemCount': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    await batch.commit();

    return item;
  }

  /// Update an item
  Future<void> updateItem({
    required String userId,
    required String listId,
    required String itemId,
    String? serviceName,
    String? note,
    String? estimatedPrice,
    String? currency,
  }) async {
    final updates = <String, dynamic>{};
    
    if (serviceName != null) updates['serviceName'] = serviceName;
    if (note != null) updates['note'] = note;
    if (estimatedPrice != null) updates['estimatedPrice'] = estimatedPrice;
    if (currency != null) updates['currency'] = currency;

    if (updates.isNotEmpty) {
      await _itemsRef(userId, listId).doc(itemId).update(updates);
      
      // Update wishlist timestamp
      await _wishlistsRef(userId).doc(listId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  /// Delete an item
  Future<void> deleteItem({
    required String userId,
    required String listId,
    required String itemId,
  }) async {
    final batch = _firestore.batch();
    
    batch.delete(_itemsRef(userId, listId).doc(itemId));
    batch.update(_wishlistsRef(userId).doc(listId), {
      'itemCount': FieldValue.increment(-1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    
    await batch.commit();
  }

  /// Move item to another wishlist
  Future<void> moveItem({
    required String userId,
    required String fromListId,
    required String toListId,
    required String itemId,
    required bool isPremium,
  }) async {
    // Get the item
    final itemDoc = await _itemsRef(userId, fromListId).doc(itemId).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final item = WishListItem.fromFirestore(itemDoc);

    // Check limits on destination list
    if (!isPremium) {
      final destItems = await getItems(userId, toListId);
      if (!WishListLimits.canAddItem(destItems.length, isPremium)) {
        throw WishListLimitException(
          'Destination list has reached maximum items for free users.',
        );
      }
    }

    // Move item in a batch
    final batch = _firestore.batch();
    
    // Delete from source
    batch.delete(_itemsRef(userId, fromListId).doc(itemId));
    batch.update(_wishlistsRef(userId).doc(fromListId), {
      'itemCount': FieldValue.increment(-1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    
    // Add to destination
    final newDocRef = _itemsRef(userId, toListId).doc();
    batch.set(newDocRef, item.toFirestore());
    batch.update(_wishlistsRef(userId).doc(toListId), {
      'itemCount': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    
    await batch.commit();
  }

  /// Check if service is already in any wishlist
  Future<bool> isInWishlist({
    required String userId,
    required String serviceName,
  }) async {
    final wishlists = await getWishlists(userId);
    
    for (final list in wishlists) {
      final items = await getItems(userId, list.id);
      if (items.any((item) => 
          item.serviceName.toLowerCase() == serviceName.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
}

/// Exception for wishlist limit violations
class WishListLimitException implements Exception {
  final String message;
  WishListLimitException(this.message);
  
  @override
  String toString() => message;
}
