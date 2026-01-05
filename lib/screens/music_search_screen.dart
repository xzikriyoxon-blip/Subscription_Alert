import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/music_content.dart';
import '../models/subscription.dart';
import '../models/media_favorite.dart';
import '../services/deezer_service.dart';
import '../providers/subscription_providers.dart';
import '../providers/feature_providers.dart';
import 'settings_screen.dart';

/// Provider for Deezer service.
final deezerServiceProvider = Provider<DeezerService>((ref) => DeezerService());

/// Provider for music search results.
final musicSearchResultsProvider = StateProvider<List<MusicTrack>>((ref) => []);

/// Provider for music search loading state.
final musicSearchLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for chart tracks.
final chartTracksProvider = FutureProvider<List<MusicTrack>>((ref) async {
  final deezer = ref.read(deezerServiceProvider);
  return deezer.getChartTracks();
});

/// Screen to search for music and see streaming availability.
class MusicSearchScreen extends ConsumerStatefulWidget {
  const MusicSearchScreen({super.key});

  @override
  ConsumerState<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends ConsumerState<MusicSearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _deezer = DeezerService();
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
      ref.read(musicSearchResultsProvider.notifier).state = [];
      return;
    }

    ref.read(musicSearchLoadingProvider.notifier).state = true;

    try {
      final results = await _deezer.searchTracks(query);
      if (mounted) {
        ref.read(musicSearchResultsProvider.notifier).state = results;
      }
    } catch (e) {
      print('Music search error: $e');
    } finally {
      if (mounted) {
        ref.read(musicSearchLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final searchResults = ref.watch(musicSearchResultsProvider);
    final isLoading = ref.watch(musicSearchLoadingProvider);
    final chartAsync = ref.watch(chartTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.musicSearch),
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
                    hintText: strings.searchSongsAndArtists,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(musicSearchResultsProvider.notifier).state = [];
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
                    setState(() {});
                    if (value.length > 2) {
                      _search(value);
                    }
                  },
                ),
              ),

              // Results or Charts
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                        ? _buildChartSection(chartAsync, strings)
                        : _buildSearchResults(searchResults, strings),
              ),

              // Deezer Attribution footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by ',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0092), // Deezer pink
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Deezer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

  Widget _buildChartSection(AsyncValue<List<MusicTrack>> chartAsync, dynamic strings) {
    return chartAsync.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  strings.findYourMusic,
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
                '🔥 ${strings.topCharts}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  return _TrackCard(
                    track: tracks[index],
                    index: index + 1,
                    strings: strings,
                    onTap: () => _showTrackDetails(tracks[index]),
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
            Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              strings.findYourMusic,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<MusicTrack> results, dynamic strings) {
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
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _TrackCard(
          track: results[index],
          strings: strings,
          onTap: () => _showTrackDetails(results[index]),
        );
      },
    );
  }

  void _showTrackDetails(MusicTrack track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TrackDetailsSheet(
        track: track,
        userSubscriptions: ref.read(subscriptionsProvider),
      ),
    );
  }

  Widget _buildFavoritesTab(dynamic strings) {
    final favorites = ref.watch(songFavoritesProvider);
    
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
        return _SongFavoriteCard(
          favorite: favorite,
          strings: strings,
          onTap: () => _openFavoriteTrack(favorite),
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

  Future<void> _openFavoriteTrack(MediaFavorite favorite) async {
    // Get Deezer track ID from extraData
    final deezerId = favorite.extraData?['deezerId'] as int?;
    if (deezerId == null) return;
    
    // Open the Deezer track in browser
    final url = 'https://www.deezer.com/track/$deezerId';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open track')),
        );
      }
    }
  }
}

class _TrackCard extends ConsumerWidget {
  final MusicTrack track;
  final int? index;
  final VoidCallback onTap;
  final dynamic strings;

