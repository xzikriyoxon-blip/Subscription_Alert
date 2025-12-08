import 'package:flutter/material.dart';
import '../models/subscription_brand.dart';

/// A dialog for selecting a subscription brand from the list.
class BrandSelectionDialog extends StatefulWidget {
  const BrandSelectionDialog({super.key});

  @override
  State<BrandSelectionDialog> createState() => _BrandSelectionDialogState();
}

class _BrandSelectionDialogState extends State<BrandSelectionDialog> {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  List<SubscriptionBrand> get _filteredBrands {
    var brands = SubscriptionBrands.all;
    
    if (_selectedCategory != null) {
      brands = SubscriptionBrands.byCategory(_selectedCategory!);
    }
    
    if (_searchQuery.isNotEmpty) {
      brands = brands.where((brand) =>
        brand.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        brand.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return brands;
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                      const Icon(Icons.apps, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select a Service',
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
                      hintText: 'Search services...',
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
            
            // Category chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ),
                  ...BrandCategory.all.map((category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    ),
                  )),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Brand grid
            Expanded(
              child: _filteredBrands.isEmpty
                  ? const Center(
                      child: Text('No services found'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredBrands.length,
                      itemBuilder: (context, index) {
                        final brand = _filteredBrands[index];
                        return _BrandCard(
                          brand: brand,
                          onTap: () => Navigator.of(context).pop(brand),
                        );
                      },
                    ),
            ),
            
            // Custom option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Subscription'),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final SubscriptionBrand brand;
  final VoidCallback onTap;

  const _BrandCard({
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand logo
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
                  brand.iconUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue[100],
                      child: Center(
                        child: Text(
                          brand.name.substring(0, 1).toUpperCase(),
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
            const SizedBox(height: 8),
            // Brand name
            Text(
              brand.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the brand selection dialog and returns the selected brand.
Future<SubscriptionBrand?> showBrandSelectionDialog(BuildContext context) async {
  return showDialog<SubscriptionBrand>(
    context: context,
    builder: (context) => const BrandSelectionDialog(),
  );
}
