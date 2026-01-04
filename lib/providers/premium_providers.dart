import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/calendar_sync_service.dart';
import 'auth_provider.dart';

// ============================================================
// User Profile Providers
// ============================================================

/// Provider for the UserProfileService singleton.
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider that streams the current user's profile.
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(userProfileServiceProvider);

  if (userId == null) {
    return Stream.value(null);
  }

  return service.watchUserProfile(userId);
});

/// Provider for the current user's profile (non-stream).
final userProfileProvider = Provider<UserProfile?>((ref) {
  final profileAsync = ref.watch(userProfileStreamProvider);
  return profileAsync.valueOrNull;
});

/// Trial duration in days
const int trialDurationDays = 7;

/// Provider to check if user is in trial period
final isInTrialProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final firstLaunchStr = prefs.getString('first_launch_date');
  
  if (firstLaunchStr == null) {
    // First time launch - start trial
    await prefs.setString('first_launch_date', DateTime.now().toIso8601String());
    return true;
  }
  
  final firstLaunch = DateTime.parse(firstLaunchStr);
  final daysSinceFirstLaunch = DateTime.now().difference(firstLaunch).inDays;
  return daysSinceFirstLaunch < trialDurationDays;
});

/// Provider for remaining trial days
final trialDaysRemainingProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final firstLaunchStr = prefs.getString('first_launch_date');
  
  if (firstLaunchStr == null) {
    return trialDurationDays;
  }
  
  final firstLaunch = DateTime.parse(firstLaunchStr);
  final daysSinceFirstLaunch = DateTime.now().difference(firstLaunch).inDays;
  final remaining = trialDurationDays - daysSinceFirstLaunch;
  return remaining > 0 ? remaining : 0;
});

/// Provider that checks if the current user has premium access.
/// Premium = paid premium OR in trial period
/// NOTE: Returns true for all users during testing - set testingMode to false for production
const bool testingMode = true; // Set to false for production

final isPremiumProvider = Provider<bool>((ref) {
  // Testing mode - all features free
  if (testingMode) return true;
  
  // Check if user has paid premium
  final profile = ref.watch(userProfileProvider);
  if (profile?.isPremium ?? false) return true;
  
  // Check if user is in trial (async check, default to false)
  final trialAsync = ref.watch(isInTrialProvider);
  return trialAsync.valueOrNull ?? false;
});

/// StateNotifier for the user's base currency - works with local storage
class BaseCurrencyNotifier extends StateNotifier<String> {
  BaseCurrencyNotifier() : super('USD') {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('base_currency') ?? 'USD';
    state = currency;
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_currency', currency);
    state = currency;
  }
}

/// StateNotifier for currency conversion enabled state
class CurrencyConversionEnabledNotifier extends StateNotifier<bool> {
  CurrencyConversionEnabledNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false - user must explicitly enable currency conversion
    final enabled = prefs.getBool('currency_conversion_enabled') ?? false;
    state = enabled;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('currency_conversion_enabled', enabled);
    state = enabled;
  }
}

/// Provider for whether currency conversion is enabled
final currencyConversionEnabledNotifierProvider = 
    StateNotifierProvider<CurrencyConversionEnabledNotifier, bool>((ref) {
  return CurrencyConversionEnabledNotifier();
});

/// Provider for currency conversion enabled state (convenience)
final currencyConversionEnabledProvider = Provider<bool>((ref) {
  return ref.watch(currencyConversionEnabledNotifierProvider);
});

/// Provider for the user's base currency - uses local storage for immediate updates
final baseCurrencyNotifierProvider = StateNotifierProvider<BaseCurrencyNotifier, String>((ref) {
  return BaseCurrencyNotifier();
});

/// Provider for the user's base currency (backward compatible).
final baseCurrencyProvider = Provider<String>((ref) {
  // First try from local notifier (immediate updates)
  return ref.watch(baseCurrencyNotifierProvider);
});

/// Provider for premium days remaining.
final premiumDaysRemainingProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.premiumDaysRemaining ?? 0;
});

