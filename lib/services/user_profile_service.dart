import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Service for managing user profiles in Firestore.
///
/// Handles user profile CRUD operations, premium status management,
/// and referral system logic.
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Reference to users collection.
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Reference to referral codes index for quick lookup.
  CollectionReference<Map<String, dynamic>> get _referralCodesRef =>
      _firestore.collection('referral_codes');

  /// Gets a user profile by ID.
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Watches a user profile in real-time.
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Creates or updates a user profile.
  /// If the profile doesn't exist, creates it with a new referral code.
  Future<UserProfile> createOrUpdateProfile({
    required String userId,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final existingProfile = await getUserProfile(userId);

    if (existingProfile != null) {
      // Update existing profile
      final updated = existingProfile.copyWith(
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );
      await _usersRef.doc(userId).update(updated.toFirestore());
      return updated;
    }

    // Create new profile with unique referral code
    final referralCode = await _generateUniqueReferralCode();
    final now = DateTime.now();

    final newProfile = UserProfile(
      id: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      referralCode: referralCode,
      createdAt: now,
      updatedAt: now,
    );

    // Save profile
    await _usersRef.doc(userId).set(newProfile.toFirestore());

    // Index the referral code for quick lookup
    await _referralCodesRef.doc(referralCode).set({
      'userId': userId,
      'createdAt': Timestamp.fromDate(now),
    });

    return newProfile;
  }

  /// Updates user's base currency.
  Future<void> updateBaseCurrency(String userId, String currency) async {
    await _usersRef.doc(userId).set({
      'baseCurrency': currency,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Updates user's theme mode.
  Future<void> updateThemeMode(String userId, String themeMode) async {
    await _usersRef.doc(userId).set({
      'themeMode': themeMode,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Updates calendar sync settings.
  Future<void> updateCalendarSync(
    String userId, {
    required bool enabled,
    String? calendarId,
  }) async {
    await _usersRef.doc(userId).set({
      'calendarSyncEnabled': enabled,
      'calendarId': calendarId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Updates the mapping of subscriptionId -> Google Calendar eventId.
  ///
  /// Stored in the user profile so we can update/delete events reliably and
  /// avoid creating duplicates on each sync.
  Future<void> updateCalendarEventIds(
    String userId, {
    required Map<String, String> eventIds,
  }) async {
    await _usersRef.doc(userId).set({
      'calendarEventIds': eventIds,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Grants lifetime premium to a user (after purchase).
  Future<void> grantLifetimePremium(String userId) async {
    await _usersRef.doc(userId).update({
      'isLifetimePremium': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Extends premium by a number of days (for referral rewards).
  Future<void> extendPremium(String userId, int days) async {
    final profile = await getUserProfile(userId);
    if (profile == null) return;

    // If already lifetime premium, no need to extend
    if (profile.isLifetimePremium) return;

    DateTime newPremiumUntil;
    if (profile.premiumUntil != null &&
        profile.premiumUntil!.isAfter(DateTime.now())) {
      // Extend from current expiry
      newPremiumUntil = profile.premiumUntil!.add(Duration(days: days));
    } else {
      // Start from now
      newPremiumUntil = DateTime.now().add(Duration(days: days));
    }

    await _usersRef.doc(userId).update({
      'premiumUntil': Timestamp.fromDate(newPremiumUntil),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Generates a unique referral code.
  Future<String> _generateUniqueReferralCode() async {
    const maxAttempts = 10;
    for (var i = 0; i < maxAttempts; i++) {
      final code = UserProfile.generateReferralCode();
      final existing = await _referralCodesRef.doc(code).get();
      if (!existing.exists) {
        return code;
      }
    }
    // Fallback: add timestamp to ensure uniqueness
    return '${UserProfile.generateReferralCode()}${DateTime.now().millisecondsSinceEpoch % 1000}';
  }

  /// Looks up a user by referral code.
  Future<String?> getUserIdByReferralCode(String referralCode) async {
    final doc = await _referralCodesRef.doc(referralCode.toUpperCase()).get();
    if (!doc.exists) return null;
    return doc.data()?['userId'] as String?;
  }

  /// Applies a referral code for a new user.
  /// Returns a result indicating success/failure and message.
  Future<ReferralResult> applyReferralCode({
    required String userId,
    required String referralCode,
  }) async {
    final code = referralCode.toUpperCase().trim();

    // Validate code format
    if (code.length < 6) {
      return ReferralResult(
        success: false,
        message: 'Invalid referral code format',
      );
    }

    // Get the user applying the code
    final userProfile = await getUserProfile(userId);
    if (userProfile == null) {
      return ReferralResult(
        success: false,
        message: 'User profile not found',
      );
    }

    // Check if user already used a referral code
    if (userProfile.referredBy != null) {
      return ReferralResult(
        success: false,
        message: 'You have already used a referral code',
      );
    }

    // Look up the inviter
    final inviterUserId = await getUserIdByReferralCode(code);
    if (inviterUserId == null) {
      return ReferralResult(
        success: false,
        message: 'Referral code not found',
      );
    }

    // Prevent self-referral
    if (inviterUserId == userId) {
      return ReferralResult(
        success: false,
        message: 'You cannot use your own referral code',
      );
    }

    // Get inviter profile
    final inviterProfile = await getUserProfile(inviterUserId);
    if (inviterProfile == null) {
      return ReferralResult(
        success: false,
        message: 'Inviter not found',
      );
    }

    // Apply rewards using a batch write for atomicity
    final batch = _firestore.batch();

    // Update new user: set referredBy and extend premium by 7 days
    final userRef = _usersRef.doc(userId);
    final userPremiumUntil = _calculateNewPremiumDate(userProfile, 7);
    batch.update(userRef, {
      'referredBy': inviterUserId,
      'premiumUntil': Timestamp.fromDate(userPremiumUntil),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Update inviter: increment totalReferrals and extend premium by 7 days
    final inviterRef = _usersRef.doc(inviterUserId);
    final inviterPremiumUntil = _calculateNewPremiumDate(inviterProfile, 7);
    batch.update(inviterRef, {
      'totalReferrals': FieldValue.increment(1),
      'premiumUntil': Timestamp.fromDate(inviterPremiumUntil),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();

    return ReferralResult(
      success: true,
      message: 'Referral code applied! You and your friend both received 7 days of Premium.',
      daysAwarded: 7,
    );
  }

  /// Calculates new premium expiry date when extending by days.
  DateTime _calculateNewPremiumDate(UserProfile profile, int days) {
    if (profile.isLifetimePremium) {
      // Lifetime premium users don't need extension, but we still track it
      return DateTime.now().add(Duration(days: days));
    }

    if (profile.premiumUntil != null &&
        profile.premiumUntil!.isAfter(DateTime.now())) {
      return profile.premiumUntil!.add(Duration(days: days));
    }

    return DateTime.now().add(Duration(days: days));
  }

  /// Gets statistics for a user's referrals.
  Future<ReferralStats> getReferralStats(String userId) async {
    final profile = await getUserProfile(userId);
    if (profile == null) {
      return ReferralStats(
        referralCode: '',
        totalReferrals: 0,
        daysEarned: 0,
      );
    }

    return ReferralStats(
      referralCode: profile.referralCode,
      totalReferrals: profile.totalReferrals,
      daysEarned: profile.totalReferrals * 7,
    );
  }
}

/// Result of applying a referral code.
class ReferralResult {
  final bool success;
  final String message;
  final int? daysAwarded;

  ReferralResult({
    required this.success,
    required this.message,
    this.daysAwarded,
  });
}

/// Statistics about a user's referrals.
class ReferralStats {
  final String referralCode;
  final int totalReferrals;
  final int daysEarned;

  ReferralStats({
    required this.referralCode,
    required this.totalReferrals,
    required this.daysEarned,
  });
}
