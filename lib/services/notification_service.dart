import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/subscription.dart';
import 'package:intl/intl.dart';

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

  bool _isInitialized = false;

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
      return granted ?? false;
    }

    return true;
  }

  /// Generates a unique notification ID from subscription ID.
  /// 
  /// Uses hashCode to create a stable integer ID.
  /// Adds an offset for the "3 days before" notification.
  int _generateNotificationId(String subscriptionId, {bool isReminder = false}) {
    final baseId = subscriptionId.hashCode.abs() % 100000;
    return isReminder ? baseId : baseId + 100000;
  }

  /// Schedules notifications for a subscription.
  /// 
  /// Creates two notifications:
  /// 1. Three days before the payment date
  /// 2. On the payment date
  /// On web, this is a no-op.
  Future<void> scheduleSubscriptionNotifications(Subscription subscription) async {
    // Skip on web - local notifications not supported
    if (kIsWeb) return;
    
    if (!_isInitialized) {
      await initialize();
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

    // Schedule notification 3 days before payment
    final reminderDate = paymentDate.subtract(const Duration(days: 3));
    if (reminderDate.isAfter(now)) {
      final scheduledReminder = tz.TZDateTime.from(
        DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          9, // Schedule for 9 AM
          0,
        ),
        tz.local,
      );

      await _notifications.zonedSchedule(
        _generateNotificationId(subscription.id, isReminder: true),
        'Upcoming subscription payment',
        '${subscription.name} payment of ${subscription.price.toStringAsFixed(0)} ${subscription.currency} is due on $formattedDate',
        scheduledReminder,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: subscription.id,
      );
    }

    // Schedule notification on payment day
    if (paymentDate.isAfter(now) || _isSameDay(paymentDate, now)) {
      // Only schedule if payment date is today or in the future
      DateTime notificationTime;
      
      if (_isSameDay(paymentDate, now)) {
        // If payment is today, schedule for 1 minute from now (or skip if past 9 AM)
        notificationTime = now.add(const Duration(minutes: 1));
      } else {
        notificationTime = DateTime(
          paymentDate.year,
          paymentDate.month,
          paymentDate.day,
          9, // Schedule for 9 AM
          0,
        );
      }

      if (notificationTime.isAfter(now)) {
        final scheduledPayment = tz.TZDateTime.from(notificationTime, tz.local);

        await _notifications.zonedSchedule(
          _generateNotificationId(subscription.id, isReminder: false),
          'Subscription payment due today',
          '${subscription.name} payment of ${subscription.price.toStringAsFixed(0)} ${subscription.currency} is due today!',
          scheduledPayment,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: subscription.id,
        );
      }
    }
  }

  /// Checks if two dates are the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Cancels all notifications for a subscription.
  /// On web, this is a no-op.
  Future<void> cancelSubscriptionNotifications(Subscription subscription) async {
    if (kIsWeb) return;
    
    await _notifications.cancel(
      _generateNotificationId(subscription.id, isReminder: true),
    );
    await _notifications.cancel(
      _generateNotificationId(subscription.id, isReminder: false),
    );
  }

  /// Cancels a notification by its ID.
  /// On web, this is a no-op.
  Future<void> cancelNotificationById(String subscriptionId) async {
    if (kIsWeb) return;
    
    await _notifications.cancel(
      _generateNotificationId(subscriptionId, isReminder: true),
    );
    await _notifications.cancel(
      _generateNotificationId(subscriptionId, isReminder: false),
    );
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
