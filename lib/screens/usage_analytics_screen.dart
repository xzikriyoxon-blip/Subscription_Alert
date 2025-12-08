import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/app_usage.dart';
import '../models/subscription.dart';
import '../providers/feature_providers.dart';
import '../providers/subscription_providers.dart';
import '../providers/premium_providers.dart';
import '../services/manual_usage_log_service.dart';
import 'settings_screen.dart';

/// Screen to display usage analytics for subscriptions.
/// Premium-only feature that tracks app usage on Android or manual logs on iOS.
class UsageAnalyticsScreen extends ConsumerStatefulWidget {
  const UsageAnalyticsScreen({super.key});

  @override
  ConsumerState<UsageAnalyticsScreen> createState() =>
      _UsageAnalyticsScreenState();
}

class _UsageAnalyticsScreenState extends ConsumerState<UsageAnalyticsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final isAndroid = ref.watch(usageTrackingSupported);
    final subscriptions = ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.usageAnalytics),
        centerTitle: true,
        actions: [
          if (!isAndroid)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: strings.manualTrackingTip,
              onPressed: () => _showManualTrackingInfo(context, strings),
            ),
        ],
      ),
      body: !isPremium
          ? _buildPremiumPrompt(context, strings)
          : isAndroid
              ? _buildAndroidContent(context, strings, subscriptions)
              : _buildIOSContent(context, strings, subscriptions),
      floatingActionButton: isPremium && !isAndroid
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showAddManualLogDialog(context, strings, subscriptions),
              icon: const Icon(Icons.add),
              label: Text(strings.addManualLog),
            )
          : null,
    );
  }

  Widget _buildPremiumPrompt(BuildContext context, dynamic strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              strings.premiumFeature,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              strings.unlockUsageTracking,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to premium screen
                Navigator.of(context).pushNamed('/premium');
              },
              icon: const Icon(Icons.star),
              label: Text(strings.getPremium),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidContent(
      BuildContext context, dynamic strings, List<Subscription> subscriptions) {
    final permissionAsync = ref.watch(usagePermissionProvider);
    final usageAsync = ref.watch(currentMonthUsageProvider);

    return permissionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (hasPermission) {
        if (!hasPermission) {
          return _buildPermissionPrompt(context, strings);
        }

        return usageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (usageMap) {
            if (usageMap.isEmpty) {
              return _buildNoData(context, strings);
            }
            return _buildUsageContent(
                context, strings, usageMap, subscriptions);
          },
        );
      },
    );
  }

  Widget _buildIOSContent(
      BuildContext context, dynamic strings, List<Subscription> subscriptions) {
    final usageAsync = ref.watch(currentMonthUsageProvider);
    final manualLogs = ref.watch(manualUsageProvider);

    return usageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (usageMap) {
        return CustomScrollView(
          slivers: [
            // iOS info banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.manualTrackingTip,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Usage summary
            if (usageMap.isNotEmpty)
              ..._buildUsageSliver(context, strings, usageMap, subscriptions),
            // Recent manual logs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  strings.recentLogs,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (manualLogs.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 48,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.noUsageData,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildManualLogCard(manualLogs[index], strings),
                  childCount: manualLogs.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildPermissionPrompt(BuildContext context, dynamic strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              strings.usagePermissionRequired,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              strings.usagePermissionDesc,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final service = ref.read(usageTrackerServiceProvider);
                await service.requestUsagePermission();
                // Refresh the permission check
                ref.invalidate(usagePermissionProvider);
              },
              icon: const Icon(Icons.settings),
              label: Text(strings.grantPermission),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoData(BuildContext context, dynamic strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            strings.noUsageData,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageContent(
    BuildContext context,
    dynamic strings,
    Map<String, SubscriptionUsage> usageMap,
    List<Subscription> subscriptions,
  ) {
    return CustomScrollView(
      slivers: _buildUsageSliver(context, strings, usageMap, subscriptions),
    );
  }

  List<Widget> _buildUsageSliver(
    BuildContext context,
    dynamic strings,
    Map<String, SubscriptionUsage> usageMap,
    List<Subscription> subscriptions,
  ) {
    // Calculate totals
    Duration totalUsage = Duration.zero;
    int totalLaunches = 0;
    for (final usage in usageMap.values) {
      totalUsage += usage.totalUsage;
      totalLaunches += usage.launchCount;
    }

    final dayCount = DateTime.now().day;
    final avgDaily =
        Duration(milliseconds: totalUsage.inMilliseconds ~/ dayCount);

    // Sort by usage
    final sortedUsage = usageMap.values.toList()
      ..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));

    final topUsed = sortedUsage.take(5).toList();
    final underused =
        sortedUsage.where((u) => u.totalUsage.inMinutes < 60).toList();

    return [
      // Month selector
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                DateFormat('MMMM yyyy')
                    .format(DateTime(_selectedYear, _selectedMonth)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: DateTime(_selectedYear, _selectedMonth).isBefore(
                  DateTime(DateTime.now().year, DateTime.now().month),
                )
                    ? () => _changeMonth(1)
                    : null,
              ),
            ],
          ),
        ),
      ),

      // Summary cards
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: strings.totalUsage,
                  value: _formatDuration(totalUsage),
                  icon: Icons.access_time,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: strings.averageDaily,
                  value: _formatDuration(avgDaily),
                  icon: Icons.today,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 8)),

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: strings.launches,
                  value: totalLaunches.toString(),
                  icon: Icons.touch_app,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: strings.underused,
                  value: underused.length.toString(),
                  icon: Icons.warning_amber,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),

      // Top used section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            strings.topUsed,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),

      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _UsageCard(
            usage: topUsed[index],
            subscription: subscriptions.firstWhere(
              (s) => s.id == topUsed[index].subscriptionId,
              orElse: () => Subscription(
                id: '',
                name: topUsed[index].serviceName,
                price: 0,
                currency: 'USD',
                cycle: 'monthly',
                nextPaymentDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ),
            strings: strings,
          ),
          childCount: topUsed.length,
        ),
      ),

      // Underused section
      if (underused.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  strings.underused,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    underused.length.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _UnderusedCard(
              usage: underused[index],
              subscription: subscriptions.firstWhere(
                (s) => s.id == underused[index].subscriptionId,
                orElse: () => Subscription(
                  id: '',
                  name: underused[index].serviceName,
                  price: 0,
                  currency: 'USD',
                  cycle: 'monthly',
                  nextPaymentDate: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
              strings: strings,
            ),
            childCount: underused.length,
          ),
        ),
      ],

      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ];
  }

  Widget _buildManualLogCard(ManualUsageLog log, dynamic strings) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.schedule,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(log.serviceName),
        subtitle: Text(
          '${DateFormat.yMMMd().format(log.date)} • ${_formatDuration(log.duration)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            ref.read(manualUsageProvider.notifier).deleteLog(log.id);
          },
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  void _showManualTrackingInfo(BuildContext context, dynamic strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.manualLog),
        content: Text(strings.manualTrackingTip),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.ok),
          ),
        ],
      ),
    );
  }

  void _showAddManualLogDialog(
    BuildContext context,
    dynamic strings,
    List<Subscription> subscriptions,
  ) {
    Subscription? selectedSubscription;
    Duration selectedDuration = const Duration(hours: 1);
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.addManualLog,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Subscription dropdown
              DropdownButtonFormField<Subscription>(
                decoration: InputDecoration(
                  labelText: strings.selectSubscription,
                  border: const OutlineInputBorder(),
                ),
                value: selectedSubscription,
                items: subscriptions
                    .where((s) => !s.isCancelled)
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (s) => setModalState(() => selectedSubscription = s),
              ),
              const SizedBox(height: 16),

              // Duration selector
              Text(strings.selectDuration),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    ManualUsageLogService.quickLogPresets.entries.map((e) {
                  final isSelected = selectedDuration == e.value;
                  return ChoiceChip(
                    label: Text(e.key),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() => selectedDuration = e.value);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notes field
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: strings.addNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: selectedSubscription == null
                    ? null
                    : () async {
                        await ref.read(manualUsageProvider.notifier).addLog(
                              subscriptionId: selectedSubscription!.id,
                              serviceName: selectedSubscription!.name,
                              date: DateTime.now(),
                              duration: selectedDuration,
                              notes: notesController.text.isNotEmpty
                                  ? notesController.text
                                  : null,
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.usageLogAdded)),
                          );
                        }
                      },
                child: Text(strings.save),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}';
    }
    return '$minutes m';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final SubscriptionUsage usage;
  final Subscription subscription;
  final dynamic strings;

  const _UsageCard({
    required this.usage,
    required this.subscription,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final trendIcon = _getTrendIcon();
    final trendColor = _getTrendColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              usage.serviceName.isNotEmpty
                  ? usage.serviceName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        title: Text(
          usage.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_formatDuration(usage.totalUsage)} • ${usage.launchCount} ${strings.launches}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, color: trendColor, size: 18),
            const SizedBox(width: 4),
            Text(
              _getTrendText(),
              style: TextStyle(color: trendColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrendIcon() {
    switch (usage.trend) {
      case UsageTrend.increasing:
        return Icons.trending_up;
      case UsageTrend.decreasing:
        return Icons.trending_down;
      case UsageTrend.stable:
        return Icons.trending_flat;
      case UsageTrend.newService:
        return Icons.new_releases;
    }
  }

  Color _getTrendColor() {
    switch (usage.trend) {
      case UsageTrend.increasing:
        return Colors.green;
      case UsageTrend.decreasing:
        return Colors.red;
      case UsageTrend.stable:
        return Colors.blue;
      case UsageTrend.newService:
        return Colors.purple;
    }
  }

  String _getTrendText() {
    switch (usage.trend) {
      case UsageTrend.increasing:
        return strings.trendIncreasing;
      case UsageTrend.decreasing:
        return strings.trendDecreasing;
      case UsageTrend.stable:
        return strings.trendStable;
      case UsageTrend.newService:
        return 'New';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}';
    }
    return '$minutes m';
  }
}

class _UnderusedCard extends StatelessWidget {
  final SubscriptionUsage usage;
  final Subscription subscription;
  final dynamic strings;

  const _UnderusedCard({
    required this.usage,
    required this.subscription,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.red.withOpacity(0.05),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.warning_amber, color: Colors.red),
          ),
        ),
        title: Text(
          usage.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDuration(usage.totalUsage)),
            const SizedBox(height: 4),
            Text(
              strings.consideCancelling,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: subscription.price > 0
            ? Text(
                '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes m' : ''}';
    }
    return '$minutes m';
  }
}
