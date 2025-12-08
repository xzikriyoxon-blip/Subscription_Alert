/// Model for streaming content (movies/TV shows).
class StreamingContent {
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final String mediaType; // 'movie' or 'tv'
  final double? voteAverage;
  final String? releaseDate;
  final List<StreamingProvider> providers;

  StreamingContent({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    required this.mediaType,
    this.voteAverage,
    this.releaseDate,
    this.providers = const [],
  });

  factory StreamingContent.fromTMDB(Map<String, dynamic> json) {
    return StreamingContent(
      id: json['id'] as int,
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      mediaType: json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv'),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'],
    );
  }

  StreamingContent copyWith({List<StreamingProvider>? providers}) {
    return StreamingContent(
      id: id,
      title: title,
      posterPath: posterPath,
      overview: overview,
      mediaType: mediaType,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      providers: providers ?? this.providers,
    );
  }

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w342$posterPath'
      : '';

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }
}

/// Model for streaming provider (Netflix, Disney+, etc.).
class StreamingProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final String type; // 'flatrate', 'rent', 'buy'

  StreamingProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    required this.type,
  });

  factory StreamingProvider.fromTMDB(Map<String, dynamic> json, String type) {
    return StreamingProvider(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      logoPath: json['logo_path'] as String?,
      type: type,
    );
  }

  String get logoUrl => logoPath != null
      ? 'https://image.tmdb.org/t/p/w92$logoPath'
      : '';

  String get typeLabel {
    switch (type) {
      case 'flatrate':
        return 'Stream';
      case 'rent':
        return 'Rent';
      case 'buy':
        return 'Buy';
      default:
        return type;
    }
  }

  /// Get the URL to open this provider's platform
  String? getProviderUrl(String? contentTitle) {
    final searchQuery = contentTitle != null ? Uri.encodeComponent(contentTitle) : '';
    return ProviderMapping.getProviderUrl(providerId, searchQuery);
  }
}

/// Provider info with subscription mapping.
class ProviderMapping {
  static const Map<int, String> providerToBrandId = {
    8: 'netflix',           // Netflix
    9: 'amazon_prime',      // Amazon Prime Video
    337: 'disney_plus',     // Disney+
    384: 'hbo_max',         // HBO Max
    15: 'hulu',             // Hulu
    531: 'paramount_plus',  // Paramount+
    350: 'apple_tv_plus',   // Apple TV+
    283: 'crunchyroll',     // Crunchyroll
    387: 'peacock',         // Peacock
    1899: 'hbo_max',        // Max
    386: 'peacock',         // Peacock Premium
    526: 'amc_plus',        // AMC+
    151: 'britbox',         // BritBox
    190: 'curiosity_stream', // Curiosity Stream
    300: 'discovery_plus',  // Discovery+
    422: 'dazn',            // DAZN
    444: 'hotstar',         // Disney+ Hotstar
    119: 'amazon_prime',    // Amazon Video
    10: 'amazon_prime',     // Amazon Video
    3: 'google_play',       // Google Play Movies
    2: 'apple_tv',          // Apple TV
    192: 'youtube',         // YouTube
    188: 'youtube_premium', // YouTube Premium
    11: 'mubi',             // MUBI
  };

  /// Provider URLs for streaming platforms
  static const Map<int, String> providerUrls = {
    8: 'https://www.netflix.com/search?q=',           // Netflix
    9: 'https://www.primevideo.com/search?phrase=',   // Amazon Prime Video
    337: 'https://www.disneyplus.com/search?q=',      // Disney+
    384: 'https://www.max.com/search?q=',             // HBO Max
    1899: 'https://www.max.com/search?q=',            // Max
    15: 'https://www.hulu.com/search?q=',             // Hulu
    531: 'https://www.paramountplus.com/search/?q=',  // Paramount+
    350: 'https://tv.apple.com/search?term=',         // Apple TV+
    2: 'https://tv.apple.com/search?term=',           // Apple TV
    283: 'https://www.crunchyroll.com/search?q=',     // Crunchyroll
    387: 'https://www.peacocktv.com/search?q=',       // Peacock
    386: 'https://www.peacocktv.com/search?q=',       // Peacock Premium
    526: 'https://www.amcplus.com/search?q=',         // AMC+
    151: 'https://www.britbox.com/search?q=',         // BritBox
    300: 'https://www.discoveryplus.com/search?q=',   // Discovery+
    444: 'https://www.hotstar.com/search?q=',         // Disney+ Hotstar
    119: 'https://www.primevideo.com/search?phrase=', // Amazon Video
    10: 'https://www.primevideo.com/search?phrase=',  // Amazon Video
    3: 'https://play.google.com/store/search?q=',     // Google Play Movies
    192: 'https://www.youtube.com/results?search_query=', // YouTube
    188: 'https://www.youtube.com/results?search_query=', // YouTube Premium
    11: 'https://mubi.com/search?query=',             // MUBI
    422: 'https://www.dazn.com/search?q=',            // DAZN
    190: 'https://curiositystream.com/search?q=',     // Curiosity Stream
  };

  static String? getBrandId(int providerId) {
    return providerToBrandId[providerId];
  }

  static String? getProviderUrl(int providerId, String searchQuery) {
    final baseUrl = providerUrls[providerId];
    if (baseUrl != null) {
      return '$baseUrl$searchQuery';
    }
    return null;
  }
}
