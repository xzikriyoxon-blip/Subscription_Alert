import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_providers.dart';
import '../services/purchase_service.dart';

/// Shows a dialog to upgrade to premium.
Future<void> showPremiumUpgradeDialog(
    BuildContext context, WidgetRef ref) async {
  await showDialog(
    context: context,
    builder: (context) => const _PremiumUpgradeDialog(),
  );
}

class _PremiumUpgradeDialog extends ConsumerStatefulWidget {
  const _PremiumUpgradeDialog();

  @override
  ConsumerState<_PremiumUpgradeDialog> createState() =>
      _PremiumUpgradeDialogState();
}

class _PremiumUpgradeDialogState extends ConsumerState<_PremiumUpgradeDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final success = await purchaseService.purchasePremium();

      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Purchase could not be initiated. Please try again.';
          _isLoading = false;
        });
      }
      // If successful, the purchase stream will update and we can close
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      await purchaseService.restorePurchases();

      // Wait a moment for the restore to process
      await Future.delayed(const Duration(seconds: 2));

      if (purchaseService.isPremium && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'No previous purchase found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to restore purchases.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for premium status changes
    final isPremium = ref.watch(isPremiumProvider);

    // Close dialog if premium is granted
    if (isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium activated! Enjoy all features.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }

    final purchaseService = ref.watch(purchaseServiceProvider);
    final price = purchaseService.premiumProduct?.price ?? premiumPrice;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Upgrade to Premium',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'One-time purchase',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Features
            const Text(
              'Premium Features:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            _buildFeatureItem(
                Icons.search, 'Where to Watch - Find streaming services'),
            _buildFeatureItem(
                Icons.music_note, 'Music Search - Find songs on platforms'),
            _buildFeatureItem(
                Icons.local_offer, 'Deals & Discounts - Get the best prices'),
            _buildFeatureItem(Icons.health_and_safety,
                'Spend Health - Analyze spending habits'),
            _buildFeatureItem(
                Icons.timeline, 'Timeline - Visual subscription history'),
            _buildFeatureItem(
                Icons.bookmark, 'Wishlist - Track services you want'),
            _buildFeatureItem(
                Icons.analytics, 'Usage Analytics - Track app usage'),
            _buildFeatureItem(
                Icons.description, 'Reports - Export PDF reports'),
            _buildFeatureItem(Icons.calendar_today,
                'Calendar Sync - Sync to Google Calendar'),
            _buildFeatureItem(Icons.currency_exchange,
                'Currency Conversion - Compare prices'),
            _buildFeatureItem(Icons.block, 'No Ads - Ad-free experience'),

            const SizedBox(height: 16),

            // Free features note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Add & manage subscriptions is always FREE!',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                            TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _restorePurchases,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Restore'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _purchasePremium,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upgrade Now'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
