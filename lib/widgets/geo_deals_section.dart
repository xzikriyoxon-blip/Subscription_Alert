import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/geo_deal.dart';
import '../providers/feature_providers.dart';
import '../providers/premium_providers.dart';
import '../screens/settings_screen.dart';
import '../l10n/app_strings.dart';

/// Widget displaying location-based deals for subscription services.
/// Shows deals based on user's region with premium gating.
class GeoDealsSection extends ConsumerWidget {
  const GeoDealsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final dealsAsync = ref.watch(geoDealsProvider);
    final userCountry = ref.watch(userCountryCodeProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dealsInYourRegion,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      strings.basedOnLocation(userCountry),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.amber.shade800),
                      const SizedBox(width: 4),
                      Text(
                        strings.limitedView,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Deals list
        dealsAsync.when(
          data: (deals) {
            if (deals.isEmpty) {
              return _buildEmptyState(context, ref);
            }

            return Column(
              children: [
                // Deals cards
                ...deals.map((deal) => _GeoDealCard(deal: deal)),

                // Premium upgrade banner if not premium
                if (!isPremium) _buildPremiumBanner(context, ref),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${strings.error}: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            strings.noDealsInRegion,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.checkBackLater,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
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
          colors: [Colors.blue.shade600, Colors.purple.shade600],
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
                  strings.unlockAllDeals,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  strings.geoDealsPremiuDescription,
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
              foregroundColor: Colors.blue.shade700,
            ),
            child: Text(strings.upgrade),
          ),
        ],
      ),
    );
  }
}

/// Individual deal card
class _GeoDealCard extends ConsumerWidget {
  final GeoDeal deal;

  const _GeoDealCard({required this.deal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: deal.url != null ? () => _launchUrl(deal.url!) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deal icon/image
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(deal.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: deal.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                deal.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  _getCategoryIcon(deal.category),
                                  color: _getCategoryColor(deal.category),
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              _getCategoryIcon(deal.category),
                              color: _getCategoryColor(deal.category),
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Deal info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (deal.discountPercent != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '-${deal.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deal.serviceName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                deal.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Bottom row with price and action
              Row(
                children: [
                  // Region badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(deal.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          deal.regionName,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category badge
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(deal.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(strings, deal.category),
                      style: TextStyle(
                        color: _getCategoryColor(deal.category),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Price
                  if (deal.price != null)
                    Text(
                      '${deal.currency} ${deal.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),

                  // Action button
                  if (deal.url != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                ],
              ),

              // Expiry date
              if (deal.expiresAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        strings.expiresIn(_getDaysUntilExpiry(deal.expiresAt!)),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(DealCategory category) {
    switch (category) {
      case DealCategory.streaming:
        return Colors.red;
      case DealCategory.music:
        return Colors.green;
      case DealCategory.gaming:
        return Colors.purple;
      case DealCategory.cloud:
        return Colors.blue;
      case DealCategory.software:
        return Colors.teal;
      case DealCategory.vpn:
        return Colors.indigo;
      case DealCategory.education:
        return Colors.orange;
      case DealCategory.fitness:
        return Colors.pink;
      case DealCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(DealCategory category) {
    switch (category) {
      case DealCategory.streaming:
        return Icons.play_circle_fill;
      case DealCategory.music:
        return Icons.music_note;
      case DealCategory.gaming:
        return Icons.sports_esports;
      case DealCategory.cloud:
        return Icons.cloud;
      case DealCategory.software:
        return Icons.code;
      case DealCategory.vpn:
        return Icons.vpn_key;
      case DealCategory.education:
        return Icons.school;
      case DealCategory.fitness:
        return Icons.fitness_center;
      case DealCategory.other:
        return Icons.local_offer;
    }
  }

  String _getCategoryName(AppStrings strings, DealCategory category) {
    switch (category) {
      case DealCategory.streaming:
        return strings.categoryStreaming;
      case DealCategory.music:
        return strings.categoryMusic;
      case DealCategory.gaming:
        return strings.categoryGaming;
      case DealCategory.cloud:
        return strings.categoryCloud;
      case DealCategory.software:
        return strings.categorySoftware;
      case DealCategory.vpn:
        return strings.categoryVpn;
      case DealCategory.education:
        return strings.categoryEducation;
      case DealCategory.fitness:
        return strings.categoryFitness;
      case DealCategory.other:
        return strings.categoryOther;
    }
  }

  int _getDaysUntilExpiry(DateTime expiresAt) {
    return expiresAt.difference(DateTime.now()).inDays;
  }
}

/// Full screen for viewing all geo deals
class AllGeoDealsScreen extends ConsumerWidget {
  const AllGeoDealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final allDealsAsync = ref.watch(allGeoDealsProvider);
    final availableRegions = ref.watch(availableGeoRegionsProvider);
    final selectedRegion = ref.watch(_selectedRegionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.allDeals),
        centerTitle: true,
        actions: [
          // Region filter
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              ref.read(_selectedRegionProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(strings.allRegions),
              ),
              ...availableRegions.map((region) => PopupMenuItem(
                    value: region,
                    child: Text(region),
                  )),
            ],
          ),
        ],
      ),
      body: allDealsAsync.when(
        data: (deals) {
          // Filter by selected region
          final filteredDeals = selectedRegion == null
              ? deals
              : deals.where((d) => d.regionCode == selectedRegion).toList();

          if (filteredDeals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    strings.noDealsAvailable,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredDeals.length,
            itemBuilder: (context, index) {
              return _GeoDealCard(deal: filteredDeals[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('${strings.error}: $error'),
        ),
      ),
    );
  }
}

/// Selected region state provider
final _selectedRegionProvider = StateProvider<String?>((ref) => null);
