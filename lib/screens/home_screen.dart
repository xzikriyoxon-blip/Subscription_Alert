import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_history.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_providers.dart';
import '../providers/premium_providers.dart';
import '../services/exchange_rate_service.dart';
import '../widgets/subscription_list_item.dart';
import '../widgets/subscription_detail_dialog.dart';
import '../widgets/banner_ad_widget.dart';
import 'add_edit_subscription_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'watch_search_screen.dart';
import 'music_search_screen.dart';
import 'deals_screen.dart';
import 'referral_screen.dart';
import 'spend_health_screen.dart';
import 'timeline_screen.dart';
import 'wishlist_screen.dart';
import 'usage_analytics_screen.dart';
import 'report_screen.dart';

/// Home screen displaying the user's subscriptions.
///
/// Shows total monthly cost, list of subscriptions, and provides
/// options to add, edit, or delete subscriptions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);
    final authService = ref.watch(authServiceProvider);
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        centerTitle: true,
        actions: [
          // Premium badge if user has premium
          if (isPremium)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.white),
                  SizedBox(width: 2),
                  Text('PRO',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(context, ref, strings, isPremium, authService),
      body: subscriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                strings.errorLoadingSubscriptions,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(subscriptionsStreamProvider),
                child: Text(strings.retry),
              ),
            ],
          ),
        ),
        data: (subscriptions) => _buildContent(
          context,
          ref,
          subscriptions,
        ),
      ),
      // Show banner ad for non-premium users
      bottomNavigationBar: isPremium ? null : const BannerAdWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSubscription(context),
        tooltip: strings.addSubscription,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Subscription> subscriptions,
  ) {
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noSubscriptionsYet,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.tapToAddFirst,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Filter active (non-cancelled) subscriptions
    final activeSubscriptions =
        subscriptions.where((s) => !s.isCancelled).toList();

    // Group subscriptions by currency and calculate totals
    final Map<String, double> monthlyByCurrency = {};
    final Map<String, double> yearlyByCurrency = {};

    for (final sub in activeSubscriptions) {
      // Add all subscription prices as monthly total (regardless of cycle)
      monthlyByCurrency[sub.currency] =
          (monthlyByCurrency[sub.currency] ?? 0) + sub.price;

      // Yearly is monthly total * 12
      yearlyByCurrency[sub.currency] =
          (yearlyByCurrency[sub.currency] ?? 0) + (sub.price * 12);
    }

    final numberFormat = NumberFormat('#,##0.00', 'en_US');

    return Column(
      children: [
        // Total cost card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? [Colors.amber[600]!, Colors.orange[400]!]
                  : [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isPremium ? Colors.amber : Colors.blue)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    strings.totalMonthlyCost,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  if (isPremium) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        baseCurrency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // For premium users with conversion enabled, show converted total
              if (isPremium && ref.watch(currencyConversionEnabledProvider))
                _PremiumTotalDisplay(
                  monthlyByCurrency: monthlyByCurrency,
                  yearlyByCurrency: yearlyByCurrency,
                  baseCurrency: baseCurrency,
                  numberFormat: numberFormat,
                )
              else ...[
                // Show monthly costs by currency (non-premium or conversion disabled)
                if (monthlyByCurrency.isNotEmpty)
                  ...monthlyByCurrency.entries.map((e) => Text(
                        '${numberFormat.format(e.value)} ${e.key}/mo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                // Show yearly costs by currency
                if (yearlyByCurrency.isNotEmpty) ...[
                  if (monthlyByCurrency.isNotEmpty) const SizedBox(height: 4),
                  ...yearlyByCurrency.entries.map((e) => Text(
                        '${numberFormat.format(e.value)} ${e.key}/yr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
                if (monthlyByCurrency.isEmpty && yearlyByCurrency.isEmpty)
                  const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              const SizedBox(height: 4),
              Text(
                strings.activeSubscriptions(activeSubscriptions.length),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              // Premium upsell for non-premium users with multiple currencies
              if (!isPremium &&
                  (monthlyByCurrency.length > 1 ||
                      yearlyByCurrency.length > 1)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.upgradeToPremiumConversion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Subscriptions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = subscriptions[index];
              return _SubscriptionListItemWithConversion(
                subscription: subscription,
                isPremium: isPremium,
                baseCurrency: baseCurrency,
                onTap: () =>
                    _showSubscriptionDetail(context, ref, subscription),
                onDelete: () => _showDeleteDialog(context, ref, subscription),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToAddSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditSubscriptionScreen(),
      ),
    );
  }

  void _showSubscriptionDetail(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    showSubscriptionDetailDialog(
      context,
      subscription: subscription,
      onEdit: () => _navigateToEditSubscription(context, subscription),
      onDelete: () => _showDeleteDialog(context, ref, subscription),
      onMarkCancelled: () =>
          _markSubscriptionCancelled(context, ref, subscription),
      onReactivate: () => _reactivateSubscription(context, ref, subscription),
      onMarkPaid: () => _markSubscriptionPaid(context, ref, subscription),
    );
  }

  void _navigateToEditSubscription(
    BuildContext context,
    Subscription subscription,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditSubscriptionScreen(
          subscription: subscription,
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    final strings = ref.read(stringsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteSubscription),
        content: Text(strings.deleteConfirmation(subscription.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteSubscription(context, ref, subscription);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubscription(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final controller = ref.read(subscriptionControllerProvider);

    if (controller == null) return;

    try {
      await controller.deleteSubscription(subscription);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subscription.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Re-add the subscription
                controller.addSubscription(subscription);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markSubscriptionCancelled(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final controller = ref.read(subscriptionControllerProvider);

    if (controller == null) return;

    try {
      final updatedSubscription = subscription.copyWith(
        isCancelled: true,
        cancelledAt: DateTime.now(),
      );
      await controller.updateSubscription(updatedSubscription);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subscription.name} marked as cancelled'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _reactivateSubscription(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final controller = ref.read(subscriptionControllerProvider);
    final strings = ref.read(stringsProvider);

    if (controller == null) return;

    try {
      final updatedSubscription = subscription.copyWith(
        isCancelled: false,
        clearCancelledAt: true,
      );
      await controller.updateSubscription(updatedSubscription);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${subscription.name} ${strings.active.toLowerCase()}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markSubscriptionPaid(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final userId = ref.read(currentUserIdProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final controller = ref.read(subscriptionControllerProvider);
    final strings = ref.read(stringsProvider);

    if (userId == null || controller == null) return;

    try {
      // Create history record
      final historyRecord = SubscriptionHistory(
        id: '',
        subscriptionId: subscription.id,
        subscriptionName: subscription.name,
        amount: subscription.price,
        currency: subscription.currency,
        paidDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Add to history
      await firestoreService.addHistoryRecord(userId, historyRecord);

      // Update next payment date
      DateTime nextDate;
      if (subscription.cycle == 'monthly') {
        nextDate = DateTime(
          subscription.nextPaymentDate.year,
          subscription.nextPaymentDate.month + 1,
          subscription.nextPaymentDate.day,
        );
      } else {
        nextDate = DateTime(
          subscription.nextPaymentDate.year + 1,
          subscription.nextPaymentDate.month,
          subscription.nextPaymentDate.day,
        );
      }

      final updatedSubscription = subscription.copyWith(
        nextPaymentDate: nextDate,
      );
      await controller.updateSubscription(updatedSubscription);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.paymentRecorded),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSignOutDialog(
      BuildContext context, WidgetRef ref, dynamic authService) {
    final strings = ref.watch(stringsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.signOut),
        content: Text(strings.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authService.signOut();
            },
            child: Text(strings.signOut),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic strings,
      bool isPremium, dynamic authService) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [Colors.amber[600]!, Colors.orange[400]!]
                    : [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.subscriptions, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  strings.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPremium)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // FREE FEATURES
          _buildDrawerSectionHeader(strings.freeFeatures),

          // Payment History - FREE
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(strings.history),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),

          const Divider(),

          // PREMIUM FEATURES
          _buildDrawerSectionHeader(strings.premiumFeatures),

          // Where to Watch - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.live_tv,
            title: strings.whereToWatch,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WatchSearchScreen()));
            },
          ),

          // Music Search - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.music_note,
            title: strings.musicSearch,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MusicSearchScreen()));
            },
          ),

          // Deals - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.local_offer,
            title: strings.deals,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DealsScreen()));
            },
          ),

          // Spend Health - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.health_and_safety,
            title: strings.spendHealth,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SpendHealthScreen()));
            },
          ),

          // Timeline - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.timeline,
            title: strings.timeline,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TimelineScreen()));
            },
          ),

          // Wishlist - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.favorite,
            title: strings.wishlist,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()));
            },
          ),

          // Usage Analytics - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.analytics,
            title: strings.usageAnalytics,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UsageAnalyticsScreen()));
            },
          ),

          // Reports - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.description,
            title: strings.reports,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReportScreen()));
            },
          ),

          // Referral/Invite - PREMIUM
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.card_giftcard,
            title: strings.inviteFriends,
            isPremium: isPremium,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReferralScreen()));
            },
          ),

          const Divider(),

          // Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(strings.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(strings.signOut,
                style: const TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showSignOutDialog(context, ref, authService);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPremiumDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Text(title),
          if (!isPremium) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap, // All features accessible (testing mode / trial)
    );
  }
}

