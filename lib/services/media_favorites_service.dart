import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_favorite.dart';

/// Service for managing favorite movies, TV shows, and songs.
/// Uses local SharedPreferences for storage.
class MediaFavoritesService {
  static const String _storageKey = 'media_favorites';
  
  List<MediaFavorite> _favorites = [];
  bool _initialized = false;

  /// Initialize and load favorites from storage
  Future<void> init() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    
    if (data != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(data);
        _favorites = jsonList
            .map((json) => MediaFavorite.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _favorites = [];
      }
    }
    
    _initialized = true;
  }

  /// Save favorites to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _favorites.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Get all favorites
  List<MediaFavorite> getAll() => List.unmodifiable(_favorites);

  /// Get favorites by type
  List<MediaFavorite> getByType(MediaType type) {
    return _favorites.where((f) => f.type == type).toList();
  }

  /// Get movie favorites
  List<MediaFavorite> get movieFavorites => 
      _favorites.where((f) => f.type == MediaType.movie).toList();

  /// Get TV show favorites
  List<MediaFavorite> get tvFavorites => 
      _favorites.where((f) => f.type == MediaType.tv).toList();

  /// Get song favorites
  List<MediaFavorite> get songFavorites => 
      _favorites.where((f) => f.type == MediaType.song).toList();

  /// Get all video favorites (movies + TV shows)
  List<MediaFavorite> get videoFavorites => 
      _favorites.where((f) => f.type == MediaType.movie || f.type == MediaType.tv).toList();

  /// Check if an item is favorited
  bool isFavorite(String id) {
    return _favorites.any((f) => f.id == id);
  }

  /// Check if a movie/TV show is favorited by TMDB ID
  bool isVideoFavorite(int tmdbId, String mediaType) {
    final id = '${mediaType}_$tmdbId';
    return isFavorite(id);
  }

  /// Check if a song is favorited by track ID
  bool isSongFavorite(int trackId) {
    final id = 'song_$trackId';
    return isFavorite(id);
  }

  /// Add a favorite
  Future<void> addFavorite(MediaFavorite favorite) async {
    if (!_favorites.any((f) => f.id == favorite.id)) {
      _favorites.insert(0, favorite); // Add to beginning (most recent)
      await _save();
    }
  }

  /// Remove a favorite by ID
  Future<void> removeFavorite(String id) async {
    _favorites.removeWhere((f) => f.id == id);
    await _save();
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(MediaFavorite favorite) async {
    if (isFavorite(favorite.id)) {
      await removeFavorite(favorite.id);
      return false;
    } else {
      await addFavorite(favorite);
      return true;
    }
  }

  /// Remove a movie/TV show favorite by TMDB ID
  Future<void> removeVideoFavorite(int tmdbId, String mediaType) async {
    final id = '${mediaType}_$tmdbId';
    await removeFavorite(id);
  }

  /// Remove a song favorite by track ID
  Future<void> removeSongFavorite(int trackId) async {
    final id = 'song_$trackId';
    await removeFavorite(id);
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    _favorites.clear();
    await _save();
  }

  /// Clear favorites by type
  Future<void> clearByType(MediaType type) async {
    _favorites.removeWhere((f) => f.type == type);
    await _save();
  }

  /// Get favorite count
  int get count => _favorites.length;

  /// Get count by type
  int countByType(MediaType type) => 
      _favorites.where((f) => f.type == type).length;
}
