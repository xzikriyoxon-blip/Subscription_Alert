/// Model for favorite media items (movies, TV shows, songs).
/// Supports both streaming content and music tracks.

enum MediaType { movie, tv, song }

class MediaFavorite {
  final String id;
  final MediaType type;
  final String title;
  final String? subtitle; // Artist for songs, year for movies
  final String? imageUrl;
  final DateTime addedAt;
  final Map<String, dynamic>? extraData;

  const MediaFavorite({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.addedAt,
    this.extraData,
  });

  /// Create from a movie/TV show
  factory MediaFavorite.fromStreamingContent({
    required int tmdbId,
    required String title,
    required String mediaType,
    String? posterPath,
    String? year,
    double? rating,
  }) {
    return MediaFavorite(
      id: '${mediaType}_$tmdbId',
      type: mediaType == 'movie' ? MediaType.movie : MediaType.tv,
      title: title,
      subtitle: year,
      imageUrl: posterPath != null 
          ? 'https://image.tmdb.org/t/p/w342$posterPath' 
          : null,
      addedAt: DateTime.now(),
      extraData: {
        'tmdbId': tmdbId,
        'mediaType': mediaType,
        'rating': rating,
      },
    );
  }

  /// Create from a music track
  factory MediaFavorite.fromMusicTrack({
    required int trackId,
    required String title,
    required String artistName,
    required String albumName,
    String? albumCover,
    int? duration,
  }) {
    return MediaFavorite(
      id: 'song_$trackId',
      type: MediaType.song,
      title: title,
      subtitle: artistName,
      imageUrl: albumCover,
      addedAt: DateTime.now(),
      extraData: {
        'trackId': trackId,
        'artistName': artistName,
        'albumName': albumName,
        'duration': duration,
      },
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'addedAt': addedAt.toIso8601String(),
      'extraData': extraData,
    };
  }

  /// Create from JSON
  factory MediaFavorite.fromJson(Map<String, dynamic> json) {
    return MediaFavorite(
      id: json['id'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.movie,
      ),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      extraData: json['extraData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFavorite &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
