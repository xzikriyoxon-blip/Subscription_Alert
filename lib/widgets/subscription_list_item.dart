import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_brand.dart';

/// A list item widget displaying a subscription's details.
/// 
/// Shows the subscription name, price, next payment date, cycle,
/// and status indicator (overdue, soon, or active).
class SubscriptionListItem extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkCancelled;
  
  /// Optional converted amount in user's base currency (for premium users).
  final double? convertedAmount;
  
  /// The currency the amount was converted to.
  final String? convertedCurrency;

  const SubscriptionListItem({
    super.key,
    required this.subscription,
    this.onTap,
    this.onDelete,
    this.onMarkCancelled,
    this.convertedAmount,
    this.convertedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final numberFormat = NumberFormat('#,##0.##', 'en_US');
    final status = subscription.status;
    
    // Get brand for logo
    final brand = subscription.brandId != null 
        ? SubscriptionBrands.getById(subscription.brandId!)
        : SubscriptionBrands.getByName(subscription.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusBorderColor(status),
          width: status == SubscriptionStatus.active ? 0 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subscription icon/logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: brand != null
                      ? Image.network(
                          brand.iconUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              subscription.name.isNotEmpty 
                                  ? subscription.name[0].toUpperCase() 
                                  : '?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(status),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            subscription.name.isNotEmpty 
                                ? subscription.name[0].toUpperCase() 
                                : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Subscription details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subscription.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Trial badge (shown before status chip)
                        if (subscription.isTrial) ...[
                          _buildTrialBadge(),
                          const SizedBox(width: 4),
                        ],
                        _buildStatusChip(status),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Price and cycle with optional conversion
                    Row(
                      children: [
                        Text(
                          '${numberFormat.format(subscription.price)} ${subscription.currency}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (convertedAmount != null && convertedCurrency != null) ...[
                          Text(
                            ' (~${numberFormat.format(convertedAmount!)} $convertedCurrency)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        Text(
                          ' / ${subscription.cycle}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Next payment date or trial end date
                    if (subscription.isTrial && subscription.trialEndsAt != null) ...[
                      _buildTrialEndInfo(dateFormat),
                    ] else ...[
                      Text(
                        'Next: ${dateFormat.format(subscription.nextPaymentDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusTextColor(status),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status indicator chip.
  Widget _buildStatusChip(SubscriptionStatus status) {
    String label;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case SubscriptionStatus.overdue:
        label = 'Overdue';
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        break;
      case SubscriptionStatus.soon:
        label = 'Soon';
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        break;
      case SubscriptionStatus.active:
        label = 'Active';
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        break;
      case SubscriptionStatus.cancelled:
        label = 'Cancelled';
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Returns the primary color for the given status.
  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.overdue:
        return Colors.red;
      case SubscriptionStatus.soon:
        return Colors.orange;
      case SubscriptionStatus.active:
        return Colors.blue;
      case SubscriptionStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Returns the border color for the given status.
  Color _getStatusBorderColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.overdue:
        return Colors.red[200]!;
      case SubscriptionStatus.soon:
        return Colors.orange[200]!;
      case SubscriptionStatus.active:
        return Colors.transparent;
      case SubscriptionStatus.cancelled:
        return Colors.grey[300]!;
    }
  }

  /// Returns the text color for the payment date based on status.
  Color _getStatusTextColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.overdue:
        return Colors.red[600]!;
      case SubscriptionStatus.soon:
        return Colors.orange[600]!;
      case SubscriptionStatus.active:
        return Colors.grey[500]!;
      case SubscriptionStatus.cancelled:
        return Colors.grey[400]!;
    }
  }

  /// Builds the TRIAL badge.
  Widget _buildTrialBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Text(
        'TRIAL',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.purple[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds the trial end info text.
  Widget _buildTrialEndInfo(DateFormat dateFormat) {
    if (subscription.trialEndsAt == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trialEnd = DateTime(
      subscription.trialEndsAt!.year,
      subscription.trialEndsAt!.month,
      subscription.trialEndsAt!.day,
    );
    final daysRemaining = trialEnd.difference(today).inDays;

    String text;
    Color color;

    if (daysRemaining < 0) {
      text = 'Trial expired ${-daysRemaining} days ago';
      color = Colors.red[600]!;
    } else if (daysRemaining == 0) {
      text = 'Trial ends today!';
      color = Colors.red[600]!;
    } else if (daysRemaining == 1) {
      text = 'Trial ends tomorrow';
      color = Colors.orange[600]!;
    } else if (daysRemaining <= 3) {
      text = 'Trial ends in $daysRemaining days';
      color = Colors.orange[600]!;
    } else {
      text = 'Trial ends: ${dateFormat.format(subscription.trialEndsAt!)}';
      color = Colors.purple[600]!;
    }

    return Row(
      children: [
        Icon(Icons.schedule, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
