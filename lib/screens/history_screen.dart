import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription_history.dart';
import '../providers/subscription_providers.dart';
import 'settings_screen.dart';

/// Screen to display subscription payment history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(subscriptionHistoryProvider);
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.history),
        centerTitle: true,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          final stats = HistoryStats.fromHistory(history);
          
          return CustomScrollView(
            slivers: [
              // Stats cards
              SliverToBoxAdapter(
                child: _buildStatsSection(context, ref, stats),
              ),
              
              // History list
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    strings.recentPayments,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = history[index];
                    return _HistoryListItem(record: record);
                  },
                  childCount: history.length,
                ),
              ),
              
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading history: $error'),
            ],
          ),
        ),
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
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            strings.noPaymentHistory,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.paymentHistoryWillAppear,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, WidgetRef ref, HistoryStats stats) {
    final strings = ref.watch(stringsProvider);
    final numberFormat = NumberFormat('#,##0.##', 'en_US');
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.overview,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: strings.thisMonth,
                  value: numberFormat.format(stats.thisMonthSpent),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: strings.thisYear,
                  value: numberFormat.format(stats.thisYearSpent),
                  icon: Icons.calendar_month,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: strings.totalSpent,
                  value: numberFormat.format(stats.totalSpent),
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: strings.payments,
                  value: stats.totalPayments.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final SubscriptionHistory record;

  const _HistoryListItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final numberFormat = NumberFormat('#,##0.##', 'en_US');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.check_circle,
            color: Colors.green[600],
          ),
        ),
        title: Text(
          record.subscriptionName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          dateFormat.format(record.paidDate),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${numberFormat.format(record.amount)} ${record.currency}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
