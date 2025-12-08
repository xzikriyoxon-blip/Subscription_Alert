/// Model for popular subscription brands with logos and predefined settings.
class SubscriptionBrand {
  final String id;
  final String name;
  final String category;
  final String iconUrl;
  final String? defaultPrice;
  final String? defaultCurrency;
  final String? defaultCycle;
  final String? cancelUrl;

  const SubscriptionBrand({
    required this.id,
    required this.name,
    required this.category,
    required this.iconUrl,
    this.defaultPrice,
    this.defaultCurrency,
    this.defaultCycle,
    this.cancelUrl,
  });
}

/// Categories for subscription brands.
class BrandCategory {
  static const String streaming = 'Streaming';
  static const String music = 'Music';
  static const String gaming = 'Gaming';
  static const String productivity = 'Productivity';
  static const String cloud = 'Cloud Storage';
  static const String fitness = 'Fitness';
  static const String news = 'News & Magazines';
  static const String education = 'Education';
  static const String social = 'Social Media';
  static const String vpn = 'VPN & Security';
  static const String food = 'Food Delivery';
  static const String shopping = 'Shopping';
  static const String finance = 'Finance';
  static const String other = 'Other';

  static const List<String> all = [
    streaming,
    music,
    gaming,
    productivity,
    cloud,
    fitness,
    news,
    education,
    social,
    vpn,
    food,
    shopping,
    finance,
    other,
  ];
}

