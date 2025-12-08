import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_usage.dart';

/// Service for manual usage logging.
/// 
/// Used for iOS devices (where system usage stats aren't available)
/// or as a fallback/supplement to automatic tracking.
class ManualUsageLogService {
  static const String _localStorageKey = 'manual_usage_logs';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final ManualUsageLogService _instance = ManualUsageLogService._internal();
  factory ManualUsageLogService() => _instance;
  ManualUsageLogService._internal();

  CollectionReference get _usageCollection => _firestore.collection('usage_logs');

  /// Add a manual usage log entry
  Future<ManualUsageLog> addLog({
    required String userId,
    required String subscriptionId,
    required String serviceName,
    required DateTime date,
    required Duration duration,
    String? notes,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final log = ManualUsageLog(
      id: id,
      subscriptionId: subscriptionId,
      serviceName: serviceName,
      date: date,
      duration: duration,
      notes: notes,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    try {
      await _usageCollection
          .doc(userId)
          .collection('logs')
          .doc(id)
          .set(log.toJson());
    } catch (e) {
      debugPrint('ManualUsageLogService: Error saving to Firestore: $e');
    }

    // Also save locally as backup
    await _saveLocally(log);

    return log;
  }

  /// Get all logs for a user within a date range
  Future<List<ManualUsageLog>> getLogs({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final snapshot = await _usageCollection
          .doc(userId)
          .collection('logs')
          .where('date', isGreaterThanOrEqualTo: from.toIso8601String())
          .where('date', isLessThanOrEqualTo: to.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ManualUsageLog.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('ManualUsageLogService: Error fetching logs: $e');
      // Fall back to local storage
      return _getLocalLogs(from: from, to: to);
    }
  }

  /// Get logs for a specific subscription
  Future<List<ManualUsageLog>> getLogsForSubscription({
    required String userId,
    required String subscriptionId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      var query = _usageCollection
          .doc(userId)
          .collection('logs')
          .where('subscriptionId', isEqualTo: subscriptionId);

      if (from != null) {
        query = query.where('date', isGreaterThanOrEqualTo: from.toIso8601String());
      }
      if (to != null) {
        query = query.where('date', isLessThanOrEqualTo: to.toIso8601String());
      }

      final snapshot = await query.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => ManualUsageLog.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('ManualUsageLogService: Error fetching subscription logs: $e');
      return [];
    }
  }

  /// Update a log entry
  Future<void> updateLog({
    required String userId,
    required String logId,
    Duration? duration,
    String? notes,
  }) async {
    final updates = <String, dynamic>{};
    if (duration != null) {
      updates['duration'] = duration.inMinutes;
    }
    if (notes != null) {
      updates['notes'] = notes;
    }

    if (updates.isNotEmpty) {
      try {
        await _usageCollection
            .doc(userId)
            .collection('logs')
            .doc(logId)
            .update(updates);
      } catch (e) {
        debugPrint('ManualUsageLogService: Error updating log: $e');
      }
    }
  }

  /// Delete a log entry
  Future<void> deleteLog({
    required String userId,
    required String logId,
  }) async {
    try {
      await _usageCollection
          .doc(userId)
          .collection('logs')
          .doc(logId)
          .delete();
    } catch (e) {
      debugPrint('ManualUsageLogService: Error deleting log: $e');
    }

    // Also remove from local storage
    await _deleteLocally(logId);
  }

  /// Calculate total usage from manual logs
  Future<Map<String, Duration>> calculateManualUsage({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final logs = await getLogs(userId: userId, from: from, to: to);
    final result = <String, Duration>{};

    for (final log in logs) {
      result[log.subscriptionId] = (result[log.subscriptionId] ?? Duration.zero) + log.duration;
    }

    return result;
  }

  /// Get usage summary for a subscription from manual logs
  Future<SubscriptionUsage?> getSubscriptionUsageFromLogs({
    required String userId,
    required String subscriptionId,
    required String serviceName,
    String? brandId,
    required DateTime from,
    required DateTime to,
  }) async {
    final logs = await getLogsForSubscription(
      userId: userId,
      subscriptionId: subscriptionId,
      from: from,
      to: to,
    );

    if (logs.isEmpty) return null;

    Duration totalUsage = Duration.zero;
    for (final log in logs) {
      totalUsage += log.duration;
    }

    final dayCount = to.difference(from).inDays.clamp(1, 365);
    final averageDaily = Duration(milliseconds: totalUsage.inMilliseconds ~/ dayCount);

    // Calculate daily breakdown
    final dailyMap = <DateTime, DailyUsage>{};
    for (final log in logs) {
      final dateKey = DateTime(log.date.year, log.date.month, log.date.day);
      if (dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = DailyUsage(
          date: dateKey,
          usage: dailyMap[dateKey]!.usage + log.duration,
          launches: dailyMap[dateKey]!.launches + 1,
        );
      } else {
        dailyMap[dateKey] = DailyUsage(
          date: dateKey,
          usage: log.duration,
          launches: 1,
        );
      }
    }

    return SubscriptionUsage(
      subscriptionId: subscriptionId,
      serviceName: serviceName,
      brandId: brandId,
      totalUsage: totalUsage,
      launchCount: logs.length,
      averageDailyUsage: averageDaily,
      trend: _calculateTrend(logs),
      periodStart: from,
      periodEnd: to,
      dailyBreakdown: dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  /// Calculate usage trend from logs
  UsageTrend _calculateTrend(List<ManualUsageLog> logs) {
    if (logs.length < 7) return UsageTrend.newService;

    // Compare first half to second half
    logs.sort((a, b) => a.date.compareTo(b.date));
    final midpoint = logs.length ~/ 2;
    
    Duration firstHalf = Duration.zero;
    Duration secondHalf = Duration.zero;
    
    for (int i = 0; i < logs.length; i++) {
      if (i < midpoint) {
        firstHalf += logs[i].duration;
      } else {
        secondHalf += logs[i].duration;
      }
    }

    final ratio = secondHalf.inMinutes / (firstHalf.inMinutes.clamp(1, double.maxFinite.toInt()));
    
    if (ratio > 1.2) return UsageTrend.increasing;
    if (ratio < 0.8) return UsageTrend.decreasing;
    return UsageTrend.stable;
  }

  // ============================================================
  // Local Storage Methods (Backup)
  // ============================================================

  Future<void> _saveLocally(ManualUsageLog log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_localStorageKey) ?? [];
      existing.add(jsonEncode(log.toJson()));
      await prefs.setStringList(_localStorageKey, existing);
    } catch (e) {
      debugPrint('ManualUsageLogService: Error saving locally: $e');
    }
  }

  Future<List<ManualUsageLog>> _getLocalLogs({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_localStorageKey) ?? [];
      
      var logs = stored.map((s) {
        try {
          return ManualUsageLog.fromJson(jsonDecode(s));
        } catch (e) {
          return null;
        }
      }).whereType<ManualUsageLog>().toList();

      if (from != null) {
        logs = logs.where((l) => !l.date.isBefore(from)).toList();
      }
      if (to != null) {
        logs = logs.where((l) => !l.date.isAfter(to)).toList();
      }

      return logs;
    } catch (e) {
      debugPrint('ManualUsageLogService: Error loading local logs: $e');
      return [];
    }
  }

  Future<void> _deleteLocally(String logId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_localStorageKey) ?? [];
      
      final updated = existing.where((s) {
        try {
          final log = ManualUsageLog.fromJson(jsonDecode(s));
          return log.id != logId;
        } catch (e) {
          return true;
        }
      }).toList();

      await prefs.setStringList(_localStorageKey, updated);
    } catch (e) {
      debugPrint('ManualUsageLogService: Error deleting locally: $e');
    }
  }

  /// Sync local logs to Firestore
  Future<void> syncLocalToFirestore(String userId) async {
    final localLogs = await _getLocalLogs();
    
    for (final log in localLogs) {
      try {
        await _usageCollection
            .doc(userId)
            .collection('logs')
            .doc(log.id)
            .set(log.toJson(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('ManualUsageLogService: Error syncing log ${log.id}: $e');
      }
    }
  }

  /// Quick log presets for common durations
  static const Map<String, Duration> quickLogPresets = {
    '15 min': Duration(minutes: 15),
    '30 min': Duration(minutes: 30),
    '1 hour': Duration(hours: 1),
    '2 hours': Duration(hours: 2),
    '3 hours': Duration(hours: 3),
    '4+ hours': Duration(hours: 4),
  };
}
