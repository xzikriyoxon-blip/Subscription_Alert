import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/music_content.dart';

/// Service for searching music using Deezer API.
/// Deezer API is completely FREE and doesn't require an API key!
class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';
  // CORS proxy for web platform
  static const String _corsProxy = 'https://corsproxy.io/?';

  String _getUrl(String endpoint) {
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent('$_baseUrl$endpoint')}';
    }
    return '$_baseUrl$endpoint';
  }

  /// Search for tracks by query.
  Future<List<MusicTrack>> searchTracks(String query, {int limit = 25}) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = _getUrl('/search?q=${Uri.encodeComponent(query)}&limit=$limit');
      print('Deezer URL: $url');
      final response = await http.get(Uri.parse(url));
      print('Deezer response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List<dynamic>?;

        if (results == null) return [];

        return results
            .map((item) => MusicTrack.fromDeezer(item as Map<String, dynamic>))
            .toList();
      } else {
        print('Deezer error: ${response.body}');
      }
    } catch (e) {
      print('Deezer search error: $e');
    }
    return [];
  }

  /// Search for artists.
  Future<List<MusicArtist>> searchArtists(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = _getUrl('/search/artist?q=${Uri.encodeComponent(query)}&limit=$limit');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List<dynamic>?;

        if (results == null) return [];

        return results
            .map((item) => MusicArtist.fromDeezer(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Deezer artist search error: $e');
    }
    return [];
  }

  /// Search for albums.
  Future<List<MusicAlbum>> searchAlbums(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = _getUrl('/search/album?q=${Uri.encodeComponent(query)}&limit=$limit');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List<dynamic>?;

        if (results == null) return [];

        return results
            .map((item) => MusicAlbum.fromDeezer(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Deezer album search error: $e');
    }
    return [];
  }

  /// Get top/chart tracks.
  Future<List<MusicTrack>> getChartTracks({int limit = 20}) async {
    try {
      final url = _getUrl('/chart/0/tracks?limit=$limit');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List<dynamic>?;

        if (results == null) return [];

        return results
            .map((item) => MusicTrack.fromDeezer(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Deezer chart error: $e');
    }
    return [];
  }

  /// Get artist's top tracks.
  Future<List<MusicTrack>> getArtistTopTracks(int artistId, {int limit = 10}) async {
    try {
      final url = _getUrl('/artist/$artistId/top?limit=$limit');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['data'] as List<dynamic>?;

        if (results == null) return [];

        return results
            .map((item) => MusicTrack.fromDeezer(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Deezer artist tracks error: $e');
    }
    return [];
  }
}