/// List of popular subscription brands.
class SubscriptionBrands {
  static const List<SubscriptionBrand> all = [
    // Streaming Services
    SubscriptionBrand(
      id: 'netflix',
      name: 'Netflix',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/netflix.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/amazon.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'disney_plus',
      name: 'Disney+',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/disneyplus.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'hbo_max',
      name: 'HBO Max',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/hbomax.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'hulu',
      name: 'Hulu',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/hulu.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'apple_tv',
      name: 'Apple TV+',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/apple.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'paramount_plus',
      name: 'Paramount+',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/paramountplus.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'peacock',
      name: 'Peacock',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/peacocktv.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'crunchyroll',
      name: 'Crunchyroll',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/crunchyroll.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/youtube.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'twitch',
      name: 'Twitch',
      category: BrandCategory.streaming,
      iconUrl: 'https://logo.clearbit.com/twitch.tv',
      defaultCycle: 'monthly',
    ),

    // Music Services
    SubscriptionBrand(
      id: 'spotify',
      name: 'Spotify',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/spotify.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'apple_music',
      name: 'Apple Music',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/apple.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'youtube_music',
      name: 'YouTube Music',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/music.youtube.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'tidal',
      name: 'Tidal',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/tidal.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'deezer',
      name: 'Deezer',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/deezer.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'amazon_music',
      name: 'Amazon Music',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/amazon.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'soundcloud',
      name: 'SoundCloud Go',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/soundcloud.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'pandora',
      name: 'Pandora',
      category: BrandCategory.music,
      iconUrl: 'https://logo.clearbit.com/pandora.com',
      defaultCycle: 'monthly',
    ),

    // Gaming
    SubscriptionBrand(
      id: 'xbox_game_pass',
      name: 'Xbox Game Pass',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/xbox.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'playstation_plus',
      name: 'PlayStation Plus',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/playstation.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'nintendo_online',
      name: 'Nintendo Switch Online',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/nintendo.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'ea_play',
      name: 'EA Play',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/ea.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'ubisoft_plus',
      name: 'Ubisoft+',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/ubisoft.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'geforce_now',
      name: 'GeForce NOW',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/nvidia.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'steam',
      name: 'Steam',
      category: BrandCategory.gaming,
      iconUrl: 'https://logo.clearbit.com/steampowered.com',
      defaultCycle: 'monthly',
    ),

    // Productivity
    SubscriptionBrand(
      id: 'microsoft_365',
      name: 'Microsoft 365',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/microsoft.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'adobe_cc',
      name: 'Adobe Creative Cloud',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/adobe.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'notion',
      name: 'Notion',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/notion.so',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'slack',
      name: 'Slack',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/slack.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'zoom',
      name: 'Zoom',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/zoom.us',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'canva',
      name: 'Canva Pro',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/canva.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'figma',
      name: 'Figma',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/figma.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'grammarly',
      name: 'Grammarly',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/grammarly.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'evernote',
      name: 'Evernote',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/evernote.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'trello',
      name: 'Trello',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/trello.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'asana',
      name: 'Asana',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/asana.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'monday',
      name: 'Monday.com',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/monday.com',
      defaultCycle: 'monthly',
    ),

    // Cloud Storage
    SubscriptionBrand(
      id: 'google_one',
      name: 'Google One',
      category: BrandCategory.cloud,
      iconUrl: 'https://logo.clearbit.com/google.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'icloud',
      name: 'iCloud+',
      category: BrandCategory.cloud,
      iconUrl: 'https://logo.clearbit.com/apple.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'dropbox',
      name: 'Dropbox',
      category: BrandCategory.cloud,
      iconUrl: 'https://logo.clearbit.com/dropbox.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'onedrive',
      name: 'OneDrive',
      category: BrandCategory.cloud,
      iconUrl: 'https://logo.clearbit.com/microsoft.com',
      defaultCycle: 'monthly',
    ),

    // Fitness
    SubscriptionBrand(
      id: 'peloton',
      name: 'Peloton',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/onepeloton.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'apple_fitness',
      name: 'Apple Fitness+',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/apple.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'strava',
      name: 'Strava',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/strava.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'myfitnesspal',
      name: 'MyFitnessPal',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/myfitnesspal.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'headspace',
      name: 'Headspace',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/headspace.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'calm',
      name: 'Calm',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/calm.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'fitbit_premium',
      name: 'Fitbit Premium',
      category: BrandCategory.fitness,
      iconUrl: 'https://logo.clearbit.com/fitbit.com',
      defaultCycle: 'monthly',
    ),

    // News & Magazines
    SubscriptionBrand(
      id: 'nytimes',
      name: 'The New York Times',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/nytimes.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'wsj',
      name: 'Wall Street Journal',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/wsj.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'washington_post',
      name: 'Washington Post',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/washingtonpost.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'medium',
      name: 'Medium',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/medium.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'substack',
      name: 'Substack',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/substack.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'apple_news',
      name: 'Apple News+',
      category: BrandCategory.news,
      iconUrl: 'https://logo.clearbit.com/apple.com',
      defaultCycle: 'monthly',
    ),

    // Education
    SubscriptionBrand(
      id: 'coursera',
      name: 'Coursera Plus',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/coursera.org',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'udemy',
      name: 'Udemy',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/udemy.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'skillshare',
      name: 'Skillshare',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/skillshare.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'masterclass',
      name: 'MasterClass',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/masterclass.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'linkedin_learning',
      name: 'LinkedIn Learning',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/linkedin.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'duolingo',
      name: 'Duolingo Plus',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/duolingo.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'brilliant',
      name: 'Brilliant',
      category: BrandCategory.education,
      iconUrl: 'https://logo.clearbit.com/brilliant.org',
      defaultCycle: 'yearly',
    ),

    // Social Media
    SubscriptionBrand(
      id: 'twitter_blue',
      name: 'X Premium',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/x.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'snapchat_plus',
      name: 'Snapchat+',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/snapchat.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'discord_nitro',
      name: 'Discord Nitro',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/discord.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'telegram_premium',
      name: 'Telegram Premium',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/telegram.org',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'reddit_premium',
      name: 'Reddit Premium',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/reddit.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'linkedin_premium',
      name: 'LinkedIn Premium',
      category: BrandCategory.social,
      iconUrl: 'https://logo.clearbit.com/linkedin.com',
      defaultCycle: 'monthly',
    ),

    // VPN & Security
    SubscriptionBrand(
      id: 'nordvpn',
      name: 'NordVPN',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/nordvpn.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'expressvpn',
      name: 'ExpressVPN',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/expressvpn.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'surfshark',
      name: 'Surfshark',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/surfshark.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: '1password',
      name: '1Password',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/1password.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'lastpass',
      name: 'LastPass',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/lastpass.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'bitwarden',
      name: 'Bitwarden',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/bitwarden.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'norton',
      name: 'Norton 360',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/norton.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'mcafee',
      name: 'McAfee',
      category: BrandCategory.vpn,
      iconUrl: 'https://logo.clearbit.com/mcafee.com',
      defaultCycle: 'yearly',
    ),

    // Food Delivery
    SubscriptionBrand(
      id: 'doordash',
      name: 'DoorDash DashPass',
      category: BrandCategory.food,
      iconUrl: 'https://logo.clearbit.com/doordash.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'uber_eats',
      name: 'Uber One',
      category: BrandCategory.food,
      iconUrl: 'https://logo.clearbit.com/ubereats.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'grubhub',
      name: 'Grubhub+',
      category: BrandCategory.food,
      iconUrl: 'https://logo.clearbit.com/grubhub.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'instacart',
      name: 'Instacart+',
      category: BrandCategory.food,
      iconUrl: 'https://logo.clearbit.com/instacart.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'hellofresh',
      name: 'HelloFresh',
      category: BrandCategory.food,
      iconUrl: 'https://logo.clearbit.com/hellofresh.com',
      defaultCycle: 'monthly',
    ),

    // Shopping
    SubscriptionBrand(
      id: 'costco',
      name: 'Costco Membership',
      category: BrandCategory.shopping,
      iconUrl: 'https://logo.clearbit.com/costco.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'walmart_plus',
      name: 'Walmart+',
      category: BrandCategory.shopping,
      iconUrl: 'https://logo.clearbit.com/walmart.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'sams_club',
      name: "Sam's Club",
      category: BrandCategory.shopping,
      iconUrl: 'https://logo.clearbit.com/samsclub.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'ebay_plus',
      name: 'eBay Plus',
      category: BrandCategory.shopping,
      iconUrl: 'https://logo.clearbit.com/ebay.com',
      defaultCycle: 'yearly',
    ),

    // Finance
    SubscriptionBrand(
      id: 'ynab',
      name: 'YNAB',
      category: BrandCategory.finance,
      iconUrl: 'https://logo.clearbit.com/youneedabudget.com',
      defaultCycle: 'yearly',
    ),
    SubscriptionBrand(
      id: 'mint_premium',
      name: 'Mint Premium',
      category: BrandCategory.finance,
      iconUrl: 'https://logo.clearbit.com/mint.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'quickbooks',
      name: 'QuickBooks',
      category: BrandCategory.finance,
      iconUrl: 'https://logo.clearbit.com/quickbooks.intuit.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'robinhood_gold',
      name: 'Robinhood Gold',
      category: BrandCategory.finance,
      iconUrl: 'https://logo.clearbit.com/robinhood.com',
      defaultCycle: 'monthly',
    ),

    // AI Services
    SubscriptionBrand(
      id: 'chatgpt',
      name: 'ChatGPT Plus',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/openai.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'claude',
      name: 'Claude Pro',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/anthropic.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'midjourney',
      name: 'Midjourney',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/midjourney.com',
      defaultCycle: 'monthly',
    ),
    SubscriptionBrand(
      id: 'github_copilot',
      name: 'GitHub Copilot',
      category: BrandCategory.productivity,
      iconUrl: 'https://logo.clearbit.com/github.com',
      defaultCycle: 'monthly',
    ),
  ];

