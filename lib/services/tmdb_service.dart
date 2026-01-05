import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/streaming_content.dart';

/// Service for searching movies/TV shows and finding streaming providers.
/// Uses TMDB API (free tier).
/// 
/// To get your own API key:
/// 1. Go to https://www.themoviedb.org/signup
/// 2. Create a free account
/// 3. Go to Settings > API > Create > Developer
/// 4. Copy the API Key (v3 auth) and paste it below
class TMDBService {
  // TMDB API v3 key
  static const String _apiKey = '2f6deda68c7401889c7f18721c8bb136';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  
  // Check if API key is configured
  static bool get isConfigured => _apiKey != 'YOUR_API_KEY_HERE' && _apiKey.isNotEmpty;
  
  // Default region for streaming availability
  String _region = 'US';
  
  void setRegion(String region) {
    _region = region;
  }

  /// Search for movies and TV shows.
  Future<List<StreamingContent>> search(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final url = '$_baseUrl/search/multi?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&include_adult=false';
      print('TMDB Search URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('TMDB Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        
        print('TMDB Results count: ${results.length}');
        
        return results
            .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .map((item) => StreamingContent.fromTMDB(item))
            .toList();
      } else {
        print('TMDB Error response: ${response.body}');
      }
    } catch (e) {
      print('TMDB search error: $e');
    }
    return [];
  }

  /// Get streaming providers for a specific movie or TV show.
  /// Tries user's region first, then falls back to US, GB, DE for global availability.
  Future<List<StreamingProvider>> getProviders(int id, String mediaType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$mediaType/$id/watch/providers?api_key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as Map<String, dynamic>?;
        
        if (results == null || results.isEmpty) {
          return [];
        }
        
        // Try regions in order of preference
        final regionsToTry = [_region, 'US', 'GB', 'DE', 'FR', 'CA'];
        for (final region in regionsToTry) {
          if (results.containsKey(region)) {
            return _parseProviders(results[region] as Map<String, dynamic>);
          }
        }
        
        // If none of preferred regions, try any available region
        if (results.isNotEmpty) {
          final firstRegion = results.keys.first;
          return _parseProviders(results[firstRegion] as Map<String, dynamic>);
        }
        
        return [];
      }
    } catch (e) {
      print('TMDB providers error: $e');
    }
    return [];
  }

  List<StreamingProvider> _parseProviders(Map<String, dynamic> regionData) {
    final List<StreamingProvider> providers = [];
    
    // Streaming subscriptions (most important)
    if (regionData['flatrate'] != null) {
      for (final p in regionData['flatrate'] as List<dynamic>) {
        providers.add(StreamingProvider.fromTMDB(p, 'flatrate'));
      }
    }
    
    // Rent options
    if (regionData['rent'] != null) {
      for (final p in regionData['rent'] as List<dynamic>) {
        providers.add(StreamingProvider.fromTMDB(p, 'rent'));
      }
    }
    
    // Buy options
    if (regionData['buy'] != null) {
      for (final p in regionData['buy'] as List<dynamic>) {
        providers.add(StreamingProvider.fromTMDB(p, 'buy'));
      }
    }
    
    return providers;
  }

  /// Search and get providers in one call.
  Future<List<StreamingContent>> searchWithProviders(String query) async {
    final contents = await search(query);
    
    // Get providers for first 10 results to avoid too many API calls
    final withProviders = <StreamingContent>[];
    for (var i = 0; i < contents.length && i < 10; i++) {
      final content = contents[i];
      final providers = await getProviders(content.id, content.mediaType);
      withProviders.add(content.copyWith(providers: providers));
    }
    
    return withProviders;
  }

  /// Get trending movies and TV shows.
  Future<List<StreamingContent>> getTrending() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/all/week?api_key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>;
        
        return results
            .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
            .take(20)
            .map((item) => StreamingContent.fromTMDB(item))
            .toList();
      }
    } catch (e) {
      print('TMDB trending error: $e');
    }
    return [];
  }

  /// Get content details by ID with providers.
  Future<StreamingContent?> getContentWithProviders(int id, String mediaType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$mediaType/$id?api_key=$_apiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Add media_type since the detail endpoint doesn't include it
        data['media_type'] = mediaType;
        final content = StreamingContent.fromTMDB(data);
        final providers = await getProviders(id, mediaType);
        return content.copyWith(providers: providers);
      }
    } catch (e) {
      print('TMDB get content error: $e');
    }
    return null;
  }
}
