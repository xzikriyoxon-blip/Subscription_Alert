import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_preferences.dart';

class NotificationPreferencesStore {
  static final NotificationPreferencesStore _instance =
      NotificationPreferencesStore._internal();
  factory NotificationPreferencesStore() => _instance;
  NotificationPreferencesStore._internal();

  static const String _keyEnabled = 'notif_enabled';
  static const String _keyHour = 'notif_time_hour';
  static const String _keyMinute = 'notif_time_minute';
  static const String _keyDaysBefore = 'notif_days_before';

  String _scheduledDaysKey(String subscriptionId) =>
      'notif_scheduled_days_$subscriptionId';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool(_keyEnabled) ?? NotificationPreferences.defaults.enabled;
    final hour = prefs.getInt(_keyHour) ?? NotificationPreferences.defaults.hour;
    final minute = prefs.getInt(_keyMinute) ?? NotificationPreferences.defaults.minute;

    final daysStrings =
        prefs.getStringList(_keyDaysBefore) ?? const <String>[];

    final parsedDays = daysStrings
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();

    final daysBefore = parsedDays.isNotEmpty
        ? parsedDays
        : List<int>.from(NotificationPreferences.defaults.daysBefore);

    // normalize (unique, non-negative, sorted desc)
    final normalized = <int>{
      for (final d in daysBefore)
        if (d >= 0) d,
    }.toList()
      ..sort((a, b) => b.compareTo(a));

    return NotificationPreferences(
      enabled: enabled,
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
      daysBefore: normalized,
    );
  }

  Future<void> save(NotificationPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value.enabled);
    await prefs.setInt(_keyHour, value.hour.clamp(0, 23));
    await prefs.setInt(_keyMinute, value.minute.clamp(0, 59));
    await prefs.setStringList(
      _keyDaysBefore,
      value.daysBefore.map((e) => e.toString()).toList(growable: false),
    );
  }

  Future<List<int>> loadLastScheduledDays(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_scheduledDaysKey(subscriptionId)) ?? const <String>[];
    return raw.map((e) => int.tryParse(e)).whereType<int>().toList();
  }

  Future<void> saveLastScheduledDays(String subscriptionId, List<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _scheduledDaysKey(subscriptionId),
      days.map((e) => e.toString()).toList(growable: false),
    );
  }

  Future<void> clearLastScheduledDays(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledDaysKey(subscriptionId));
  }
}