  /// Get brands filtered by category.
  static List<SubscriptionBrand> byCategory(String category) {
    return all.where((brand) => brand.category == category).toList();
  }

  /// Search brands by name.
  static List<SubscriptionBrand> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((brand) => 
      brand.name.toLowerCase().contains(lowerQuery) ||
      brand.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get a brand by ID.
  static SubscriptionBrand? getById(String id) {
    try {
      return all.firstWhere((brand) => brand.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a brand by name (fuzzy match).
  static SubscriptionBrand? getByName(String name) {
    final lowerName = name.toLowerCase();
    try {
      return all.firstWhere((brand) => 
        brand.name.toLowerCase() == lowerName ||
        brand.name.toLowerCase().contains(lowerName) ||
        lowerName.contains(brand.name.toLowerCase())
      );
    } catch (_) {
      return null;
    }
  }
}

/// Cancellation URLs for popular services.
class CancellationLinks {
  static const Map<String, String> _links = {
    // Streaming
    'netflix': 'https://www.netflix.com/cancelplan',
    'amazon_prime': 'https://www.amazon.com/gp/primecentral',
    'disney_plus': 'https://www.disneyplus.com/account/subscription',
    'hbo_max': 'https://www.max.com/account/subscription',
    'hulu': 'https://secure.hulu.com/account',
    'apple_tv': 'https://support.apple.com/en-us/HT202039',
    'paramount_plus': 'https://www.paramountplus.com/account/',
    'peacock': 'https://www.peacocktv.com/account/subscription',
    'crunchyroll': 'https://www.crunchyroll.com/account/subscription',
    'youtube_premium': 'https://www.youtube.com/paid_memberships',
    'twitch': 'https://www.twitch.tv/subscriptions',
    
    // Music
    'spotify': 'https://www.spotify.com/account/subscription/',
    'apple_music': 'https://support.apple.com/en-us/HT202039',
    'youtube_music': 'https://www.youtube.com/paid_memberships',
    'tidal': 'https://account.tidal.com/subscription',
    'deezer': 'https://www.deezer.com/account/manage-subscription',
    'amazon_music': 'https://www.amazon.com/gp/primecentral',
    'soundcloud': 'https://soundcloud.com/settings/subscription',
    'pandora': 'https://www.pandora.com/account/subscription',
    
    // Gaming
    'xbox_game_pass': 'https://account.microsoft.com/services/',
    'playstation_plus': 'https://www.playstation.com/en-us/support/store/cancel-ps-store-subscription/',
    'nintendo_online': 'https://accounts.nintendo.com/shop/subscription',
    'ea_play': 'https://myaccount.ea.com/cp-ui/subscriptions',
    'ubisoft_plus': 'https://store.ubi.com/us/ubisoftplus',
    'geforce_now': 'https://www.nvidia.com/en-us/geforce-now/',
    'steam': 'https://store.steampowered.com/account/',
    
    // Productivity
    'microsoft_365': 'https://account.microsoft.com/services/',
    'adobe_cc': 'https://account.adobe.com/plans',
    'notion': 'https://www.notion.so/my-account',
    'slack': 'https://slack.com/help/articles/218915077',
    'zoom': 'https://zoom.us/account/billing',
    'canva': 'https://www.canva.com/settings/billing',
    'figma': 'https://www.figma.com/settings/account',
    'grammarly': 'https://account.grammarly.com/subscription',
    'evernote': 'https://www.evernote.com/Settings.action',
    'trello': 'https://trello.com/your/account',
    'asana': 'https://app.asana.com/0/billing',
    'monday': 'https://monday.com/settings/account',
    
    // Cloud Storage
    'google_one': 'https://one.google.com/settings/plan',
    'icloud': 'https://support.apple.com/en-us/HT202039',
    'dropbox': 'https://www.dropbox.com/account/plan',
    'onedrive': 'https://account.microsoft.com/services/',
    
    // Fitness
    'peloton': 'https://members.onepeloton.com/settings/subscription',
    'apple_fitness': 'https://support.apple.com/en-us/HT202039',
    'strava': 'https://www.strava.com/settings/subscription',
    'myfitnesspal': 'https://www.myfitnesspal.com/account/subscriptions',
    'headspace': 'https://www.headspace.com/settings/subscription',
    'calm': 'https://www.calm.com/settings/subscription',
    'fitbit_premium': 'https://www.fitbit.com/settings/premium',
    
    // News
    'nytimes': 'https://myaccount.nytimes.com/seg/subscription',
    'wsj': 'https://customercenter.wsj.com/',
    'washington_post': 'https://www.washingtonpost.com/my-post/account/subscriptions/',
    'medium': 'https://medium.com/me/settings/membership',
    'substack': 'https://substack.com/settings/payments',
    'apple_news': 'https://support.apple.com/en-us/HT202039',
    
    // Education
    'coursera': 'https://www.coursera.org/account-settings',
    'udemy': 'https://www.udemy.com/user/edit-account/',
    'skillshare': 'https://www.skillshare.com/settings/membership',
    'masterclass': 'https://www.masterclass.com/account/billing',
    'linkedin_learning': 'https://www.linkedin.com/learning/subscription/products',
    'duolingo': 'https://www.duolingo.com/settings/account',
    'brilliant': 'https://brilliant.org/account/',
    
    // Social
    'twitter_blue': 'https://twitter.com/settings/subscriptions',
    'snapchat_plus': 'https://accounts.snapchat.com/',
    'discord_nitro': 'https://discord.com/settings/subscriptions',
    'telegram_premium': 'https://telegram.org/faq#telegram-premium',
    'reddit_premium': 'https://www.reddit.com/premium',
    'linkedin_premium': 'https://www.linkedin.com/mypreferences/d/manage-premium-subscription',
    
    // VPN & Security
    'nordvpn': 'https://my.nordaccount.com/dashboard/nordvpn/',
    'expressvpn': 'https://www.expressvpn.com/subscriptions',
    'surfshark': 'https://my.surfshark.com/subscription',
    '1password': 'https://my.1password.com/subscription',
    'lastpass': 'https://lastpass.com/support.php?cmd=cancelaccount',
    'bitwarden': 'https://vault.bitwarden.com/#/settings/subscription',
    'norton': 'https://support.norton.com/sp/en/us/home/current/solutions/v125118527',
    'mcafee': 'https://home.mcafee.com/root/myaccount.aspx',
    
    // Food Delivery
    'doordash': 'https://www.doordash.com/consumer/account/',
    'uber_eats': 'https://www.uber.com/us/en/u/uber-one/',
    'grubhub': 'https://www.grubhub.com/help/contact-us',
    'instacart': 'https://www.instacart.com/store/account/instacart_plus',
    'hellofresh': 'https://www.hellofresh.com/my-account/deliveries',
    
    // Shopping
    'costco': 'https://www.costco.com/member-service-center.html',
    'walmart_plus': 'https://www.walmart.com/account/wplus/manage',
    'sams_club': 'https://www.samsclub.com/account/membership',
    'ebay_plus': 'https://www.ebay.com/mys/subscriptions',
    
    // Finance
    'ynab': 'https://www.youneedabudget.com/app/settings/subscription',
    'mint_premium': 'https://mint.intuit.com/settings.event',
    'quickbooks': 'https://app.qbo.intuit.com/app/billing',
    'robinhood_gold': 'https://robinhood.com/account/settings',
    
    // AI
    'chatgpt': 'https://chat.openai.com/settings/subscription',
    'claude': 'https://claude.ai/settings',
    'midjourney': 'https://www.midjourney.com/account/',
    'github_copilot': 'https://github.com/settings/copilot',
  };

  /// Get cancellation URL for a brand ID.
  static String? getByBrandId(String brandId) {
    return _links[brandId];
  }

  /// Get cancellation URL by subscription name (fuzzy match).
  static String? getByName(String name) {
    final brand = SubscriptionBrands.getByName(name);
    if (brand != null) {
      return _links[brand.id];
    }
    return null;
  }

  /// Check if cancellation link is available.
  static bool hasLink(String brandIdOrName) {
    if (_links.containsKey(brandIdOrName)) return true;
    return getByName(brandIdOrName) != null;
  }

  /// General instructions for cancelling subscriptions.
  static const String appleInstructions = '''
To cancel subscriptions on iPhone/iPad:
1. Open Settings
2. Tap your name at the top
3. Tap Subscriptions
4. Tap the subscription you want to cancel
5. Tap Cancel Subscription
''';

  static const String googlePlayInstructions = '''
To cancel subscriptions on Android:
1. Open Google Play Store
2. Tap Menu → Subscriptions
3. Tap the subscription you want to cancel
4. Tap Cancel Subscription
5. Follow the instructions
''';
}