  const _TrackCard({
    required this.track,
    this.index,
    required this.onTap,
    this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.watch(mediaFavoritesProvider.notifier);
    final isFavorite = favoritesNotifier.isSongFavorite(track.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Chart position
              if (index != null)
                SizedBox(
                  width: 30,
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: index! <= 3 ? Colors.amber[700] : Colors.grey[600],
                    ),
                  ),
                ),

              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: track.albumCoverUrl.isNotEmpty
                    ? Image.network(
                        track.albumCoverUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (track.explicit)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'E',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.artistName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${track.albumName} • ${track.durationFormatted}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Favorite button
              GestureDetector(
                onTap: () async {
                  final result = await favoritesNotifier.toggleSongFavorite(
                    trackId: track.id,
                    title: track.title,
                    artistName: track.artistName,
                    albumName: track.albumName,
                    albumCover: track.albumCover,
                    duration: track.duration,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result ? 'Added to favorites' : 'Removed from favorites'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 24,
                  ),
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
      width: 56,
      height: 56,
      color: Colors.grey[300],
      child: Icon(Icons.music_note, color: Colors.grey[500]),
    );
  }
}

class _TrackDetailsSheet extends StatelessWidget {
  final MusicTrack track;
  final List<Subscription> userSubscriptions;

  const _TrackDetailsSheet({
    required this.track,
    required this.userSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final platforms = MusicPlatform.getAvailablePlatforms(track.title, track.artistName);

    // Check which platforms user has subscribed to
    final userBrandIds = userSubscriptions
        .where((s) => !s.isCancelled && s.brandId != null)
        .map((s) => s.brandId!)
        .toSet();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
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
                    if (track.albumCoverUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          track.albumCoverUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  track.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (track.explicit)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'EXPLICIT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artistName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.albumName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                track.durationFormatted,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Listen on section
                const Text(
                  '🎧 Listen on',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Platform buttons
                ...platforms.map((platform) {
                  final brandId = MusicPlatform.getBrandId(platform.id);
                  final hasSubscription =
                      brandId != null && userBrandIds.contains(brandId);

                  return _PlatformButton(
                    platform: platform,
                    hasSubscription: hasSubscription,
                  );
                }),

                const SizedBox(height: 20),

                // Deezer attribution
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Powered by ',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0092),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Deezer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
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
}

class _PlatformButton extends StatelessWidget {
  final MusicPlatform platform;
  final bool hasSubscription;

  const _PlatformButton({
    required this.platform,
    required this.hasSubscription,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasSubscription ? Colors.green[50] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasSubscription
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () async {
          if (platform.searchUrl != null) {
            final uri = Uri.parse(platform.searchUrl!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _getPlatformIcon(platform.id),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  platform.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        hasSubscription ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (hasSubscription) ...[
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
              ],
              Icon(Icons.open_in_new, size: 18, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPlatformIcon(String platformId) {
    IconData icon;
    Color color;

    switch (platformId) {
      case 'spotify':
        icon = Icons.music_note;
        color = const Color(0xFF1DB954); // Spotify green
        break;
      case 'apple_music':
        icon = Icons.music_note;
        color = const Color(0xFFFC3C44); // Apple Music red
        break;
      case 'youtube_music':
        icon = Icons.play_circle_filled;
        color = const Color(0xFFFF0000); // YouTube red
        break;
      case 'amazon_music':
        icon = Icons.music_note;
        color = const Color(0xFF00A8E1); // Amazon blue
        break;
      case 'deezer':
        icon = Icons.music_note;
        color = const Color(0xFFFF0092); // Deezer pink
        break;
      case 'tidal':
        icon = Icons.waves;
        color = Colors.black;
        break;
      case 'soundcloud':
        icon = Icons.cloud;
        color = const Color(0xFFFF5500); // SoundCloud orange
        break;
      default:
        icon = Icons.music_note;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

/// Card widget for displaying a favorite song
class _SongFavoriteCard extends StatelessWidget {
  final MediaFavorite favorite;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final dynamic strings;

  const _SongFavoriteCard({
    required this.favorite,
    required this.onRemove,
    this.onTap,
    this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final artistName = favorite.extraData?['artistName'] as String? ?? '';
    final albumName = favorite.extraData?['albumName'] as String? ?? '';
    final duration = favorite.extraData?['duration'] as int? ?? 0;
    
    final durationFormatted = '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: favorite.imageUrl != null && favorite.imageUrl!.isNotEmpty
                    ? Image.network(
                        favorite.imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artistName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$albumName • $durationFormatted',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Tap to open',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[400],
                          ),
                        ),
                      ],
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
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey[300],
      child: Icon(Icons.music_note, color: Colors.grey[500]),
    );
  }
}
