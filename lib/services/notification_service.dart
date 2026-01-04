import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/subscription.dart';
import 'package:intl/intl.dart';
import 'notification_preferences_store.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io' show Platform;

/// Service class for managing local notifications.
/// 
/// Handles scheduling, cancelling, and displaying notifications
/// for subscription payment reminders.
/// Note: Local notifications are not supported on web platform.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final NotificationPreferencesStore _prefsStore = NotificationPreferencesStore();

  bool _isInitialized = false;
  bool _exactAlarmsPermitted = true; // Assume true until proven otherwise

  /// Channel ID for Android notifications
  static const String _channelId = 'subscription_reminders';
  static const String _channelName = 'Subscription Reminders';
  static const String _channelDescription = 
      'Notifications for upcoming subscription payments';

  /// Initializes the notification service.
  /// 
  /// Must be called before scheduling any notifications.
  /// On web, this is a no-op since local notifications aren't supported.
  Future<void> initialize() async {
    // Skip initialization on web - local notifications not supported
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }
    
    if (_isInitialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Creates the Android notification channel.
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handles notification tap events.
  void _onNotificationTap(NotificationResponse response) {
    // Can be extended to navigate to specific subscription
    // The payload contains the subscription ID
  }

  /// Requests notification permissions from the user.
  /// On web, returns true since we skip notifications.
  Future<bool> requestPermissions() async {
    // Skip on web
    if (kIsWeb) return true;
    
    // Request permissions on iOS
    final iOS = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // Request permissions on Android 13+
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();

      // Android 12+: exact alarms require special permission on many devices.
      // flutter_local_notifications exposes an API for this on newer versions.
      // Use a dynamic call so compilation stays compatible if the method isn't
      // present on some platforms.
      try {
        final dynamic androidDynamic = android;
        final exactAlarmGranted = await androidDynamic.requestExactAlarmsPermission();
        _exactAlarmsPermitted = exactAlarmGranted ?? true;
      } catch (_) {
        // Ignore if not supported or denied.
        _exactAlarmsPermitted = true; // Assume permitted on older devices
      }

      return granted ?? false;
    }

    return true;
  }

  /// Checks if exact alarms are permitted on Android 12+.
  Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;
    
    final android = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      try {
        final dynamic androidDynamic = android;
        final canSchedule = await androidDynamic.canScheduleExactNotifications();
        _exactAlarmsPermitted = canSchedule ?? true;
        return _exactAlarmsPermitted;
      } catch (_) {
        return true; // Assume permitted on older devices
      }
    }
    return true;
  }

  /// Opens system settings for exact alarm permission.
  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    
    try {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    } catch (_) {
      // Fallback to app settings if specific intent not available
      try {
        const fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.xzikriyoxon.subscriptionalert',
        );
        await fallbackIntent.launch();
      } catch (_) {
        // Ignore if unable to open settings
      }
    }
  }

  /// Whether exact alarms are currently permitted.
  bool get exactAlarmsPermitted => _exactAlarmsPermitted;

  /// Generates a unique notification ID for a given subscription and
  /// reminder offset (days before).
  ///
  /// Uses blocks of 100k per "daysBefore" value to avoid collisions.
  /// Example: baseId 12345
  /// - daysBefore 0 => 112345
  /// - daysBefore 1 => 212345
  /// - daysBefore 3 => 412345
  int _generateNotificationIdForDaysBefore(String subscriptionId, int daysBefore) {
    final baseId = subscriptionId.hashCode.abs() % 100000;
    final safeDays = daysBefore < 0 ? 0 : daysBefore;
    return baseId + ((safeDays + 1) * 100000);
  }

  // Legacy IDs from older versions of the app (2-notification scheme).
  // Keep these so we can cancel them when users upgrade.
  int _legacyIdThreeDaysBefore(String subscriptionId) {
    final baseId = subscriptionId.hashCode.abs() % 100000;
    return baseId;
  }

  int _legacyIdDueDay(String subscriptionId) {
    final baseId = subscriptionId.hashCode.abs() % 100000;
    return baseId + 100000;
  }

  DateTime _scheduleDateForDay({
    required DateTime day,
    required DateTime now,
    required int hour,
    required int minute,
  }) {
    // Standard: user-configured local time.
    final scheduled = DateTime(day.year, day.month, day.day, hour, minute);
    if (scheduled.isAfter(now)) return scheduled;

    // If the target day is today but 9 AM has already passed, schedule soon so
    // the user still gets a reminder.
    if (_isSameDay(day, now)) {
      return now.add(const Duration(minutes: 1));
    }

    // If the target day is in the past, return a past date to signal "skip".
    return scheduled;
  }

  String _titleForDaysBefore(int daysBefore) {
    if (daysBefore <= 0) return 'Subscription payment due today';
    if (daysBefore == 1) return 'Subscription payment tomorrow';
    return 'Upcoming subscription payment';
  }

  /// Schedules notifications for a subscription.
  /// 
  /// Creates three notifications:
  /// 1. Three days before the payment date
  /// 2. One day before the payment date
  /// 3. On the payment date
  /// On web, this is a no-op.
  Future<void> scheduleSubscriptionNotifications(Subscription subscription) async {
    // Skip on web - local notifications not supported
    if (kIsWeb) return;
    
    if (!_isInitialized) {
      await initialize();
    }

    final preferences = await _prefsStore.load();
    if (!preferences.enabled) {
      // Still cancel any existing schedules if user disabled notifications.
      await cancelSubscriptionNotifications(subscription);
      return;
    }

    // Cancel any existing notifications for this subscription
    await cancelSubscriptionNotifications(subscription);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormat.format(subscription.nextPaymentDate);

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    final paymentDate = subscription.nextPaymentDate;

    final scheduledDays = <int>[];

    for (final daysBefore in preferences.daysBefore) {
      final targetDay = paymentDate.subtract(Duration(days: daysBefore));

      if (!(targetDay.isAfter(now) || _isSameDay(targetDay, now))) {
        continue;
      }

      final notificationTime = _scheduleDateForDay(
        day: targetDay,
        now: now,
        hour: preferences.hour,
        minute: preferences.minute,
      );

      if (!notificationTime.isAfter(now)) {
        continue;
      }

      final scheduled = tz.TZDateTime.from(notificationTime, tz.local);
      final id = _generateNotificationIdForDaysBefore(subscription.id, daysBefore);

      // Check if exact alarms are permitted, use inexact as fallback
      final canUseExact = await canScheduleExactAlarms();
      final scheduleMode = canUseExact 
          ? AndroidScheduleMode.exactAllowWhileIdle 
          : AndroidScheduleMode.inexactAllowWhileIdle;

      try {
        await _notifications.zonedSchedule(
          id,
          _titleForDaysBefore(daysBefore),
          daysBefore <= 0
              ? '${subscription.name} payment of ${subscription.price.toStringAsFixed(2)} ${subscription.currency} is due today!'
              : '${subscription.name} payment of ${subscription.price.toStringAsFixed(2)} ${subscription.currency} is due on $formattedDate',
          scheduled,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: subscription.id,
        );
        scheduledDays.add(daysBefore);
      } catch (e) {
        // If exact alarms fail, try with inexact alarms
        if (scheduleMode == AndroidScheduleMode.exactAllowWhileIdle) {
          _exactAlarmsPermitted = false;
          try {
            await _notifications.zonedSchedule(
              id,
              _titleForDaysBefore(daysBefore),
              daysBefore <= 0
                  ? '${subscription.name} payment of ${subscription.price.toStringAsFixed(2)} ${subscription.currency} is due today!'
                  : '${subscription.name} payment of ${subscription.price.toStringAsFixed(2)} ${subscription.currency} is due on $formattedDate',
              scheduled,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: subscription.id,
            );
            scheduledDays.add(daysBefore);
          } catch (_) {
            // Notification scheduling failed completely
          }
        }
      }
    }

    await _prefsStore.saveLastScheduledDays(subscription.id, scheduledDays);
  }

  /// Checks if two dates are the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Cancels all notifications for a subscription.
  /// On web, this is a no-op.
  Future<void> cancelSubscriptionNotifications(Subscription subscription) async {
    if (kIsWeb) return;

    // Cancel legacy schedules
    await _notifications.cancel(_legacyIdThreeDaysBefore(subscription.id));
    await _notifications.cancel(_legacyIdDueDay(subscription.id));

    // Cancel whatever we last scheduled for this subscription.
    final lastDays = await _prefsStore.loadLastScheduledDays(subscription.id);
    final fallback = (await _prefsStore.load()).daysBefore;
    final daysToCancel = lastDays.isNotEmpty ? lastDays : fallback;

    for (final daysBefore in daysToCancel) {
      await _notifications.cancel(
        _generateNotificationIdForDaysBefore(subscription.id, daysBefore),
      );
    }

    await _prefsStore.clearLastScheduledDays(subscription.id);
  }

  /// Cancels a notification by its ID.
  /// On web, this is a no-op.
  Future<void> cancelNotificationById(String subscriptionId) async {
    if (kIsWeb) return;

    await _notifications.cancel(_legacyIdThreeDaysBefore(subscriptionId));
    await _notifications.cancel(_legacyIdDueDay(subscriptionId));

    final lastDays = await _prefsStore.loadLastScheduledDays(subscriptionId);
    final fallback = (await _prefsStore.load()).daysBefore;
    final daysToCancel = lastDays.isNotEmpty ? lastDays : fallback;

    for (final daysBefore in daysToCancel) {
      await _notifications.cancel(
        _generateNotificationIdForDaysBefore(subscriptionId, daysBefore),
      );
    }

    await _prefsStore.clearLastScheduledDays(subscriptionId);
  }

  /// Cancels all scheduled notifications.
  /// On web, this is a no-op.
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    
    await _notifications.cancelAll();
  }

  /// Shows an immediate notification with custom title and body.
  /// On web, this is a no-op.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Shows an immediate test notification.
  /// On web, this is a no-op.
  Future<void> showTestNotification() async {
    if (kIsWeb) return;
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'Notifications are working correctly!',
      notificationDetails,
    );
  }

  /// Gets all pending notifications.
  /// On web, returns an empty list.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) return [];
    
    return await _notifications.pendingNotificationRequests();
  }
}
