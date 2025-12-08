import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_brand.dart';
import '../models/currency.dart';
import '../providers/subscription_providers.dart';
import '../providers/premium_providers.dart';
import '../widgets/brand_selection_dialog.dart';
import '../widgets/currency_selection_dialog.dart';
import '../services/ad_service.dart';

/// Screen for adding or editing a subscription.
/// 
/// If [subscription] is provided, the screen is in edit mode.
/// Otherwise, it's in create mode.
class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? subscription;

  const AddEditSubscriptionScreen({
    super.key,
    this.subscription,
  });

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState
    extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late String _selectedCycle;
  late String _selectedCurrency;
  late DateTime _selectedDate;
  SubscriptionBrand? _selectedBrand;
  String? _brandIconUrl;
  
  // Trial Guard fields
  bool _isTrial = false;
  DateTime? _trialEndsAt;
  
  bool _isLoading = false;
  String? _errorMessage;

  /// Whether we're editing an existing subscription or creating a new one.
  bool get _isEditing => widget.subscription != null;
  
  /// List of available billing cycles.
  static const List<String> _cycles = ['monthly', 'yearly', 'weekly', 'quarterly'];

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing subscription data or defaults
    final sub = widget.subscription;
    _nameController = TextEditingController(text: sub?.name ?? '');
    _priceController = TextEditingController(
      text: sub?.price.toStringAsFixed(0) ?? '',
    );
    _selectedCycle = sub?.cycle ?? 'monthly';
    _selectedCurrency = sub?.currency ?? 'UZS';
    _selectedDate = sub?.nextPaymentDate ?? DateTime.now().add(
      const Duration(days: 30),
    );
    
    // Initialize trial fields
    _isTrial = sub?.isTrial ?? false;
    _trialEndsAt = sub?.trialEndsAt;
    
    // Try to match existing subscription to a brand
    if (sub != null) {
      _selectedBrand = SubscriptionBrands.all.where(
        (b) => b.name.toLowerCase() == sub.name.toLowerCase()
      ).firstOrNull;
      _brandIconUrl = _selectedBrand?.iconUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Validates and saves the subscription.
  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final controller = ref.read(subscriptionControllerProvider);
    
    if (controller == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Not authenticated';
      });
      return;
    }

    try {
      final subscription = Subscription(
        id: widget.subscription?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        currency: _selectedCurrency,
        cycle: _selectedCycle,
        nextPaymentDate: _selectedDate,
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isTrial: _isTrial,
        trialEndsAt: _isTrial ? _trialEndsAt : null,
        // Reset warning flags if trial date changed
        trialWarningSentBasic: _isTrial && widget.subscription?.trialEndsAt == _trialEndsAt 
            ? (widget.subscription?.trialWarningSentBasic ?? false) 
            : false,
        trialWarningSentPremium3d: _isTrial && widget.subscription?.trialEndsAt == _trialEndsAt 
            ? (widget.subscription?.trialWarningSentPremium3d ?? false) 
            : false,
        trialWarningSentPremium1d: _isTrial && widget.subscription?.trialEndsAt == _trialEndsAt 
            ? (widget.subscription?.trialWarningSentPremium1d ?? false) 
            : false,
      );

      if (_isEditing) {
        await controller.updateSubscription(subscription);
      } else {
        await controller.addSubscription(subscription);
      }

      if (mounted) {
        // Show interstitial ad for non-premium users after saving
        final isPremium = ref.read(isPremiumProvider);
        if (!isPremium) {
          await AdService().showInterstitialAdIfReady();
        }
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? '${subscription.name} updated' 
                  : '${subscription.name} added',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Opens the date picker to select the next payment date.
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Select next payment date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Opens brand selection dialog.
  Future<void> _selectBrand() async {
    final brand = await showBrandSelectionDialog(context);
    if (brand != null) {
      setState(() {
        _selectedBrand = brand;
        _brandIconUrl = brand.iconUrl;
        _nameController.text = brand.name;
        if (brand.defaultCycle != null) {
          _selectedCycle = brand.defaultCycle!;
        }
      });
    }
  }

  /// Opens currency selection dialog.
  Future<void> _selectCurrency() async {
    final currency = await showCurrencySelectionDialog(
      context,
      selectedCurrency: _selectedCurrency,
    );
    if (currency != null) {
      setState(() {
        _selectedCurrency = currency;
      });
    }
  }

  /// Opens the date picker to select the trial end date.
  Future<void> _selectTrialEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _trialEndsAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select trial end date',
    );

    if (picked != null) {
      setState(() {
        _trialEndsAt = picked;
      });
    }
  }

  /// Builds the trial section with switch and date picker.
  Widget _buildTrialSection(DateFormat dateFormat) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _isTrial ? Colors.orange : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _isTrial ? Colors.orange.withValues(alpha: 0.05) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trial switch
          SwitchListTile(
            title: const Text('This is a free trial'),
            subtitle: Text(
              _isTrial 
                  ? 'Get reminders before your trial ends' 
                  : 'Enable to track trial expiration',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            value: _isTrial,
            onChanged: (value) {
              setState(() {
                _isTrial = value;
                if (value && _trialEndsAt == null) {
                  // Default to 7 days from now
                  _trialEndsAt = DateTime.now().add(const Duration(days: 7));
                }
              });
            },
            secondary: Icon(
              Icons.schedule,
              color: _isTrial ? Colors.orange : Colors.grey,
            ),
            activeColor: Colors.orange,
          ),
          
          // Trial end date picker (shown only when trial is enabled)
          if (_isTrial) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trial ends on',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectTrialEndDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text(
                            _trialEndsAt != null
                                ? dateFormat.format(_trialEndsAt!)
                                : 'Select date',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_trialEndsAt != null)
                    _buildTrialDaysRemaining(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a widget showing days remaining in trial.
  Widget _buildTrialDaysRemaining() {
    if (_trialEndsAt == null) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trialEnd = DateTime(_trialEndsAt!.year, _trialEndsAt!.month, _trialEndsAt!.day);
    final daysRemaining = trialEnd.difference(today).inDays;
    
    Color color;
    String text;
    IconData icon;
    
    if (daysRemaining < 0) {
      color = Colors.red;
      text = 'Trial expired ${-daysRemaining} days ago';
      icon = Icons.warning;
    } else if (daysRemaining == 0) {
      color = Colors.red;
      text = 'Trial ends today!';
      icon = Icons.warning;
    } else if (daysRemaining <= 3) {
      color = Colors.orange;
      text = '$daysRemaining days remaining';
      icon = Icons.schedule;
    } else {
      color = Colors.green;
      text = '$daysRemaining days remaining';
      icon = Icons.check_circle;
    }
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final currency = Currencies.getByCode(_selectedCurrency);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Subscription' : 'Add Subscription'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Brand selection button (only for new subscriptions)
              if (!_isEditing) ...[
                InkWell(
                  onTap: _selectBrand,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      children: [
                        if (_selectedBrand != null) ...[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _selectedBrand!.iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.blue[100],
                                    child: Center(
                                      child: Text(
                                        _selectedBrand!.name.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue[100],
                            ),
                            child: Icon(Icons.apps, color: Colors.blue[700]),
                          ),
                        ],
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedBrand?.name ?? 'Select a Service',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedBrand?.category ?? 'Choose from popular services or add custom',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Subscription name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Subscription Name',
                  hintText: 'e.g., Netflix, Spotify',
                  prefixIcon: _brandIconUrl != null 
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            _brandIconUrl!,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.subscriptions_outlined);
                            },
                          ),
                        ),
                      )
                    : const Icon(Icons.subscriptions_outlined),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subscription name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and currency row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'e.g., 29000',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Currency selector
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: _selectCurrency,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              currency?.flag ?? '💰',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(_selectedCurrency),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Billing cycle dropdown
              DropdownButtonFormField<String>(
                value: _selectedCycle,
                decoration: const InputDecoration(
                  labelText: 'Billing Cycle',
                  prefixIcon: Icon(Icons.repeat),
                  border: OutlineInputBorder(),
                ),
                items: _cycles.map((cycle) {
                  String label;
                  switch (cycle) {
                    case 'weekly':
                      label = 'Weekly';
                      break;
                    case 'monthly':
                      label = 'Monthly';
                      break;
                    case 'quarterly':
                      label = 'Quarterly';
                      break;
                    case 'yearly':
                      label = 'Yearly';
                      break;
                    default:
                      label = cycle;
                  }
                  return DropdownMenuItem(
                    value: cycle,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCycle = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Next Payment Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Trial Guard Section
              _buildTrialSection(dateFormat),
              const SizedBox(height: 16),

              // Monthly equivalent (for yearly subscriptions)
              if (_selectedCycle == 'yearly' && 
                  _priceController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Monthly equivalent: ${(double.tryParse(_priceController.text) ?? 0 / 12).toStringAsFixed(0)} $_selectedCurrency',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSubscription,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Update Subscription' : 'Add Subscription',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
