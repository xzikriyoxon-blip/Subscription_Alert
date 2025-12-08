import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

/// Service to detect user's country/region
class LocationService {
  static String? _cachedCountryCode;
  static String? _cachedCountryName;

  /// Get user's country code (e.g., 'US', 'GB', 'DE', 'UZ')
  static Future<String> getCountryCode() async {
    if (_cachedCountryCode != null) return _cachedCountryCode!;

    // Try IP geolocation first
    try {
      final code = await _getCountryFromIP();
      if (code != null) {
        _cachedCountryCode = code;
        return code;
      }
    } catch (e) {
      debugPrint('IP geolocation failed: $e');
    }

    // Fallback to device locale
    return _getCountryFromLocale();
  }

  /// Get user's country name
  static Future<String> getCountryName() async {
    if (_cachedCountryName != null) return _cachedCountryName!;

    try {
      final result = await _fetchIPInfo();
      if (result != null && result['country'] != null) {
        _cachedCountryName = result['country'];
        _cachedCountryCode = result['countryCode'];
        return _cachedCountryName!;
      }
    } catch (e) {
      debugPrint('Could not get country name: $e');
    }

    // Fallback
    return 'Unknown';
  }

  /// Get country code from IP address using free API
  static Future<String?> _getCountryFromIP() async {
    final result = await _fetchIPInfo();
    return result?['countryCode'];
  }

  /// Fetch IP info from ip-api.com (free, no API key needed)
  static Future<Map<String, String>?> _fetchIPInfo() async {
    try {
      String url = 'http://ip-api.com/json/?fields=status,country,countryCode';

      // Use CORS proxy for web
      if (kIsWeb) {
        url = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      }

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return {
            'country': data['country'] as String,
            'countryCode': data['countryCode'] as String,
          };
        }
      }
    } catch (e) {
      debugPrint('IP API error: $e');
    }
    return null;
  }

  /// Get country code from device locale as fallback
  static String _getCountryFromLocale() {
    try {
      // Get system locale
      final locale = ui.PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode;

      if (countryCode != null && countryCode.isNotEmpty) {
        _cachedCountryCode = countryCode;
        return countryCode;
      }
    } catch (e) {
      debugPrint('Could not get locale: $e');
    }

    // Default fallback
    return 'US';
  }

  /// Clear cached location data
  static void clearCache() {
    _cachedCountryCode = null;
    _cachedCountryName = null;
  }

  /// Get a friendly region name for display
  static String getRegionDisplayName(String countryCode) {
    final regionNames = {
      'US': '🇺🇸 United States',
      'GB': '🇬🇧 United Kingdom',
      'UK': '🇬🇧 United Kingdom',
      'DE': '🇩🇪 Germany',
      'FR': '🇫🇷 France',
      'ES': '🇪🇸 Spain',
      'IT': '🇮🇹 Italy',
      'CA': '🇨🇦 Canada',
      'AU': '🇦🇺 Australia',
      'JP': '🇯🇵 Japan',
      'KR': '🇰🇷 South Korea',
      'IN': '🇮🇳 India',
      'BR': '🇧🇷 Brazil',
      'MX': '🇲🇽 Mexico',
      'RU': '🇷🇺 Russia',
      'UZ': '🇺🇿 Uzbekistan',
      'KZ': '🇰🇿 Kazakhstan',
      'BY': '🇧🇾 Belarus',
      'UA': '🇺🇦 Ukraine',
      'PL': '🇵🇱 Poland',
      'NL': '🇳🇱 Netherlands',
      'BE': '🇧🇪 Belgium',
      'AT': '🇦🇹 Austria',
      'CH': '🇨🇭 Switzerland',
      'SE': '🇸🇪 Sweden',
      'NO': '🇳🇴 Norway',
      'DK': '🇩🇰 Denmark',
      'FI': '🇫🇮 Finland',
      'PT': '🇵🇹 Portugal',
      'IE': '🇮🇪 Ireland',
      'NZ': '🇳🇿 New Zealand',
      'SG': '🇸🇬 Singapore',
      'HK': '🇭🇰 Hong Kong',
      'TW': '🇹🇼 Taiwan',
      'TH': '🇹🇭 Thailand',
      'PH': '🇵🇭 Philippines',
      'ID': '🇮🇩 Indonesia',
      'MY': '🇲🇾 Malaysia',
      'VN': '🇻🇳 Vietnam',
      'AE': '🇦🇪 UAE',
      'SA': '🇸🇦 Saudi Arabia',
      'TR': '🇹🇷 Turkey',
      'EG': '🇪🇬 Egypt',
      'ZA': '🇿🇦 South Africa',
      'NG': '🇳🇬 Nigeria',
      'AR': '🇦🇷 Argentina',
      'CL': '🇨🇱 Chile',
      'CO': '🇨🇴 Colombia',
      'WW': '🌍 Worldwide',
    };

    return regionNames[countryCode.toUpperCase()] ?? '🌍 $countryCode';
  }

  /// Get just the flag emoji for a country code
  static String getFlag(String countryCode) {
    if (countryCode == 'WW') return '🌍';
    if (countryCode.length != 2) return '🏳️';

    // Convert country code to flag emoji
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCodes([firstLetter, secondLetter]);
  }
}

/// Helper function for debug printing
void debugPrint(String message) {
  if (kIsWeb) {
    // ignore: avoid_print
    print(message);
  }
}
