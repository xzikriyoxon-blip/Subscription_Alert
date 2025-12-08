import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/subscription.dart';

/// Service for managing Android home screen widget data.
///
/// Uses the home_widget package to communicate between Flutter and native Android.
/// The widget displays upcoming subscription renewals and monthly spending totals.
class WidgetService {
  static const String _androidWidgetName = 'SubscriptionWidgetProvider';
  static const String _qualifiedAndroidName = 'com.example.subscription_alert.SubscriptionWidgetProvider';
  
  /// Initialize the widget service.
  Future<void> initialize() async {
    // Set up the app group for widget communication
    await HomeWidget.setAppGroupId('group.subscription_alert_widget');
    
    // Register callback for widget interactions (if needed)
    HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
  }

  /// Updates the widget with the latest subscription data.
  ///
  /// Call this whenever subscriptions change.
  Future<void> updateWidget({
    required List<Subscription> subscriptions,
    required String baseCurrency,
    double? totalMonthlyInBaseCurrency,
    bool isPremium = false,
  }) async {
    try {
      // Get active (non-cancelled) subscriptions
      final activeSubscriptions = subscriptions.where((s) => !s.isCancelled).toList();

      // Sort by next payment date
      activeSubscriptions.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

      // Calculate monthly total
      double monthlyTotal = 0;
      if (totalMonthlyInBaseCurrency != null) {
        monthlyTotal = totalMonthlyInBaseCurrency;
      } else {
        for (final sub in activeSubscriptions) {
          monthlyTotal += sub.monthlyEquivalent;
        }
      }

      // Get next renewal info
      String nextRenewalName = 'No subscriptions';
      String nextRenewalDate = '';
      
      if (activeSubscriptions.isNotEmpty) {
        final next = activeSubscriptions.first;
        nextRenewalName = next.name;
        final daysUntil = next.nextPaymentDate.difference(DateTime.now()).inDays;
        if (daysUntil == 0) {
          nextRenewalDate = 'Today';
        } else if (daysUntil == 1) {
          nextRenewalDate = 'Tomorrow';
        } else {
          nextRenewalDate = 'in $daysUntil days';
        }
      }

      // Format monthly total
      final currencySymbol = _getCurrencySymbol(baseCurrency);
      final monthlyTotalFormatted = '$currencySymbol${monthlyTotal.toStringAsFixed(2)}';

      // Save data for the widget using home_widget
      await HomeWidget.saveWidgetData<String>('nextRenewalName', nextRenewalName);
      await HomeWidget.saveWidgetData<String>('nextRenewalDate', nextRenewalDate);
      await HomeWidget.saveWidgetData<String>('monthlyTotal', monthlyTotalFormatted);
      await HomeWidget.saveWidgetData<int>('subscriptionsCount', activeSubscriptions.length);

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        qualifiedAndroidName: _qualifiedAndroidName,
      );

      debugPrint('WidgetService: Widget updated successfully');
      debugPrint('  Next: $nextRenewalName ($nextRenewalDate)');
      debugPrint('  Monthly: $monthlyTotalFormatted');
      debugPrint('  Count: ${activeSubscriptions.length}');
    } catch (e) {
      debugPrint('WidgetService: Error updating widget: $e');
    }
  }

  /// Clears widget data (e.g., on logout).
  Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String>('nextRenewalName', 'No subscriptions');
      await HomeWidget.saveWidgetData<String>('nextRenewalDate', '');
      await HomeWidget.saveWidgetData<String>('monthlyTotal', '\$0.00');
      await HomeWidget.saveWidgetData<int>('subscriptionsCount', 0);

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        qualifiedAndroidName: _qualifiedAndroidName,
      );
      
      debugPrint('WidgetService: Widget data cleared');
    } catch (e) {
      debugPrint('WidgetService: Error clearing widget data: $e');
    }
  }

  /// Gets currency symbol for display.
  String _getCurrencySymbol(String currencyCode) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'KRW': '₩',
      'INR': '₹',
      'RUB': '₽',
      'BRL': 'R\$',
      'CAD': 'CA\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'SAR': 'SR',
      'AED': 'AED',
      'EGP': 'E£',
    };
    return symbols[currencyCode] ?? currencyCode;
  }
}

/// Background callback for widget interactions.
/// Called when user taps on the widget.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  debugPrint('WidgetService: Widget background callback triggered: $uri');
  // Handle widget tap - could launch the app to a specific screen
}
