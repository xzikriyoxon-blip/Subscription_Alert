/// Model for music content (songs/tracks).
class MusicTrack {
  final int id;
  final String title;
  final String artistName;
  final String albumName;
  final String? albumCover;
  final String? previewUrl;
  final int duration; // in seconds
  final bool explicit;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumName,
    this.albumCover,
    this.previewUrl,
    this.duration = 0,
    this.explicit = false,
  });

  factory MusicTrack.fromDeezer(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] as int,
      title: json['title'] ?? '',
      artistName: json['artist']?['name'] ?? '',
      albumName: json['album']?['title'] ?? '',
      albumCover: json['album']?['cover_medium'] ?? json['album']?['cover'],
      previewUrl: json['preview'] as String?,
      duration: json['duration'] as int? ?? 0,
      explicit: json['explicit_lyrics'] == true,
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get albumCoverUrl => albumCover ?? '';
}

/// Model for artist.
class MusicArtist {
  final int id;
  final String name;
  final String? picture;
  final int? nbFans;

  MusicArtist({
    required this.id,
    required this.name,
    this.picture,
    this.nbFans,
  });

  factory MusicArtist.fromDeezer(Map<String, dynamic> json) {
    return MusicArtist(
      id: json['id'] as int,
      name: json['name'] ?? '',
      picture: json['picture_medium'] ?? json['picture'],
      nbFans: json['nb_fan'] as int?,
    );
  }

  String get pictureUrl => picture ?? '';
  
  String get fansFormatted {
    if (nbFans == null) return '';
    if (nbFans! >= 1000000) {
      return '${(nbFans! / 1000000).toStringAsFixed(1)}M fans';
    } else if (nbFans! >= 1000) {
      return '${(nbFans! / 1000).toStringAsFixed(1)}K fans';
    }
    return '$nbFans fans';
  }
}

/// Model for album.
class MusicAlbum {
  final int id;
  final String title;
  final String artistName;
  final String? cover;
  final int? nbTracks;
  final String? releaseDate;

  MusicAlbum({
    required this.id,
    required this.title,
    required this.artistName,
    this.cover,
    this.nbTracks,
    this.releaseDate,
  });

  factory MusicAlbum.fromDeezer(Map<String, dynamic> json) {
    return MusicAlbum(
      id: json['id'] as int,
      title: json['title'] ?? '',
      artistName: json['artist']?['name'] ?? '',
      cover: json['cover_medium'] ?? json['cover'],
      nbTracks: json['nb_tracks'] as int?,
      releaseDate: json['release_date'] as String?,
    );
  }

  String get coverUrl => cover ?? '';
  
  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }
}

/// Music streaming platforms where songs can be found.
class MusicPlatform {
  final String id;
  final String name;
  final String? logoUrl;
  final String? searchUrl; // URL to search on this platform

  MusicPlatform({
    required this.id,
    required this.name,
    this.logoUrl,
    this.searchUrl,
  });

  static List<MusicPlatform> getAvailablePlatforms(String trackTitle, String artistName) {
    final query = Uri.encodeComponent('$trackTitle $artistName');
    return [
      MusicPlatform(
        id: 'spotify',
        name: 'Spotify',
        searchUrl: 'https://open.spotify.com/search/$query',
      ),
      MusicPlatform(
        id: 'apple_music',
        name: 'Apple Music',
        searchUrl: 'https://music.apple.com/search?term=$query',
      ),
      MusicPlatform(
        id: 'youtube_music',
        name: 'YouTube Music',
        searchUrl: 'https://music.youtube.com/search?q=$query',
      ),
      MusicPlatform(
        id: 'amazon_music',
        name: 'Amazon Music',
        searchUrl: 'https://music.amazon.com/search/$query',
      ),
      MusicPlatform(
        id: 'deezer',
        name: 'Deezer',
        searchUrl: 'https://www.deezer.com/search/$query',
      ),
      MusicPlatform(
        id: 'tidal',
        name: 'Tidal',
        searchUrl: 'https://tidal.com/search?q=$query',
      ),
      MusicPlatform(
        id: 'soundcloud',
        name: 'SoundCloud',
        searchUrl: 'https://soundcloud.com/search?q=$query',
      ),
    ];
  }

  /// Map platform ID to subscription brand ID
  static String? getBrandId(String platformId) {
    const mapping = {
      'spotify': 'spotify',
      'apple_music': 'apple_music',
      'youtube_music': 'youtube_premium',
      'amazon_music': 'amazon_music',
      'deezer': 'deezer',
      'tidal': 'tidal',
      'soundcloud': 'soundcloud',
    };
    return mapping[platformId];
  }
}
