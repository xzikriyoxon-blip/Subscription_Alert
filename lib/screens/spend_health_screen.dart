import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../l10n/app_strings.dart';
import '../models/spend_health.dart';
import '../providers/feature_providers.dart';
import '../providers/premium_providers.dart';
import 'settings_screen.dart';

/// Screen displaying user's subscription spending health score.
/// Shows a score from 0-100 with suggestions for improvement.
class SpendHealthScreen extends ConsumerWidget {
  const SpendHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final score = ref.watch(spendHealthScoreProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final analysis = ref.watch(spendHealthAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.spendHealth),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Score display
            _buildScoreSection(context, ref, score),

            // Status message
            _buildStatusMessage(context, ref, score),

            // Premium upgrade banner (if not premium)
            if (!isPremium) _buildPremiumBanner(context, ref),

            // Suggestions
            _buildSuggestionsSection(context, ref, score),

            // Detailed analysis (premium only)
            if (isPremium && analysis != null)
              _buildAnalysisSection(context, ref, analysis),

            // Score factors (premium only)
            if (isPremium) _buildFactorsSection(context, ref, score),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(
      BuildContext context, WidgetRef ref, SpendHealthScore score) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated score gauge
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _ScoreGaugePainter(
                score: score.score,
                color: _getStatusColor(score.status),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.score.toString(),
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(score.status),
                      ),
                    ),
                    Text(
                      'out of 100',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
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

  Widget _buildStatusMessage(
      BuildContext context, WidgetRef ref, SpendHealthScore score) {
    final strings = ref.watch(stringsProvider);
    final statusText = _getStatusText(strings, score.status);
    final statusColor = _getStatusColor(score.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(score.status), color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: statusColor,
                  ),
                ),
                Text(
                  _getStatusDescription(strings, score.status),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                strings.unlockFullAnalysis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.spendHealthPremiumDescription,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to premium upgrade
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
              ),
              child: Text(strings.upgrade),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(
      BuildContext context, WidgetRef ref, SpendHealthScore score) {
    final strings = ref.watch(stringsProvider);

    if (score.suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.noSuggestions,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.suggestions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...score.suggestions.map((suggestion) => _SuggestionCard(
                suggestion: suggestion,
              )),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(
      BuildContext context, WidgetRef ref, Map<String, dynamic> analysis) {
    final strings = ref.watch(stringsProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    final monthlySpend = analysis['monthlySpend'] as double? ?? 0.0;
    final yearlyProjection = analysis['yearlyProjection'] as double? ?? 0.0;
    final avgPerSubscription = analysis['avgPerSubscription'] as double? ?? 0.0;
    final categoryBreakdown =
        analysis['categoryBreakdown'] as Map<String, double>? ?? {};

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.detailedAnalysis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Spending stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: strings.monthlySpend,
                  value: '$baseCurrency ${monthlySpend.toStringAsFixed(2)}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month,
                  label: strings.yearlyProjection,
                  value: '$baseCurrency ${yearlyProjection.toStringAsFixed(2)}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.receipt,
            label: strings.avgPerSubscription,
            value: '$baseCurrency ${avgPerSubscription.toStringAsFixed(2)}',
            color: Colors.teal,
          ),

          // Category breakdown
          if (categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              strings.categoryBreakdown,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...categoryBreakdown.entries.map((entry) => _CategoryBar(
                  category: entry.key,
                  amount: entry.value,
                  total: monthlySpend,
                  currency: baseCurrency,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorsSection(
      BuildContext context, WidgetRef ref, SpendHealthScore score) {
    final strings = ref.watch(stringsProvider);

    if (score.factors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.scoreFactors,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...score.factors.map((factor) => _FactorRow(factor: factor)),
        ],
      ),
    );
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return Colors.green;
      case HealthStatus.good:
        return Colors.blue;
      case HealthStatus.warning:
        return Colors.orange;
      case HealthStatus.critical:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return Icons.sentiment_very_satisfied;
      case HealthStatus.good:
        return Icons.sentiment_satisfied;
      case HealthStatus.warning:
        return Icons.sentiment_neutral;
      case HealthStatus.critical:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String _getStatusText(AppStrings strings, HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return strings.excellentHealth;
      case HealthStatus.good:
        return strings.goodHealth;
      case HealthStatus.warning:
        return strings.warningHealth;
      case HealthStatus.critical:
        return strings.criticalHealth;
    }
  }

  String _getStatusDescription(AppStrings strings, HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return strings.excellentHealthDesc;
      case HealthStatus.good:
        return strings.goodHealthDesc;
      case HealthStatus.warning:
        return strings.warningHealthDesc;
      case HealthStatus.critical:
        return strings.criticalHealthDesc;
    }
  }
}

/// Custom painter for the score gauge
class _ScoreGaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _ScoreGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Score arc
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

/// Suggestion card widget
class _SuggestionCard extends StatelessWidget {
  final String suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category breakdown bar
class _CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final String currency;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '$currency ${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Entertainment': Colors.purple,
      'Music': Colors.pink,
      'Video': Colors.red,
      'Gaming': Colors.green,
      'Cloud': Colors.blue,
      'Software': Colors.teal,
      'News': Colors.orange,
      'Fitness': Colors.lime,
      'Food': Colors.amber,
      'Shopping': Colors.indigo,
      'Finance': Colors.cyan,
      'Education': Colors.deepPurple,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}

/// Score factor row
class _FactorRow extends StatelessWidget {
  final ScoreFactor factor;

  const _FactorRow({required this.factor});

  @override
  Widget build(BuildContext context) {
    final isPositive = factor.impact > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.add_circle : Icons.remove_circle,
            color: isPositive ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${factor.impact}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
