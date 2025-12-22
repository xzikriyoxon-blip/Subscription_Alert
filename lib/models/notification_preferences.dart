import 'package:flutter/foundation.dart';

@immutable
class NotificationPreferences {
  final bool enabled;
  final int hour;
  final int minute;

  /// Days before the next payment date when a reminder should fire.
  ///
  /// Examples:
  /// - 3 => 3 days before
  /// - 1 => 1 day before
  /// - 0 => on the payment date
  final List<int> daysBefore;

  const NotificationPreferences({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.daysBefore,
  });

  static const NotificationPreferences defaults = NotificationPreferences(
    enabled: true,
    hour: 9,
    minute: 0,
    daysBefore: [3, 1, 0],
  );

  NotificationPreferences copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    List<int>? daysBefore,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysBefore: daysBefore ?? this.daysBefore,
    );
  }
}