/// Provider for whether user has lifetime premium.
final isLifetimePremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.isLifetimePremium ?? false;
});

// ============================================================
// Exchange Rate Providers
// ============================================================

/// Provider for the ExchangeRateService singleton.
final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) {
  return ExchangeRateService();
});

/// Provider for converting a specific amount to the user's base currency.
/// Usage: ref.watch(convertedAmountProvider((amount: 100, from: 'EUR')))
final convertedAmountProvider =
    FutureProvider.family<double?, ({double amount, String from})>((ref, params) async {
  final isPremium = ref.watch(isPremiumProvider);
  if (!isPremium) return null;

  final baseCurrency = ref.watch(baseCurrencyProvider);
  final service = ref.watch(exchangeRateServiceProvider);

  return service.convertAmount(params.amount, params.from, baseCurrency);
});

/// Provider for getting exchange rate between two currencies.
final exchangeRateProvider =
    FutureProvider.family<double?, ({String from, String to})>((ref, params) async {
  final service = ref.watch(exchangeRateServiceProvider);
  return service.getRate(params.from, params.to);
});

// ============================================================
// Calendar Sync Providers
// ============================================================

/// Provider for the GoogleCalendarSyncService.
final calendarSyncServiceProvider = Provider<GoogleCalendarSyncService>((ref) {
  return CalendarSyncServiceFactory.create();
});

/// Provider for available calendars.
final availableCalendarsProvider = FutureProvider<List<CalendarInfo>>((ref) async {
  final service = ref.watch(calendarSyncServiceProvider);
  return service.getCalendars();
});

/// Provider for calendar sync enabled status.
final calendarSyncEnabledProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.calendarSyncEnabled ?? false;
});

// ============================================================
// Referral Providers
// ============================================================

/// Provider for the user's referral code.
final referralCodeProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.referralCode;
});

/// Provider for total referrals count.
final totalReferralsProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.totalReferrals ?? 0;
});

/// Provider for referral stats.
final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(userProfileServiceProvider);

  if (userId == null) {
    return ReferralStats(referralCode: '', totalReferrals: 0, daysEarned: 0);
  }

  return service.getReferralStats(userId);
});

// ============================================================
// Premium Feature Controllers
// ============================================================

/// Controller for premium-related actions.
class PremiumController {
  final UserProfileService _profileService;
  final String _userId;

  PremiumController({
    required UserProfileService profileService,
    required String userId,
  })  : _profileService = profileService,
        _userId = userId;

  /// Updates the user's base currency.
  Future<void> setBaseCurrency(String currency) async {
    await _profileService.updateBaseCurrency(_userId, currency);
  }

  /// Updates the user's theme mode.
  Future<void> setThemeMode(String mode) async {
    await _profileService.updateThemeMode(_userId, mode);
  }

  /// Updates calendar sync settings.
  Future<void> setCalendarSync({
    required bool enabled,
    String? calendarId,
  }) async {
    await _profileService.updateCalendarSync(
      _userId,
      enabled: enabled,
      calendarId: calendarId,
    );
  }

  /// Persists the mapping of subscriptionId -> calendar eventId.
  Future<void> setCalendarEventIds(Map<String, String> eventIds) async {
    await _profileService.updateCalendarEventIds(
      _userId,
      eventIds: eventIds,
    );
  }

  /// Applies a referral code.
  Future<ReferralResult> applyReferralCode(String code) async {
    return _profileService.applyReferralCode(
      userId: _userId,
      referralCode: code,
    );
  }

  /// Grants lifetime premium (call after successful purchase).
  Future<void> grantLifetimePremium() async {
    await _profileService.grantLifetimePremium(_userId);
  }
}

/// Provider for the PremiumController.
final premiumControllerProvider = Provider<PremiumController?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final service = ref.watch(userProfileServiceProvider);

  if (userId == null) return null;

  return PremiumController(
    profileService: service,
    userId: userId,
  );
});
