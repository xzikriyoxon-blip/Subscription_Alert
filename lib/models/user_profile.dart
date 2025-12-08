import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model containing premium status, referral info, and preferences.
///
/// Stored in Firestore at: users/{userId}
class UserProfile {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  // Premium fields
  final bool isLifetimePremium;
  final DateTime? premiumUntil;

  // Referral fields
  final String referralCode;
  final String? referredBy;
  final int totalReferrals;

  // Preferences
  final String baseCurrency;
  final String themeMode; // 'system', 'light', 'dark'
  final bool calendarSyncEnabled;
  final String? calendarId; // ID of synced calendar

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isLifetimePremium = false,
    this.premiumUntil,
    required this.referralCode,
    this.referredBy,
    this.totalReferrals = 0,
    this.baseCurrency = 'USD',
    this.themeMode = 'system',
    this.calendarSyncEnabled = false,
    this.calendarId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user currently has premium access (lifetime or temporary).
  /// NOTE: Returns true for all users during testing.
  bool get isPremium {
    // TODO: Remove this after testing - makes all features free
    return true;
    
    // Original logic:
    // if (isLifetimePremium) return true;
    // if (premiumUntil == null) return false;
    // return premiumUntil!.isAfter(DateTime.now());
  }

  /// Get remaining premium days (for temporary premium).
  int get premiumDaysRemaining {
    if (isLifetimePremium) return -1; // -1 indicates lifetime
    if (premiumUntil == null) return 0;
    final remaining = premiumUntil!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Creates a UserProfile from a Firestore document snapshot.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      id: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isLifetimePremium: data['isLifetimePremium'] as bool? ?? false,
      premiumUntil: (data['premiumUntil'] as Timestamp?)?.toDate(),
      referralCode: data['referralCode'] as String? ?? _generateReferralCode(),
      referredBy: data['referredBy'] as String?,
      totalReferrals: data['totalReferrals'] as int? ?? 0,
      baseCurrency: data['baseCurrency'] as String? ?? 'USD',
      themeMode: data['themeMode'] as String? ?? 'system',
      calendarSyncEnabled: data['calendarSyncEnabled'] as bool? ?? false,
      calendarId: data['calendarId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the UserProfile to a Map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isLifetimePremium': isLifetimePremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'totalReferrals': totalReferrals,
      'baseCurrency': baseCurrency,
      'themeMode': themeMode,
      'calendarSyncEnabled': calendarSyncEnabled,
      'calendarId': calendarId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy with updated fields.
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isLifetimePremium,
    DateTime? premiumUntil,
    bool clearPremiumUntil = false,
    String? referralCode,
    String? referredBy,
    int? totalReferrals,
    String? baseCurrency,
    String? themeMode,
    bool? calendarSyncEnabled,
    String? calendarId,
    bool clearCalendarId = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isLifetimePremium: isLifetimePremium ?? this.isLifetimePremium,
      premiumUntil:
          clearPremiumUntil ? null : (premiumUntil ?? this.premiumUntil),
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      themeMode: themeMode ?? this.themeMode,
      calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
      calendarId: clearCalendarId ? null : (calendarId ?? this.calendarId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Generates a random 8-character referral code.
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
            8, (index) => chars[(random + index * 7) % chars.length])
        .join();
  }

  /// Creates a new referral code.
  static String generateReferralCode() => _generateReferralCode();

  @override
  String toString() {
    return 'UserProfile(id: $id, email: $email, isPremium: $isPremium, '
        'referralCode: $referralCode, baseCurrency: $baseCurrency)';
  }
}
