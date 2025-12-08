import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/streaming_content.dart';
import '../models/subscription.dart';
import '../models/media_favorite.dart';
import '../services/tmdb_service.dart';
import '../providers/subscription_providers.dart';
import '../providers/feature_providers.dart';
import 'settings_screen.dart';

/// Provider for TMDB service.
final tmdbServiceProvider = Provider<TMDBService>((ref) => TMDBService());

/// Provider for search results.
final searchResultsProvider = StateProvider<List<StreamingContent>>((ref) => []);

/// Provider for search loading state.
final searchLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for trending content.
final trendingProvider = FutureProvider<List<StreamingContent>>((ref) async {
  final tmdb = ref.read(tmdbServiceProvider);
  return tmdb.getTrending();
});

/// Screen to search for movies/TV shows and see streaming availability.
class WatchSearchScreen extends ConsumerStatefulWidget {
  const WatchSearchScreen({super.key});

  @override
  ConsumerState<WatchSearchScreen> createState() => _WatchSearchScreenState();
}

class _WatchSearchScreenState extends ConsumerState<WatchSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _tmdb = TMDBService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      ref.read(searchResultsProvider.notifier).state = [];
      return;
    }

    ref.read(searchLoadingProvider.notifier).state = true;
    
    try {
      final results = await _tmdb.searchWithProviders(query);
      if (mounted) {
        ref.read(searchResultsProvider.notifier).state = results;
      }
    } catch (e) {
      print('Search error: $e');
    } finally {
      if (mounted) {
        ref.read(searchLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final isLoading = ref.watch(searchLoadingProvider);
    final trendingAsync = ref.watch(trendingProvider);

    // Check if API is configured
    if (!TMDBService.isConfigured) {
      return Scaffold(
        appBar: AppBar(
          title: Text(strings.whereToWatch),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.key, size: 64, color: Colors.orange[400]),
                const SizedBox(height: 24),
                const Text(
                  'TMDB API Key Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'To use this feature, you need a free TMDB API key:\n\n'
                  '1. Go to themoviedb.org/signup\n'
                  '2. Create a free account\n'
                  '3. Go to Settings > API\n'
                  '4. Create a new API key\n'
                  '5. Copy the API Key (v3 auth)\n'
                  '6. Paste it in lib/services/tmdb_service.dart',
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.whereToWatch),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.search),
              text: strings.search,
            ),
            Tab(
              icon: const Icon(Icons.favorite),
              text: strings.favorites,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Search Tab
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: strings.searchMoviesAndShows,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchResultsProvider.notifier).state = [];
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onSubmitted: _search,
                  onChanged: (value) {
                    setState(() {}); // Update suffix icon
                    if (value.length > 2) {
                      _search(value);
                    }
                  },
                ),
              ),

              // Results or Trending
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                        ? _buildTrendingSection(trendingAsync, strings)
                        : _buildSearchResults(searchResults, strings),
              ),
              
              // TMDB Attribution footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by ',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const Text('T', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
                    const Text('M', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF01B4E4))),
                    const Text('D', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF90CEA1))),
                    const Text('B', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF01B4E4))),
                  ],
                ),
              ),
            ],
          ),
          
          // Favorites Tab
          _buildFavoritesTab(strings),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(AsyncValue<List<StreamingContent>> trendingAsync, dynamic strings) {
    return trendingAsync.when(
      data: (trending) {
        if (trending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  strings.findWhereToWatch,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '🔥 ${strings.trending}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trending.length,
                itemBuilder: (context, index) {
                  return _ContentCard(
                    content: trending[index],
                    strings: strings,
                    onTap: () => _showContentDetails(trending[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              strings.findWhereToWatch,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<StreamingContent> results, dynamic strings) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              strings.noResultsFound,
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              strings.tryDifferentSearch,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _ContentCard(
          content: results[index],
          strings: strings,
          showProviders: true,
          onTap: () => _showContentDetails(results[index]),
        );
      },
    );
  }

  void _showContentDetails(StreamingContent content) async {
    // Get providers if not already loaded
    List<StreamingProvider> providers = content.providers;
    if (providers.isEmpty) {
      providers = await _tmdb.getProviders(content.id, content.mediaType);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ContentDetailsSheet(
        content: content.copyWith(providers: providers),
        userSubscriptions: ref.read(subscriptionsProvider),
      ),
    );
  }

  Widget _buildFavoritesTab(dynamic strings) {
    final favorites = ref.watch(videoFavoritesProvider);
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              strings.noFavoritesYet,
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                strings.tapHeartToAdd,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return _FavoriteCard(
          favorite: favorite,
          strings: strings,
          onRemove: () async {
            await ref.read(mediaFavoritesProvider.notifier).removeFavorite(favorite.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.removedFromFavorites)),
              );
            }
          },
        );
      },
    );
  }
}

