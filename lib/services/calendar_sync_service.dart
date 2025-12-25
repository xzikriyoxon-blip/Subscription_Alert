import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/subscription.dart';

/// Service for syncing subscriptions with Google Calendar.
///
/// Uses Google Calendar API to create recurring events for subscription renewals.
/// Requires Google Sign-In with calendar scope.
class GoogleCalendarSyncService {
  static const List<String> _scopes = [
    gcal.CalendarApi.calendarScope,
  ];

  GoogleSignIn? _googleSignIn;
  gcal.CalendarApi? _calendarApi;
  
  /// Initialize with existing GoogleSignIn instance or create new one.
  Future<void> initialize({GoogleSignIn? existingSignIn}) async {
    _googleSignIn = existingSignIn ?? GoogleSignIn(scopes: _scopes);
  }

  /// Check if user is signed in with calendar access.
  Future<bool> isAuthenticated() async {
    if (_googleSignIn == null) return false;
    final account = _googleSignIn!.currentUser;
    if (account == null) return false;
    
    // Check if we have calendar scope
    final hasScope = await _googleSignIn!.requestScopes(_scopes);
    return hasScope;
  }

  /// Request calendar permissions (will prompt user if needed).
  Future<bool> requestPermissions() async {
    try {
      if (_googleSignIn == null) {
        _googleSignIn = GoogleSignIn(scopes: _scopes);
      }

      // Check if already signed in
      var account = _googleSignIn!.currentUser;
      if (account == null) {
        // Try silent sign in first
        account = await _googleSignIn!.signInSilently();
      }
      
      if (account == null) {
        // Need to sign in interactively
        account = await _googleSignIn!.signIn();
      }

      if (account == null) {
        debugPrint('GoogleCalendarSync: User cancelled sign-in');
        return false;
      }

      // Request calendar scope
      final hasScope = await _googleSignIn!.requestScopes(_scopes);
      if (!hasScope) {
        debugPrint('GoogleCalendarSync: Calendar scope not granted');
        return false;
      }

      // Initialize the Calendar API
      await _initCalendarApi();
      return _calendarApi != null;
    } catch (e) {
      debugPrint('GoogleCalendarSync: Error requesting permissions: $e');
      return false;
    }
  }

  /// Initialize the Google Calendar API client.
  Future<void> _initCalendarApi() async {
    try {
      final httpClient = await _googleSignIn!.authenticatedClient();
      if (httpClient == null) {
        debugPrint('GoogleCalendarSync: Failed to get authenticated client');
        return;
      }
      _calendarApi = gcal.CalendarApi(httpClient);
      debugPrint('GoogleCalendarSync: Calendar API initialized');
    } catch (e) {
      debugPrint('GoogleCalendarSync: Error initializing Calendar API: $e');
    }
  }

  /// Get list of user's calendars.
  Future<List<CalendarInfo>> getCalendars() async {
    if (_calendarApi == null) {
      await _initCalendarApi();
    }
    
    if (_calendarApi == null) {
      return [CalendarInfo(id: 'primary', name: 'Primary Calendar')];
    }

    try {
      final calendarList = await _calendarApi!.calendarList.list();
      final calendars = <CalendarInfo>[];
      
      for (final item in calendarList.items ?? []) {
        if (item.id != null && item.accessRole != 'reader') {
          calendars.add(CalendarInfo(
            id: item.id!,
            name: item.summary ?? 'Unnamed Calendar',
            isReadOnly: item.accessRole == 'reader',
            color: _parseColor(item.backgroundColor),
            isPrimary: item.primary ?? false,
          ));
        }
      }
      
      // Sort with primary calendar first
      calendars.sort((a, b) {
        if (a.isPrimary) return -1;
        if (b.isPrimary) return 1;
        return a.name.compareTo(b.name);
      });
      
      return calendars.isEmpty 
          ? [CalendarInfo(id: 'primary', name: 'Primary Calendar', isPrimary: true)]
          : calendars;
    } catch (e) {
      debugPrint('GoogleCalendarSync: Error getting calendars: $e');
      return [CalendarInfo(id: 'primary', name: 'Primary Calendar', isPrimary: true)];
    }
  }

  /// Create or update a calendar event for a subscription.
  Future<String?> createOrUpdateEvent({
    required Subscription subscription,
    required String calendarId,
    String? existingEventId,
  }) async {
    if (_calendarApi == null) {
      await _initCalendarApi();
    }
    
    if (_calendarApi == null) {
      debugPrint('GoogleCalendarSync: Calendar API not available');
      return null;
    }

    try {
      final event = gcal.Event()
        ..summary = '${subscription.name} Renewal'
        ..description = _buildEventDescription(subscription)
        ..start = gcal.EventDateTime()
        ..end = gcal.EventDateTime();

      // Set as all-day event
      // For all-day events, Google Calendar expects the end date to be
      // *exclusive* (i.e., the next day). If start == end, the event may not
      // render in many calendar views.
      final startDate = DateTime(
        subscription.nextPaymentDate.year,
        subscription.nextPaymentDate.month,
        subscription.nextPaymentDate.day,
      );
      event.start!.date = startDate;
      event.end!.date = startDate.add(const Duration(days: 1));

      // Tag event so we can identify it later (optional but useful for debugging).
      event.extendedProperties = gcal.EventExtendedProperties()
        ..private = {
          'managedBy': 'SubscriptionAlert',
          'subscriptionId': subscription.id,
        };

      // Add recurrence based on subscription cycle
      event.recurrence = [_buildRecurrenceRule(subscription)];

      // Add reminder
      event.reminders = gcal.EventReminders()
        ..useDefault = false
        ..overrides = [
          gcal.EventReminder()
            ..method = 'popup'
            ..minutes = 1440, // 1 day before
        ];

      gcal.Event result;
      if (existingEventId != null) {
        // Update existing event
        result = await _calendarApi!.events.update(event, calendarId, existingEventId);
        debugPrint('GoogleCalendarSync: Updated event for ${subscription.name}');
      } else {
        // Create new event
        result = await _calendarApi!.events.insert(event, calendarId);
        debugPrint('GoogleCalendarSync: Created event for ${subscription.name}');
      }

      return result.id;
    } catch (e) {
      debugPrint('GoogleCalendarSync: Error creating/updating event: $e');
      return null;
    }
  }