/// Widget that displays total cost converted to base currency for premium users.
class _PremiumTotalDisplay extends ConsumerWidget {
  final Map<String, double> monthlyByCurrency;
  final Map<String, double> yearlyByCurrency;
  final String baseCurrency;
  final NumberFormat numberFormat;

  const _PremiumTotalDisplay({
    required this.monthlyByCurrency,
    required this.yearlyByCurrency,
    required this.baseCurrency,
    required this.numberFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exchangeService = ref.watch(exchangeRateServiceProvider);

    return FutureBuilder<Map<String, double>>(
      future: _calculateTotals(exchangeService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 30,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        final totals = snapshot.data ?? {'monthly': 0.0, 'yearly': 0.0};
        final monthlyTotal = totals['monthly'] ?? 0.0;
        final yearlyTotal = totals['yearly'] ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (monthlyTotal > 0)
              Text(
                '${numberFormat.format(monthlyTotal)} $baseCurrency/mo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (yearlyTotal > 0)
              Text(
                '${numberFormat.format(yearlyTotal)} $baseCurrency/yr',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (monthlyTotal == 0 && yearlyTotal == 0)
              const Text(
                '0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<Map<String, double>> _calculateTotals(
      ExchangeRateService service) async {
    double monthlyTotal = 0;
    double yearlyTotal = 0;

    // Convert monthly totals (these are already monthly equivalents)
    for (final entry in monthlyByCurrency.entries) {
      if (entry.key == baseCurrency) {
        monthlyTotal += entry.value;
      } else {
        final converted =
            await service.convertAmount(entry.value, entry.key, baseCurrency);
        monthlyTotal += converted ?? 0;
      }
    }

    // Convert yearly totals (these are already yearly projections)
    for (final entry in yearlyByCurrency.entries) {
      if (entry.key == baseCurrency) {
        yearlyTotal += entry.value;
      } else {
        final converted =
            await service.convertAmount(entry.value, entry.key, baseCurrency);
        yearlyTotal += converted ?? 0;
      }
    }

    return {'monthly': monthlyTotal, 'yearly': yearlyTotal};
  }
}

/// Subscription list item that shows converted price for premium users.
class _SubscriptionListItemWithConversion extends ConsumerWidget {
  final Subscription subscription;
  final bool isPremium;
  final String baseCurrency;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SubscriptionListItemWithConversion({
    required this.subscription,
    required this.isPremium,
    required this.baseCurrency,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If premium and currency differs, show conversion
    final showConversion = isPremium && subscription.currency != baseCurrency;

    if (!showConversion) {
      return SubscriptionListItem(
        subscription: subscription,
        onTap: onTap,
        onDelete: onDelete,
      );
    }

    // Premium user with different currency - show converted amount
    final convertedAsync = ref.watch(
      convertedAmountProvider(
          (amount: subscription.price, from: subscription.currency)),
    );

    return SubscriptionListItem(
      subscription: subscription,
      onTap: onTap,
      onDelete: onDelete,
      convertedAmount: convertedAsync.valueOrNull,
      convertedCurrency: baseCurrency,
    );
  }
}
