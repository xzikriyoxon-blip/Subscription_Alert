import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/currency.dart';
import '../models/subscription.dart';
import '../models/subscription_brand.dart';
import 'brand_logo.dart';

/// Shows a dialog with subscription details and actions.
class SubscriptionDetailDialog extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkCancelled;
  final VoidCallback? onReactivate;
  final VoidCallback? onMarkPaid;

  const SubscriptionDetailDialog({
    super.key,
    required this.subscription,
    this.onEdit,
    this.onDelete,
    this.onMarkCancelled,
    this.onReactivate,
    this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final numberFormat = NumberFormat('#,##0.00', 'en_US');

    // Get brand for logo
    final brand = subscription.brandId != null
        ? SubscriptionBrands.getById(subscription.brandId!)
        : SubscriptionBrands.getByName(subscription.name);

    // Try to find cancellation link
    String? cancelUrl;
    if (subscription.brandId != null) {
      cancelUrl = CancellationLinks.getByBrandId(subscription.brandId!);
    }
    cancelUrl ??= CancellationLinks.getByName(subscription.name);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: subscription.isCancelled
                    ? Colors.grey[100]
                    : Colors.blue[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  // Icon
                  BrandLogo(
                    brandId: subscription.brandId,
                    brandName: brand?.name ?? subscription.name,
                    iconUrl: brand?.iconUrl,
                    size: 64,
                    borderRadius: 16,
                    backgroundColor: subscription.isCancelled
                        ? Colors.grey[200]
                        : Colors.blue[100],
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    subscription.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: subscription.isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subscription.isCancelled) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'CANCELLED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value:
                    '${Currencies.getSymbol(subscription.currency)}${numberFormat.format(subscription.price)}',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.repeat,
                    label: 'Billing Cycle',
                    value:
                        subscription.cycle == 'monthly' ? 'Monthly' : 'Yearly',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Next Payment',
                    value: dateFormat.format(subscription.nextPaymentDate),
                    valueColor:
                        subscription.status == SubscriptionStatus.overdue
                            ? Colors.red
                            : null,
                  ),
                  if (subscription.isCancelled &&
                      subscription.cancelledAt != null) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.cancel_outlined,
                      label: 'Cancelled On',
                      value: dateFormat.format(subscription.cancelledAt!),
                      valueColor: Colors.grey,
                    ),
                  ],
                  // Trial information
                  if (subscription.isTrial) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.schedule,
                      label: 'Trial Status',
                      value: 'Free Trial',
                      valueColor: Colors.purple,
                    ),
                    if (subscription.trialEndsAt != null) ...[
                      const SizedBox(height: 12),
                      _TrialEndRow(
                        trialEndsAt: subscription.trialEndsAt!,
                        dateFormat: dateFormat,
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mark as Paid button (only enabled when payment is due)
                  if (!subscription.isCancelled && onMarkPaid != null) ...[
                    Builder(
                      builder: (context) {
                        // Check if payment is due (today or past)
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final paymentDate = DateTime(
                          subscription.nextPaymentDate.year,
                          subscription.nextPaymentDate.month,
                          subscription.nextPaymentDate.day,
                        );
                        final isDue = !paymentDate.isAfter(today);

                        return ElevatedButton.icon(
                          onPressed: isDue
                              ? () {
                                  Navigator.of(context).pop();
                                  onMarkPaid?.call();
                                }
                              : null,
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: Text(isDue ? 'Mark as Paid' : 'Not due yet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDue ? Colors.green : Colors.grey[300],
                            foregroundColor:
                                isDue ? Colors.white : Colors.grey[600],
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cancellation link button
                  if (cancelUrl != null && !subscription.isCancelled) ...[
                    OutlinedButton.icon(
                      onPressed: () => _launchCancelUrl(context, cancelUrl!),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Cancel Subscription Online'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // How to cancel (if no direct link)
                  if (cancelUrl == null && !subscription.isCancelled) ...[
                    OutlinedButton.icon(
                      onPressed: () => _showCancelInstructions(context),
                      icon: const Icon(Icons.help_outline, size: 18),
                      label: const Text('How to Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Mark as cancelled / Reactivate
                  if (!subscription.isCancelled) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onMarkCancelled?.call();
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Mark as Cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReactivate?.call();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reactivate Subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Edit and Delete row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit?.call();
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDelete?.call();
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchCancelUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  void _showCancelInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Cancel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For iPhone/iPad:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(CancellationLinks.appleInstructions),
              const SizedBox(height: 16),
              const Text(
                'For Android:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(CancellationLinks.googlePlayInstructions),
              const SizedBox(height: 16),
              const Text(
                'Or visit the service\'s website and look for subscription/account settings.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying trial end date with days remaining.
class _TrialEndRow extends StatelessWidget {
  final DateTime trialEndsAt;
  final DateFormat dateFormat;

  const _TrialEndRow({
    required this.trialEndsAt,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trialEnd =
        DateTime(trialEndsAt.year, trialEndsAt.month, trialEndsAt.day);
    final daysRemaining = trialEnd.difference(today).inDays;

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (daysRemaining < 0) {
      statusText = 'Expired ${-daysRemaining} days ago';
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else if (daysRemaining == 0) {
      statusText = 'Ends today!';
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else if (daysRemaining == 1) {
      statusText = 'Ends tomorrow';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else if (daysRemaining <= 3) {
      statusText = '$daysRemaining days left';
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    } else {
      statusText = '$daysRemaining days left';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.event, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Trial Ends',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              dateFormat.format(trialEndsAt),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows the subscription detail dialog.
Future<void> showSubscriptionDetailDialog(
  BuildContext context, {
  required Subscription subscription,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onMarkCancelled,
  VoidCallback? onReactivate,
  VoidCallback? onMarkPaid,
}) {
  return showDialog(
    context: context,
    builder: (context) => SubscriptionDetailDialog(
      subscription: subscription,
      onEdit: onEdit,
      onDelete: onDelete,
      onMarkCancelled: onMarkCancelled,
      onReactivate: onReactivate,
      onMarkPaid: onMarkPaid,
    ),
  );
}
