import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

@immutable
class BrandIconSpec {
  final IconData icon;
  final Color color;

  const BrandIconSpec({
    required this.icon,
    required this.color,
  });
}

/// Maps known subscription brand ids/names to offline vector icons.
///
/// This avoids relying on network-hosted logos (Clearbit/TMDB) that can fail
/// due to connectivity, rate limiting, or missing domains.
class BrandIconRegistry {
  static BrandIconSpec? forBrand({String? brandId, String? brandName}) {
    final normalizedId = _normalize(brandId);
    if (normalizedId != null) {
      final hit = _icons[normalizedId] ?? _aliases[normalizedId];
      if (hit != null) return hit;
    }

    final normalizedName = _normalize(brandName);
    if (normalizedName != null) {
      final hit = _icons[normalizedName] ?? _aliases[normalizedName];
      if (hit != null) return hit;
    }

    return null;
  }

  static String? _normalize(String? s) {
    if (s == null) return null;
    final trimmed = s.trim();
    if (trimmed.isEmpty) return null;
    return trimmed
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll('+', 'plus')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Core mappings for the most common services.
  // Add more entries here as needed.
  static const Map<String, BrandIconSpec> _icons = {
    'netflix': BrandIconSpec(icon: SimpleIcons.netflix, color: SimpleIconColors.netflix),
    'youtube': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
    'youtube_premium': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
    'youtube_music': BrandIconSpec(icon: SimpleIcons.youtubemusic, color: SimpleIconColors.youtubemusic),
    'spotify': BrandIconSpec(icon: SimpleIcons.spotify, color: SimpleIconColors.spotify),
    // simple_icons v14.6.1 does not include a dedicated Disney+/Hulu/Peacock icon.
    // Those brands will fall back to network logos (Clearbit) or letter avatars.

    // HBO Max rebranded to “Max”. The package includes `max`, so map to that.
    'hbo_max': BrandIconSpec(icon: SimpleIcons.max, color: SimpleIconColors.max),
    'paramount_plus': BrandIconSpec(icon: SimpleIcons.paramountplus, color: SimpleIconColors.paramountplus),
    'apple_tv': BrandIconSpec(icon: SimpleIcons.appletv, color: SimpleIconColors.appletv),
    'amazon_prime': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'twitch': BrandIconSpec(icon: SimpleIcons.twitch, color: SimpleIconColors.twitch),
    'crunchyroll': BrandIconSpec(icon: SimpleIcons.crunchyroll, color: SimpleIconColors.crunchyroll),
  };

  // Aliases for alternative ids/names.
  static const Map<String, BrandIconSpec> _aliases = {
    'amazon_prime_video': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'prime_video': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'apple_tv_plus': BrandIconSpec(icon: SimpleIcons.appletv, color: SimpleIconColors.appletv),
    'hbomax': BrandIconSpec(icon: SimpleIcons.max, color: SimpleIconColors.max),
    'paramountplus': BrandIconSpec(icon: SimpleIcons.paramountplus, color: SimpleIconColors.paramountplus),
    'youtube_premium': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
  };
}
