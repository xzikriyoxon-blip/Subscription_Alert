import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a wishlist (named list of subscription ideas).
/// 
/// Stored in Firestore at: users/{userId}/wishlists/{listId}
class WishList {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount; // Cached count for display

  const WishList({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory WishList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishList(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed List',
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      itemCount: data['itemCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'itemCount': itemCount,
    };
  }

  WishList copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
  }) {
    return WishList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

/// Model for a wishlist item.
/// 
/// Stored in Firestore at: users/{userId}/wishlists/{listId}/items/{itemId}
class WishListItem {
  final String id;
  final String serviceName;
  final String? brandId;       // Reference to SubscriptionBrand if exists
  final String? note;
  final String? estimatedPrice;
  final String? currency;
  final String? category;
  final String? imageUrl;
  final DateTime createdAt;

  const WishListItem({
    required this.id,
    required this.serviceName,
    this.brandId,
    this.note,
    this.estimatedPrice,
    this.currency,
    this.category,
    this.imageUrl,
    required this.createdAt,
  });

  factory WishListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishListItem(
      id: doc.id,
      serviceName: data['serviceName'] as String? ?? '',
      brandId: data['brandId'] as String?,
      note: data['note'] as String?,
      estimatedPrice: data['estimatedPrice'] as String?,
      currency: data['currency'] as String?,
      category: data['category'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'brandId': brandId,
      'note': note,
      'estimatedPrice': estimatedPrice,
      'currency': currency,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WishListItem copyWith({
    String? id,
    String? serviceName,
    String? brandId,
    String? note,
    String? estimatedPrice,
    String? currency,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return WishListItem(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      brandId: brandId ?? this.brandId,
      note: note ?? this.note,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Limits for free vs premium users
class WishListLimits {
  static const int freeMaxLists = 1;
  static const int freeMaxItemsPerList = 5;
  static const int premiumMaxLists = -1;  // Unlimited (-1)
  static const int premiumMaxItemsPerList = -1; // Unlimited (-1)

  static int maxLists(bool isPremium) => isPremium ? premiumMaxLists : freeMaxLists;
  static int maxItems(bool isPremium) => isPremium ? premiumMaxItemsPerList : freeMaxItemsPerList;
  
  static bool canCreateList(int currentCount, bool isPremium) {
    final max = maxLists(isPremium);
    return max == -1 || currentCount < max;
  }

  static bool canAddItem(int currentCount, bool isPremium) {
    final max = maxItems(isPremium);
    return max == -1 || currentCount < max;
  }
}
