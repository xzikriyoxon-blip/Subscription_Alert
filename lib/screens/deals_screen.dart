import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription_deal.dart';
import '../models/subscription_brand.dart';
import '../services/location_service.dart';
import 'settings_screen.dart';

/// Provider for selected deal filter.
final dealFilterProvider = StateProvider<DealType?>((ref) => null);

/// Provider for user's country code.
final userCountryProvider = FutureProvider<String>((ref) async {
  return LocationService.getCountryCode();
});

/// Provider for user's country name.
final userCountryNameProvider = FutureProvider<String>((ref) async {
  return LocationService.getCountryName();
});

/// Provider to toggle showing only regional deals.
final showRegionalDealsProvider = StateProvider<bool>((ref) => true);

/// Screen to browse subscription deals and offers.
class DealsScreen extends ConsumerWidget {
  const DealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final selectedFilter = ref.watch(dealFilterProvider);
    final countryAsync = ref.watch(userCountryProvider);
    final showRegionalOnly = ref.watch(showRegionalDealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.deals),
        centerTitle: true,
        actions: [
          // Region info button
          countryAsync.when(
            data: (country) => TextButton.icon(
              onPressed: () => _showRegionInfo(context, ref, country),
              icon: Text(LocationService.getFlag(country),
                  style: const TextStyle(fontSize: 20)),
              label: Text(country, style: const TextStyle(fontSize: 12)),
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.location_off),
              onPressed: () => _showRegionInfo(context, ref, 'US'),
            ),
          ),
        ],
      ),
      body: countryAsync.when(
        data: (countryCode) {
          final allDeals = showRegionalOnly
              ? DealsRepository.getDealsForCountry(countryCode)
              : DealsRepository.getAllDealsWithRegional();

          final filteredDeals = selectedFilter != null
              ? allDeals.where((d) => d.dealType == selectedFilter).toList()
              : allDeals;

          return Column(
            children: [
              // Region toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Text(
                      LocationService.getFlag(countryCode),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        showRegionalOnly
                            ? '${strings.showingDealsFor} ${LocationService.getRegionDisplayName(countryCode)}'
                            : strings.showingAllDeals,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Switch(
                      value: showRegionalOnly,
                      onChanged: (v) => ref
                          .read(showRegionalDealsProvider.notifier)
                          .state = v,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _FilterChip(
                      label: strings.allDeals,
                      isSelected: selectedFilter == null,
                      onTap: () =>
                          ref.read(dealFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 8),
                    ...DealType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: type.label,
                            isSelected: selectedFilter == type,
                            onTap: () => ref
                                .read(dealFilterProvider.notifier)
                                .state = type,
                          ),
                        )),
                  ],
                ),
              ),

              // Deals list
              Expanded(
                child: filteredDeals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              strings.noDealsFound,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(showRegionalDealsProvider.notifier)
                                    .state = false;
                              },
                              child: Text(strings.showAllDeals),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDeals.length,
                        itemBuilder: (context, index) {
                          return _DealCard(deal: filteredDeals[index]);
                        },
                      ),
              ),

              // Affiliate disclosure
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Text(
                  strings.affiliateDisclosure,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Could not detect location',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  LocationService.clearCache();
                  ref.invalidate(userCountryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegionInfo(
      BuildContext context, WidgetRef ref, String currentCountry) {
    final strings = ref.read(stringsProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  LocationService.getFlag(currentCountry),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.yourLocation,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        LocationService.getRegionDisplayName(currentCountry),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              strings.regionExplanation,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      LocationService.clearCache();
                      ref.invalidate(userCountryProvider);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(strings.refreshLocation),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final SubscriptionDeal deal;

  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final brand = SubscriptionBrands.getById(deal.brandId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openDeal(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Brand logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: brand != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              brand.iconUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            ),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(width: 12),

                  // Brand name and deal type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.brandName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDealTypeColor(deal.dealType)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            deal.dealType.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getDealTypeColor(deal.dealType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Discount badge
                  if (deal.discountText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        deal.discountText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                deal.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                deal.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 12),

              // Price row
              Row(
                children: [
                  if (deal.originalPrice != null) ...[
                    Text(
                      deal.originalPrice!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (deal.dealPrice != null)
                    Text(
                      deal.dealPrice!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  const Spacer(),

                  // Get Deal button
                  ElevatedButton.icon(
                    onPressed: () => _openDeal(context),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Get Deal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              // Promo code if available
              if (deal.promoCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.confirmation_number,
                          color: Colors.amber[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Code: ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        deal.promoCode!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(Icons.local_offer, color: Colors.grey[400], size: 24);
  }

  Color _getDealTypeColor(DealType type) {
    switch (type) {
      case DealType.freeTrial:
        return Colors.green;
      case DealType.discount:
        return Colors.red;
      case DealType.bundle:
        return Colors.purple;
      case DealType.studentDiscount:
        return Colors.blue;
      case DealType.familyPlan:
        return Colors.orange;
      case DealType.annualSavings:
        return Colors.teal;
    }
  }

  Future<void> _openDeal(BuildContext context) async {
    final uri = Uri.parse(deal.affiliateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
