import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/regional_price.dart';
import '../providers/feature_providers.dart';
import '../providers/premium_providers.dart';
import '../screens/settings_screen.dart';

/// Widget that displays regional price comparison for a subscription service.
/// This is a premium-only feature that shows prices across different regions.
class RegionalPriceComparator extends ConsumerWidget {
  final String serviceName;

  const RegionalPriceComparator({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    // If not premium, show upgrade prompt
    if (!isPremium) {
      return _PremiumLockCard(serviceName: serviceName);
    }

    final comparisonAsync = ref.watch(regionalPriceComparisonProvider(serviceName));

    return comparisonAsync.when(
      data: (comparison) {
        if (comparison.prices.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.noPriceDataAvailable(serviceName),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _PriceComparisonCard(comparison: comparison);
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(strings.loadingPrices),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${strings.error}: $error'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium lock card shown for non-premium users
class _PremiumLockCard extends ConsumerWidget {
  final String serviceName;

  const _PremiumLockCard({required this.serviceName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade50, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.public, color: Colors.amber.shade800, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.regionalPriceComparison,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        strings.premiumOnlyFeature,
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              strings.regionalPriceDescription(serviceName),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            // Preview of what they'd see
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PreviewFlag(flag: '🇹🇷', label: 'Turkey', isCheapest: true),
                  _PreviewFlag(flag: '🇮🇳', label: 'India', isCheapest: false),
                  _PreviewFlag(flag: '🇦🇷', label: 'Argentina', isCheapest: false),
                  _PreviewFlag(flag: '🇺🇸', label: 'USA', isCheapest: false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to premium upgrade
              },
              icon: const Icon(Icons.star, size: 18),
              label: Text(strings.unlockNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview flag for locked state
class _PreviewFlag extends StatelessWidget {
  final String flag;
  final String label;
  final bool isCheapest;

  const _PreviewFlag({
    required this.flag,
    required this.label,
    required this.isCheapest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        if (isCheapest)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Cheapest',
              style: TextStyle(color: Colors.white, fontSize: 8),
            ),
          ),
      ],
    );
  }
}

/// Price comparison card for premium users
class _PriceComparisonCard extends ConsumerWidget {
  final RegionalPriceComparison comparison;

  const _PriceComparisonCard({required this.comparison});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    final sortedPrices = comparison.prices;
    final cheapest = comparison.cheapest;
    final mostExpensive = comparison.mostExpensive;
    
    // Calculate potential savings
    final potentialSavings = (cheapest != null && mostExpensive != null)
        ? mostExpensive.convertedPrice - cheapest.convertedPrice
        : 0.0;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.public, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.regionalPriceComparison,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${comparison.prices.length} ${strings.regionsCompared}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (potentialSavings > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.savings, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${strings.potentialSavings} $baseCurrency ${potentialSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Savings highlight
          if (cheapest != null && mostExpensive != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.cheapestInRegion(
                        cheapest.original.regionName,
                        '${cheapest.original.currency} ${cheapest.original.price.toStringAsFixed(2)}',
                      ),
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Price list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: sortedPrices.asMap().entries.map((entry) {
                final index = entry.key;
                final priceData = entry.value;
                final isCheapest = index == 0;
                final isMostExpensive = index == sortedPrices.length - 1;

                return _PriceRow(
                  price: priceData.original,
                  convertedPrice: priceData.convertedPrice,
                  targetCurrency: baseCurrency,
                  isCheapest: isCheapest,
                  isMostExpensive: isMostExpensive && sortedPrices.length > 1,
                );
              }).toList(),
            ),
          ),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              strings.priceDisclaimer,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual price row
class _PriceRow extends StatelessWidget {
  final RegionalPrice price;
  final double convertedPrice;
  final String targetCurrency;
  final bool isCheapest;
  final bool isMostExpensive;

  const _PriceRow({
    required this.price,
    required this.convertedPrice,
    required this.targetCurrency,
    required this.isCheapest,
    required this.isMostExpensive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCheapest
            ? Colors.green.shade50
            : isMostExpensive
                ? Colors.red.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCheapest
              ? Colors.green.shade300
              : isMostExpensive
                  ? Colors.red.shade200
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Flag and region
          Text(
            price.flag,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.regionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (price.planName != null)
                  Text(
                    price.planName!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Prices
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${price.currency} ${price.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                '≈ $targetCurrency ${convertedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Badge
          if (isCheapest || isMostExpensive)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCheapest ? Colors.green : Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCheapest ? 'Best' : 'High',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full screen for viewing all regional prices
class RegionalPriceScreen extends ConsumerWidget {
  final String serviceName;

  const RegionalPriceScreen({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.regionalPricesFor(serviceName)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: isPremium
            ? RegionalPriceComparator(serviceName: serviceName)
            : Column(
                children: [
                  _PremiumLockCard(serviceName: serviceName),
                  const SizedBox(height: 24),
                  // Supported services preview
                  _SupportedServicesPreview(),
                ],
              ),
      ),
    );
  }
}

/// Preview of supported services for price comparison
class _SupportedServicesPreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final supportedServices = ref.watch(supportedPriceComparisonServicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.supportedServices,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: supportedServices.map((service) {
                return Chip(
                  label: Text(service),
                  backgroundColor: Colors.blue.shade50,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
