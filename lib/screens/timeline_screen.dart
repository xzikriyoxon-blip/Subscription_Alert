import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/timeline_entry.dart';
import '../providers/feature_providers.dart';
import '../providers/premium_providers.dart';
import 'settings_screen.dart';

/// Screen displaying subscription payment timeline.
/// Shows past and future payments in a visual timeline format.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final timeline = ref.watch(subscriptionTimelineProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final summary = ref.watch(timelineSummaryProvider);
    
    // Flatten all entries from all months
    final allEntries = timeline.allMonths.expand((m) => m.entries).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.timeline),
        centerTitle: true,
      ),
      body: allEntries.isEmpty
          ? _buildEmptyState(context, ref)
          : CustomScrollView(
              slivers: [
                // Summary cards
                SliverToBoxAdapter(
                  child: _buildSummarySection(context, ref, summary),
                ),

                // Premium banner if not premium
                if (!isPremium)
                  SliverToBoxAdapter(
                    child: _buildPremiumBanner(context, ref),
                  ),

                // Timeline header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      strings.paymentTimeline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                // Timeline entries
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = allEntries[index];
                      final isFirst = index == 0;
                      final isLast = index == allEntries.length - 1;
                      return _TimelineEntryItem(
                        entry: entry,
                        isFirst: isFirst,
                        isLast: isLast,
                      );
                    },
                    childCount: allEntries.length,
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            strings.noTimelineData,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.addSubscriptionsToSeeTimeline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, WidgetRef ref, Map<String, dynamic> summary) {
    final strings = ref.watch(stringsProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    final totalPast = summary['totalPast'] as double? ?? 0.0;
    final totalUpcoming = summary['totalUpcoming'] as double? ?? 0.0;
    final nextPaymentDays = summary['nextPaymentDays'] as int?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Past spending card
          Expanded(
            child: _SummaryCard(
              icon: Icons.history,
              iconColor: Colors.blue,
              title: strings.pastSpending,
              value: '$baseCurrency ${totalPast.toStringAsFixed(2)}',
              subtitle: strings.lastMonths(3),
            ),
          ),
          const SizedBox(width: 12),
          // Upcoming spending card
          Expanded(
            child: _SummaryCard(
              icon: Icons.upcoming,
              iconColor: Colors.orange,
              title: strings.upcomingSpending,
              value: '$baseCurrency ${totalUpcoming.toStringAsFixed(2)}',
              subtitle: nextPaymentDays != null
                  ? strings.nextPaymentIn(nextPaymentDays)
                  : strings.noUpcomingPayments,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.unlockFullTimeline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  strings.timelinePremiumDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to premium upgrade
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade700,
            ),
            child: Text(strings.upgrade),
          ),
        ],
      ),
    );
  }
}

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Timeline entry item widget
class _TimelineEntryItem extends ConsumerWidget {
  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  const _TimelineEntryItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat.MMMd();
    final isToday = entry.type == EntryType.today;
    final isPast = entry.type == EntryType.past;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPast ? Colors.grey[300] : Colors.blue[200],
                    ),
                  ),
                // Dot
                Container(
                  width: isToday ? 20 : 14,
                  height: isToday ? 20 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getDotColor(entry.type),
                    border: isToday
                        ? Border.all(color: Colors.green.shade300, width: 3)
                        : null,
                  ),
                  child: isToday
                      ? const Icon(Icons.today, size: 12, color: Colors.white)
                      : null,
                ),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPast ? Colors.grey[300] : Colors.blue[200],
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              elevation: isToday ? 4 : 1,
              color: isToday ? Colors.green[50] : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Date
                    SizedBox(
                      width: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(entry.date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isToday ? Colors.green[700] : null,
                            ),
                          ),
                          if (isToday)
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Subscription info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isPast ? Colors.grey[600] : null,
                            ),
                          ),
                          if (entry.planName != null)
                            Text(
                              entry.planName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      '${entry.currency} ${entry.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPast
                            ? Colors.grey[500]
                            : isToday
                                ? Colors.green[700]
                                : Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDotColor(EntryType type) {
    switch (type) {
      case EntryType.past:
        return Colors.grey;
      case EntryType.today:
        return Colors.green;
      case EntryType.future:
        return Colors.blue;
    }
  }
}
