import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist.dart';
import '../providers/feature_providers.dart';
import '../providers/premium_providers.dart';
import 'settings_screen.dart';

/// Screen displaying user's wishlists for saving subscription ideas.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final wishlistsAsync = ref.watch(wishlistsStreamProvider);
    final canCreate = ref.watch(canCreateWishlistProvider);
    final limits = ref.watch(wishlistLimitsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.wishlists),
        centerTitle: true,
        actions: [
          if (!isPremium)
            IconButton(
              icon: const Icon(Icons.workspace_premium, color: Colors.amber),
              tooltip: strings.upgradeToPremium,
              onPressed: () => _showPremiumDialog(context, ref),
            ),
        ],
      ),
      body: wishlistsAsync.when(
        data: (wishlists) {
          if (wishlists.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildWishlistList(context, ref, wishlists, limits);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('${strings.error}: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateWishlistDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(strings.newWishlist),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showPremiumDialog(context, ref),
              icon: const Icon(Icons.star, color: Colors.amber),
              label: Text(strings.upgradeToPremium),
              backgroundColor: Colors.grey[300],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              strings.noWishlists,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.createWishlistToStart,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateWishlistDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(strings.createFirstWishlist),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistList(BuildContext context, WidgetRef ref,
      List<WishList> wishlists, Map<String, dynamic> limits) {
    final strings = ref.watch(stringsProvider);
    final isPremium = limits['isPremium'] as bool;
    final maxLists = limits['maxLists'] as int;

    return Column(
      children: [
        // Limits info banner
        if (!isPremium)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.wishlistLimitInfo(wishlists.length, maxLists),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Wishlists
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: wishlists.length,
            itemBuilder: (context, index) {
              final wishlist = wishlists[index];
              return _WishlistCard(
                wishlist: wishlist,
                onTap: () => _navigateToWishlistDetail(context, wishlist),
                onEdit: () => _showEditWishlistDialog(context, ref, wishlist),
                onDelete: () => _showDeleteConfirmation(context, ref, wishlist),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateWishlistDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.read(stringsProvider);
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.createWishlist),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: strings.wishlistName,
                hintText: strings.wishlistNameHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: strings.description,
                hintText: strings.wishlistDescriptionHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              final controller = ref.read(wishlistControllerProvider);
              if (controller != null) {
                try {
                  await controller.createWishlist(
                    nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.wishlistCreated)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(strings.create),
          ),
        ],
      ),
    );
  }

  void _showEditWishlistDialog(
      BuildContext context, WidgetRef ref, WishList wishlist) {
    final strings = ref.read(stringsProvider);
    final nameController = TextEditingController(text: wishlist.name);
    final descController = TextEditingController(text: wishlist.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.editWishlist),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: strings.wishlistName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: strings.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              final controller = ref.read(wishlistControllerProvider);
              if (controller != null) {
                await controller.updateWishlist(
                  wishlist.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.wishlistUpdated)),
                  );
                }
              }
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, WishList wishlist) {
    final strings = ref.read(stringsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteWishlist),
        content: Text(strings.deleteWishlistConfirmation(wishlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final controller = ref.read(wishlistControllerProvider);
              if (controller != null) {
                await controller.deleteWishlist(wishlist.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.wishlistDeleted)),
                  );
                }
              }
            },
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    final strings = ref.read(stringsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(strings.upgradeToPremium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.wishlistPremiumBenefits),
            const SizedBox(height: 16),
            _PremiumFeature(text: strings.unlimitedWishlists),
            _PremiumFeature(text: strings.unlimitedItemsPerList),
            _PremiumFeature(text: strings.moveItemsBetweenLists),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.maybeLater),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium upgrade screen
            },
            child: Text(strings.upgrade),
          ),
        ],
      ),
    );
  }

  void _navigateToWishlistDetail(BuildContext context, WishList wishlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WishlistDetailScreen(wishlist: wishlist),
      ),
    );
  }
}

/// Card widget for displaying a wishlist
class _WishlistCard extends StatelessWidget {
  final WishList wishlist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WishlistCard({
    required this.wishlist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bookmark,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlist.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (wishlist.description != null &&
                        wishlist.description!.isNotEmpty)
                      Text(
                        wishlist.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '${wishlist.itemCount} items',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(context.findAncestorWidgetOfExactType<WishlistScreen>() != null ? 'Edit' : 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium feature row
class _PremiumFeature extends StatelessWidget {
  final String text;

  const _PremiumFeature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Screen displaying items in a wishlist
class WishlistDetailScreen extends ConsumerWidget {
  final WishList wishlist;

  const WishlistDetailScreen({super.key, required this.wishlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final itemsAsync = ref.watch(wishlistItemsStreamProvider(wishlist.id));
    final isPremium = ref.watch(isPremiumProvider);
    final limits = ref.watch(wishlistLimitsProvider);
    final maxItems = limits['maxItemsPerList'] as int;

    return Scaffold(
      appBar: AppBar(
        title: Text(wishlist.name),
        centerTitle: true,
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return Column(
            children: [
              // Item count info
              if (!isPremium)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        strings.itemsLimitInfo(items.length, maxItems),
                        style: TextStyle(color: Colors.blue[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // Items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _WishlistItemCard(
                      item: item,
                      onDelete: () => _deleteItem(context, ref, item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref, isPremium, limits),
        icon: const Icon(Icons.add),
        label: Text(strings.addItem),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            strings.noItemsInWishlist,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.addItemsToWishlist,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref, bool isPremium,
      Map<String, dynamic> limits) {
    final strings = ref.read(stringsProvider);
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.addToWishlist),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: strings.serviceName,
                  hintText: strings.serviceNameHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: strings.estimatedPrice,
                  hintText: strings.estimatedPriceHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: strings.note,
                  hintText: strings.noteHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final controller = ref.read(wishlistControllerProvider);
              if (controller != null) {
                try {
                  await controller.addItem(
                    listId: wishlist.id,
                    serviceName: nameController.text.trim(),
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    estimatedPrice: priceController.text.trim().isEmpty
                        ? null
                        : priceController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.itemAdded)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(strings.add),
          ),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, String itemId) async {
    final strings = ref.read(stringsProvider);
    final controller = ref.read(wishlistControllerProvider);

    if (controller != null) {
      await controller.deleteItem(wishlist.id, itemId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.itemRemoved)),
        );
      }
    }
  }
}

/// Card widget for displaying a wishlist item
class _WishlistItemCard extends StatelessWidget {
  final WishListItem item;
  final VoidCallback onDelete;

  const _WishlistItemCard({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: item.imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    item.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.bookmark, color: Colors.purple[700]),
                  ),
                )
              : Icon(Icons.bookmark, color: Colors.purple[700]),
        ),
        title: Text(
          item.serviceName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.estimatedPrice != null)
              Text(
                '${item.currency ?? '\$'}${item.estimatedPrice}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            if (item.note != null && item.note!.isNotEmpty)
              Text(
                item.note!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
