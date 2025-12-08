import 'package:flutter/material.dart';
import '../models/currency.dart';

/// A dialog for selecting a currency from the list.
class CurrencySelectionDialog extends StatefulWidget {
  final String? selectedCurrency;

  const CurrencySelectionDialog({
    super.key,
    this.selectedCurrency,
  });

  @override
  State<CurrencySelectionDialog> createState() => _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Currency> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      // Show popular currencies first, then all
      final popular = Currencies.popular;
      final rest = Currencies.all.where((c) => !Currencies.popularCodes.contains(c.code)).toList();
      return [...popular, ...rest];
    }
    return Currencies.search(_searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select Currency',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search currency...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Popular currencies label
            if (_searchQuery.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Text(
                  'Popular Currencies',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            
            // Currency list
            Expanded(
              child: _filteredCurrencies.isEmpty
                  ? const Center(
                      child: Text('No currencies found'),
                    )
                  : ListView.builder(
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        final isSelected = currency.code == widget.selectedCurrency;
                        
                        // Add "All Currencies" divider
                        Widget? divider;
                        if (_searchQuery.isEmpty && index == Currencies.popularCodes.length) {
                          divider = Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.grey[100],
                            child: Text(
                              'All Currencies',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (divider != null) divider,
                            ListTile(
                              leading: Text(
                                currency.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(currency.code),
                              subtitle: Text(currency.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currency.symbol,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    Icon(Icons.check, color: Theme.of(context).primaryColor),
                                  ],
                                ],
                              ),
                              selected: isSelected,
                              onTap: () => Navigator.of(context).pop(currency.code),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the currency selection dialog and returns the selected currency code.
Future<String?> showCurrencySelectionDialog(
  BuildContext context, {
  String? selectedCurrency,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) => CurrencySelectionDialog(
      selectedCurrency: selectedCurrency,
    ),
  );
}