  /// Delete a calendar event.
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    if (_calendarApi == null) {
      await _initCalendarApi();
    }
    
    if (_calendarApi == null) return false;

    try {
      await _calendarApi!.events.delete(calendarId, eventId);
      debugPrint('GoogleCalendarSync: Deleted event $eventId');
      return true;
    } catch (e) {
      debugPrint('GoogleCalendarSync: Error deleting event: $e');
      return false;
    }
  }

  /// Sync all subscriptions to the calendar.
  Future<SyncResult> syncAllSubscriptions({
    required List<Subscription> subscriptions,
    required String calendarId,
    required Map<String, String> existingEventIds,
  }) async {
    int created = 0;
    int updated = 0;
    int deleted = 0;
    int failed = 0;
    final errors = <String>[];
    final newEventIds = <String, String>{};

    // Create/update events for active subscriptions
    for (final sub in subscriptions.where((s) => !s.isCancelled)) {
      try {
        final existingEventId = existingEventIds[sub.id];
        final eventId = await createOrUpdateEvent(
          subscription: sub,
          calendarId: calendarId,
          existingEventId: existingEventId,
        );

        if (eventId != null) {
          newEventIds[sub.id] = eventId;
          if (existingEventId != null) {
            updated++;
          } else {
            created++;
          }
        } else {
          failed++;
          errors.add('Failed to sync ${sub.name}');
        }
      } catch (e) {
        failed++;
        errors.add('Error syncing ${sub.name}: $e');
      }
    }

    // Delete events for cancelled or removed subscriptions
    final activeSubIds = subscriptions.where((s) => !s.isCancelled).map((s) => s.id).toSet();
    for (final entry in existingEventIds.entries) {
      if (!activeSubIds.contains(entry.key)) {
        try {
          final success = await deleteEvent(calendarId: calendarId, eventId: entry.value);
          if (success) deleted++;
        } catch (e) {
          errors.add('Error deleting event: $e');
        }
      }
    }

    debugPrint('GoogleCalendarSync: Sync complete - Created: $created, Updated: $updated, Deleted: $deleted, Failed: $failed');
    
    return SyncResult(
      created: created,
      updated: updated,
      deleted: deleted,
      failed: failed,
      errors: errors,
      eventIds: newEventIds,
    );
  }

  /// Build recurrence rule based on subscription cycle.
  String _buildRecurrenceRule(Subscription subscription) {
    switch (subscription.cycle.toLowerCase()) {
      case 'weekly':
        return 'RRULE:FREQ=WEEKLY';
      case 'monthly':
        return 'RRULE:FREQ=MONTHLY';
      case 'quarterly':
        return 'RRULE:FREQ=MONTHLY;INTERVAL=3';
      case 'yearly':
      case 'annual':
        return 'RRULE:FREQ=YEARLY';
      default:
        return 'RRULE:FREQ=MONTHLY';
    }
  }

  /// Build event description with subscription details.
  String _buildEventDescription(Subscription subscription) {
    final buffer = StringBuffer();
    buffer.writeln('💳 Subscription Renewal Reminder');
    buffer.writeln();
    buffer.writeln('Service: ${subscription.name}');
    buffer.writeln('Amount: ${subscription.currency} ${subscription.price.toStringAsFixed(2)}');
    buffer.writeln('Billing: ${subscription.cycle}');
    buffer.writeln();
    buffer.writeln('📱 Managed by Subscription Alert');
    return buffer.toString();
  }

  /// Format date as YYYY-MM-DD for Google Calendar.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse color from hex string.
  int? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    try {
      return int.parse(hexColor.replaceFirst('#', ''), radix: 16) + 0xFF000000;
    } catch (_) {
      return null;
    }
  }

  /// Sign out and clear calendar access.
  Future<void> signOut() async {
    _calendarApi = null;
    // Don't sign out of Google completely, just clear calendar API
  }
}

/// Information about a calendar.
class CalendarInfo {
  final String id;
  final String name;
  final bool isReadOnly;
  final int? color;
  final bool isPrimary;

  CalendarInfo({
    required this.id,
    required this.name,
    this.isReadOnly = false,
    this.color,
    this.isPrimary = false,
  });
}

/// Result of a sync operation.
class SyncResult {
  final int created;
  final int updated;
  final int deleted;
  final int failed;
  final List<String> errors;
  final Map<String, String> eventIds;

  SyncResult({
    this.created = 0,
    this.updated = 0,
    this.deleted = 0,
    this.failed = 0,
    this.errors = const [],
    this.eventIds = const {},
  });

  bool get success => failed == 0;
  int get total => created + updated + deleted;
}

/// Factory to get the calendar service.
class CalendarSyncServiceFactory {
  static GoogleCalendarSyncService create() {
    return GoogleCalendarSyncService();
  }
}
