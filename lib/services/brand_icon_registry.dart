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
  // If a brand is not present in simple_icons, BrandLogo will still attempt
  // network fallbacks (Clearbit -> Google favicon -> DuckDuckGo) and then a
  // letter avatar.
  static const Map<String, BrandIconSpec> _icons = {
    'netflix': BrandIconSpec(icon: SimpleIcons.netflix, color: SimpleIconColors.netflix),
    'spotify': BrandIconSpec(icon: SimpleIcons.spotify, color: SimpleIconColors.spotify),

    // Google/YouTube
    'youtube': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
    'youtube_premium': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
    'youtube_music': BrandIconSpec(icon: SimpleIcons.youtubemusic, color: SimpleIconColors.youtubemusic),
    'google_one': BrandIconSpec(icon: SimpleIcons.google, color: SimpleIconColors.google),

    // Streaming
    // simple_icons v14.6.1 does not include a dedicated Disney+/Hulu/Peacock icon.
    // Those brands will fall back to network logos / favicons.

    // HBO Max rebranded to “Max”. The package includes `max`, so map to that.
    'hbo_max': BrandIconSpec(icon: SimpleIcons.max, color: SimpleIconColors.max),
    'paramount_plus': BrandIconSpec(icon: SimpleIcons.paramountplus, color: SimpleIconColors.paramountplus),
    'apple_tv': BrandIconSpec(icon: SimpleIcons.appletv, color: SimpleIconColors.appletv),
    'amazon_prime': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'twitch': BrandIconSpec(icon: SimpleIcons.twitch, color: SimpleIconColors.twitch),
    'crunchyroll': BrandIconSpec(icon: SimpleIcons.crunchyroll, color: SimpleIconColors.crunchyroll),

    // Music
    'apple_music': BrandIconSpec(icon: SimpleIcons.applemusic, color: SimpleIconColors.applemusic),
    'amazon_music': BrandIconSpec(icon: SimpleIcons.amazon, color: SimpleIconColors.amazon),
    'tidal': BrandIconSpec(icon: SimpleIcons.tidal, color: SimpleIconColors.tidal),
    'soundcloud': BrandIconSpec(icon: SimpleIcons.soundcloud, color: SimpleIconColors.soundcloud),
    'pandora': BrandIconSpec(icon: SimpleIcons.pandora, color: SimpleIconColors.pandora),

    // Gaming
    'playstation_plus': BrandIconSpec(icon: SimpleIcons.playstation, color: SimpleIconColors.playstation),
    'steam': BrandIconSpec(icon: SimpleIcons.steam, color: SimpleIconColors.steam),
    'ea_play': BrandIconSpec(icon: SimpleIcons.ea, color: SimpleIconColors.ea),
    'ubisoft_plus': BrandIconSpec(icon: SimpleIcons.ubisoft, color: SimpleIconColors.ubisoft),
    'geforce_now': BrandIconSpec(icon: SimpleIcons.nvidia, color: SimpleIconColors.nvidia),

    // Productivity
    'notion': BrandIconSpec(icon: SimpleIcons.notion, color: SimpleIconColors.notion),
    'slack': BrandIconSpec(icon: SimpleIcons.slack, color: SimpleIconColors.slack),
    'zoom': BrandIconSpec(icon: SimpleIcons.zoom, color: SimpleIconColors.zoom),
    'canva': BrandIconSpec(icon: SimpleIcons.canva, color: SimpleIconColors.canva),
    'figma': BrandIconSpec(icon: SimpleIcons.figma, color: SimpleIconColors.figma),
    'grammarly': BrandIconSpec(icon: SimpleIcons.grammarly, color: SimpleIconColors.grammarly),
    'evernote': BrandIconSpec(icon: SimpleIcons.evernote, color: SimpleIconColors.evernote),
    'trello': BrandIconSpec(icon: SimpleIcons.trello, color: SimpleIconColors.trello),
    'asana': BrandIconSpec(icon: SimpleIcons.asana, color: SimpleIconColors.asana),

    // Cloud
    'dropbox': BrandIconSpec(icon: SimpleIcons.dropbox, color: SimpleIconColors.dropbox),
    'icloud': BrandIconSpec(icon: SimpleIcons.icloud, color: SimpleIconColors.icloud),

    // Fitness
    'peloton': BrandIconSpec(icon: SimpleIcons.peloton, color: SimpleIconColors.peloton),
    'strava': BrandIconSpec(icon: SimpleIcons.strava, color: SimpleIconColors.strava),
    'headspace': BrandIconSpec(icon: SimpleIcons.headspace, color: SimpleIconColors.headspace),
    'fitbit_premium': BrandIconSpec(icon: SimpleIcons.fitbit, color: SimpleIconColors.fitbit),

    // News
    'medium': BrandIconSpec(icon: SimpleIcons.medium, color: SimpleIconColors.medium),
    'substack': BrandIconSpec(icon: SimpleIcons.substack, color: SimpleIconColors.substack),
    'apple_news': BrandIconSpec(icon: SimpleIcons.applenews, color: SimpleIconColors.applenews),

    // Education
    'coursera': BrandIconSpec(icon: SimpleIcons.coursera, color: SimpleIconColors.coursera),
    'udemy': BrandIconSpec(icon: SimpleIcons.udemy, color: SimpleIconColors.udemy),
    'skillshare': BrandIconSpec(icon: SimpleIcons.skillshare, color: SimpleIconColors.skillshare),
    'duolingo': BrandIconSpec(icon: SimpleIcons.duolingo, color: SimpleIconColors.duolingo),

    // Social
    'snapchat_plus': BrandIconSpec(icon: SimpleIcons.snapchat, color: SimpleIconColors.snapchat),
    'discord_nitro': BrandIconSpec(icon: SimpleIcons.discord, color: SimpleIconColors.discord),
    'telegram_premium': BrandIconSpec(icon: SimpleIcons.telegram, color: SimpleIconColors.telegram),
    'reddit_premium': BrandIconSpec(icon: SimpleIcons.reddit, color: SimpleIconColors.reddit),
    'twitter_blue': BrandIconSpec(icon: SimpleIcons.x, color: SimpleIconColors.x),

    // VPN & Security
    'nordvpn': BrandIconSpec(icon: SimpleIcons.nordvpn, color: SimpleIconColors.nordvpn),
    'expressvpn': BrandIconSpec(icon: SimpleIcons.expressvpn, color: SimpleIconColors.expressvpn),
    'surfshark': BrandIconSpec(icon: SimpleIcons.surfshark, color: SimpleIconColors.surfshark),
    '1password': BrandIconSpec(icon: SimpleIcons.n1password, color: SimpleIconColors.n1password),
    'lastpass': BrandIconSpec(icon: SimpleIcons.lastpass, color: SimpleIconColors.lastpass),
    'bitwarden': BrandIconSpec(icon: SimpleIcons.bitwarden, color: SimpleIconColors.bitwarden),
    'norton': BrandIconSpec(icon: SimpleIcons.norton, color: SimpleIconColors.norton),
    'mcafee': BrandIconSpec(icon: SimpleIcons.mcafee, color: SimpleIconColors.mcafee),

    // Food Delivery
    'doordash': BrandIconSpec(icon: SimpleIcons.doordash, color: SimpleIconColors.doordash),
    'uber_eats': BrandIconSpec(icon: SimpleIcons.ubereats, color: SimpleIconColors.ubereats),
    'grubhub': BrandIconSpec(icon: SimpleIcons.grubhub, color: SimpleIconColors.grubhub),
    'instacart': BrandIconSpec(icon: SimpleIcons.instacart, color: SimpleIconColors.instacart),
    'hellofresh': BrandIconSpec(icon: SimpleIcons.hellofresh, color: SimpleIconColors.hellofresh),

    // Shopping
    'walmart_plus': BrandIconSpec(icon: SimpleIcons.walmart, color: SimpleIconColors.walmart),
    'ebay_plus': BrandIconSpec(icon: SimpleIcons.ebay, color: SimpleIconColors.ebay),

    // Finance
    'quickbooks': BrandIconSpec(icon: SimpleIcons.quickbooks, color: SimpleIconColors.quickbooks),
    'robinhood_gold': BrandIconSpec(icon: SimpleIcons.robinhood, color: SimpleIconColors.robinhood),

    // AI
    'chatgpt': BrandIconSpec(icon: SimpleIcons.openai, color: SimpleIconColors.openai),
    'claude': BrandIconSpec(icon: SimpleIcons.anthropic, color: SimpleIconColors.anthropic),

    // Dev
    'github_copilot': BrandIconSpec(icon: SimpleIcons.github, color: SimpleIconColors.github),
  };

  // Aliases for alternative ids/names.
  static const Map<String, BrandIconSpec> _aliases = {
    'amazon_prime_video': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'prime_video': BrandIconSpec(icon: SimpleIcons.primevideo, color: SimpleIconColors.primevideo),
    'apple_tv_plus': BrandIconSpec(icon: SimpleIcons.appletv, color: SimpleIconColors.appletv),
    'hbomax': BrandIconSpec(icon: SimpleIcons.max, color: SimpleIconColors.max),
    'paramountplus': BrandIconSpec(icon: SimpleIcons.paramountplus, color: SimpleIconColors.paramountplus),
    'youtube_premium': BrandIconSpec(icon: SimpleIcons.youtube, color: SimpleIconColors.youtube),
    'x_premium': BrandIconSpec(icon: SimpleIcons.x, color: SimpleIconColors.x),
  };
}