class _ContentCard extends ConsumerWidget {
  final StreamingContent content;
  final bool showProviders;
  final VoidCallback onTap;
  final dynamic strings;

  const _ContentCard({
    required this.content,
    this.showProviders = false,
    required this.onTap,
    this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(mediaFavoritesProvider.notifier);
    final isFavorite = favoritesNotifier.isVideoFavorite(content.id, content.mediaType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: content.posterUrl.isNotEmpty
                    ? Image.network(
                        content.posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with favorite button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            content.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Favorite button
                        GestureDetector(
                          onTap: () async {
                            final result = await favoritesNotifier.toggleVideoFavorite(
                              tmdbId: content.id,
                              title: content.title,
                              mediaType: content.mediaType,
                              posterPath: content.posterPath,
                              year: content.year,
                              rating: content.voteAverage,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result 
                                      ? (strings?.addedToFavorites ?? 'Added to favorites')
                                      : (strings?.removedFromFavorites ?? 'Removed from favorites')),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Year and Type
                    Row(
                      children: [
                        if (content.year.isNotEmpty) ...[
                          Text(
                            content.year,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: content.mediaType == 'movie'
                                ? Colors.blue[100]
                                : Colors.purple[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            content.mediaType == 'movie' 
                                ? (strings?.movie ?? 'Movie') 
                                : (strings?.tvShow ?? 'TV Show'),
                            style: TextStyle(
                              fontSize: 11,
                              color: content.mediaType == 'movie'
                                  ? Colors.blue[800]
                                  : Colors.purple[800],
                            ),
                          ),
                        ),
                        if (content.voteAverage != null && content.voteAverage! > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            content.voteAverage!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Providers preview
                    if (showProviders && content.providers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: content.providers
                            .where((p) => p.type == 'flatrate')
                            .take(5)
                            .map((p) => _ProviderChip(provider: p, small: true))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      color: Colors.grey[300],
      child: Icon(
        content.mediaType == 'movie' ? Icons.movie : Icons.tv,
        size: 32,
        color: Colors.grey[500],
      ),
    );
  }
}

class _ContentDetailsSheet extends StatelessWidget {
  final StreamingContent content;
  final List<Subscription> userSubscriptions;

  const _ContentDetailsSheet({
    required this.content,
    required this.userSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final streamProviders = content.providers.where((p) => p.type == 'flatrate').toList();
    final rentProviders = content.providers.where((p) => p.type == 'rent').toList();
    final buyProviders = content.providers.where((p) => p.type == 'buy').toList();

    // Check which providers user has subscribed to
    final userBrandIds = userSubscriptions
        .where((s) => !s.isCancelled && s.brandId != null)
        .map((s) => s.brandId!)
        .toSet();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content.posterUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          content.posterUrl,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (content.year.isNotEmpty)
                                Text(
                                  content.year,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: content.mediaType == 'movie'
                                      ? Colors.blue[100]
                                      : Colors.purple[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  content.mediaType == 'movie' ? 'Movie' : 'TV Show',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: content.mediaType == 'movie'
                                        ? Colors.blue[800]
                                        : Colors.purple[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (content.voteAverage != null && content.voteAverage! > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, size: 18, color: Colors.amber[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${content.voteAverage!.toStringAsFixed(1)} / 10',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Overview
                if (content.overview != null && content.overview!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    content.overview!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 24),

                // Streaming section
                if (streamProviders.isNotEmpty) ...[
                  _buildProviderSection(
                    context,
                    '📺 Stream',
                    streamProviders,
                    userBrandIds,
                    Colors.green,
                    content.title,
                  ),
                  const SizedBox(height: 16),
                ],

                // Rent section
                if (rentProviders.isNotEmpty) ...[
                  _buildProviderSection(
                    context,
                    '💰 Rent',
                    rentProviders,
                    userBrandIds,
                    Colors.orange,
                    content.title,
                  ),
                  const SizedBox(height: 16),
                ],

                // Buy section
                if (buyProviders.isNotEmpty) ...[
                  _buildProviderSection(
                    context,
                    '🛒 Buy',
                    buyProviders,
                    userBrandIds,
                    Colors.blue,
                    content.title,
                  ),
                ],

                // No providers message
                if (content.providers.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Not available for streaming in your region',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // TMDB attribution with logo
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Powered by ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          // TMDB Logo text styled with brand colors
                          const Text(
                            'T',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D253F), // TMDB dark blue
                            ),
                          ),
                          const Text(
                            'M',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF01B4E4), // TMDB light blue
                            ),
                          ),
                          const Text(
                            'D',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF90CEA1), // TMDB light green
                            ),
                          ),
                          const Text(
                            'B',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF01B4E4), // TMDB light blue
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderSection(
    BuildContext context,
    String title,
    List<StreamingProvider> providers,
    Set<String> userBrandIds,
    Color color,
    String contentTitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providers.map((p) {
            final brandId = ProviderMapping.getBrandId(p.providerId);
            final hasSubscription = brandId != null && userBrandIds.contains(brandId);
            return _ProviderChip(
              provider: p,
              hasSubscription: hasSubscription,
              contentTitle: contentTitle,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final StreamingProvider provider;
  final bool small;
  final bool hasSubscription;
  final String? contentTitle;

  const _ProviderChip({
    required this.provider,
    this.small = false,
    this.hasSubscription = false,
    this.contentTitle,
  });

  Future<void> _openProvider(BuildContext context) async {
    final url = provider.getProviderUrl(contentTitle);
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Show a snackbar if no URL available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Open ${provider.providerName} to watch'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openProvider(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 10,
          vertical: small ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: hasSubscription ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: hasSubscription
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.logoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  provider.logoUrl,
                  width: small ? 20 : 28,
                  height: small ? 20 : 28,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.tv,
                    size: small ? 16 : 20,
                  ),
                ),
              ),
            SizedBox(width: small ? 4 : 6),
            Text(
              provider.providerName,
              style: TextStyle(
                fontSize: small ? 11 : 13,
                fontWeight: hasSubscription ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasSubscription) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: small ? 12 : 16,
                color: Colors.green,
              ),
            ],
            if (!small) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.open_in_new,
                size: 12,
                color: Colors.grey[500],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a favorite movie/TV show
class _FavoriteCard extends StatelessWidget {
  final MediaFavorite favorite;
  final VoidCallback onRemove;
  final dynamic strings;

  const _FavoriteCard({
    required this.favorite,
    required this.onRemove,
    this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final isMovie = favorite.type == MediaType.movie;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: favorite.imageUrl != null && favorite.imageUrl!.isNotEmpty
                  ? Image.network(
                      favorite.imageUrl!,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(isMovie),
                    )
                  : _buildPlaceholder(isMovie),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (favorite.subtitle != null && favorite.subtitle!.isNotEmpty) ...[
                        Text(
                          favorite.subtitle!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isMovie ? Colors.blue[100] : Colors.purple[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isMovie 
                              ? (strings?.movie ?? 'Movie') 
                              : (strings?.tvShow ?? 'TV Show'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMovie ? Colors.blue[800] : Colors.purple[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Added ${_formatDate(favorite.addedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Remove button
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: onRemove,
              tooltip: 'Remove from favorites',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isMovie) {
    return Container(
      width: 80,
      height: 120,
      color: Colors.grey[300],
      child: Icon(
        isMovie ? Icons.movie : Icons.tv,
        size: 32,
        color: Colors.grey[500],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
