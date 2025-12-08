/// Mapping between subscription service names/brandIds and their Android package names.
/// 
/// Used to match system app usage data with user's subscriptions.
class AppPackageMapping {
  /// Maps brandId or service name (lowercase) to Android package name(s)
  static const Map<String, List<String>> serviceToPackages = {
    // Streaming Video Services
    'netflix': ['com.netflix.mediaclient'],
    'disney_plus': ['com.disney.disneyplus', 'com.disney.plus'],
    'disney+': ['com.disney.disneyplus', 'com.disney.plus'],
    'hbo_max': ['com.hbo.hbonow', 'com.warnermedia.hbomax', 'com.hbo.max'],
    'hbo': ['com.hbo.hbonow', 'com.warnermedia.hbomax', 'com.hbo.max'],
    'max': ['com.warnermedia.hbomax', 'com.hbo.max'],
    'amazon_prime_video': ['com.amazon.avod.thirdpartyclient', 'com.amazon.avod'],
    'prime_video': ['com.amazon.avod.thirdpartyclient', 'com.amazon.avod'],
    'amazon_prime': ['com.amazon.avod.thirdpartyclient', 'com.amazon.avod'],
    'hulu': ['com.hulu.plus', 'com.hulu.livingroomplus'],
    'paramount_plus': ['com.cbs.ott', 'com.paramount.plus'],
    'paramount+': ['com.cbs.ott', 'com.paramount.plus'],
    'peacock': ['com.peacocktv.peacockandroid'],
    'apple_tv_plus': ['com.apple.atve.androidtv.appletv', 'com.apple.atve.sony.appletv'],
    'apple_tv+': ['com.apple.atve.androidtv.appletv', 'com.apple.atve.sony.appletv'],
    'crunchyroll': ['com.crunchyroll.crunchyroid', 'com.ellation.crunchyroll'],
    'funimation': ['com.funimation.funimationapp'],
    'mubi': ['com.mubi'],
    'criterion_channel': ['com.criterionchannel'],
    'curiosity_stream': ['com.curiositystream.curiositystream'],
    'discovery_plus': ['com.discovery.discoveryplus', 'com.discoveryplus.mobile'],
    'tubi': ['com.tubitv'],
    'pluto_tv': ['tv.pluto.android'],
    'youtube_premium': ['com.google.android.youtube'],
    'youtube': ['com.google.android.youtube'],
    'viki': ['com.viki.android'],
    'hotstar': ['in.startv.hotstar', 'com.hotstar.android'],
    'shahid': ['com.mbc.shahid'],
    
    // Music Streaming Services
    'spotify': ['com.spotify.music'],
    'apple_music': ['com.apple.android.music'],
    'youtube_music': ['com.google.android.apps.youtube.music'],
    'amazon_music': ['com.amazon.mp3'],
    'tidal': ['com.aspiro.tidal'],
    'deezer': ['deezer.android.app'],
    'pandora': ['com.pandora.android'],
    'soundcloud': ['com.soundcloud.android'],
    'audible': ['com.audible.application'],
    'anghami': ['com.anghami'],
    
    // Gaming Services
    'xbox_game_pass': ['com.gamepass', 'com.microsoft.xboxone.smartglass'],
    'playstation_plus': ['com.scee.psxandroid', 'com.playstation.mobile2ndscreen'],
    'ea_play': ['com.ea.gp.fifamobile', 'com.ea.gp.fifaultimate'],
    'nintendo_online': ['com.nintendo.znca'],
    'geforce_now': ['com.nvidia.geforcenow'],
    'xbox_cloud': ['com.gamepass'],
    'stadia': ['com.google.stadia.android'],
    'twitch': ['tv.twitch.android.app'],
    'steam': ['com.valvesoftware.android.steam.community'],
    'epic_games': ['com.epicgames.portal'],
    
    // Cloud Storage Services
    'dropbox': ['com.dropbox.android'],
    'google_drive': ['com.google.android.apps.docs'],
    'google_one': ['com.google.android.apps.subscriptions.red'],
    'icloud': [], // iOS only
    'onedrive': ['com.microsoft.skydrive'],
    'box': ['com.box.android'],
    'mega': ['mega.privacy.android.app'],
    
    // Productivity & Office
    'microsoft_365': ['com.microsoft.office.word', 'com.microsoft.office.excel', 'com.microsoft.office.powerpoint', 'com.microsoft.teams'],
    'office_365': ['com.microsoft.office.word', 'com.microsoft.office.excel', 'com.microsoft.office.powerpoint'],
    'notion': ['notion.id'],
    'evernote': ['com.evernote'],
    'todoist': ['com.todoist'],
    'slack': ['com.Slack'],
    'trello': ['com.trello'],
    'asana': ['com.asana.app'],
    'monday': ['com.monday.monday'],
    'linear': ['com.linear'],
    'figma': ['com.figma.mirror'],
    'canva': ['com.canva.editor'],
    'adobe_creative_cloud': ['com.adobe.cc.android', 'com.adobe.lrmobile', 'com.adobe.psmobile'],
    'adobe': ['com.adobe.cc.android', 'com.adobe.lrmobile', 'com.adobe.psmobile'],
    
    // VPN Services
    'nordvpn': ['com.nordvpn.android'],
    'expressvpn': ['com.expressvpn.vpn'],
    'surfshark': ['com.surfshark.vpnclient.android'],
    'proton_vpn': ['ch.protonvpn.android'],
    'cyberghost': ['de.mobileconcepts.cyberghost'],
    'private_internet_access': ['com.privateinternetaccess.android'],
    'ipvanish': ['com.ixonn.ipvanish'],
    'mullvad': ['net.mullvad.mullvadvpn'],
    
    // News & Reading
    'nytimes': ['com.nytimes.android'],
    'new_york_times': ['com.nytimes.android'],
    'washington_post': ['com.washingtonpost.android'],
    'wall_street_journal': ['wsj.reader_sp'],
    'economist': ['com.economist.launchpad'],
    'medium': ['com.medium.reader'],
    'scribd': ['com.scribd.app.reader0'],
    'kindle_unlimited': ['com.amazon.kindle'],
    'pocket': ['com.ideashower.readitlater.pro'],
    'blinkist': ['com.blinkslabs.blinkist.android'],
    
    // Fitness & Health
    'peloton': ['com.onepeloton.callisto'],
    'fitbit_premium': ['com.fitbit.FitbitMobile'],
    'strava': ['com.strava'],
    'myfitnesspal': ['com.myfitnesspal.android'],
    'headspace': ['com.getsomeheadspace.android'],
    'calm': ['com.calm.android'],
    'noom': ['com.wsl.noom'],
    'nike_training': ['com.nike.ntc'],
    'apple_fitness': [], // iOS only
    
    // Dating Apps
    'tinder': ['com.tinder'],
    'bumble': ['com.bumble.app'],
    'hinge': ['co.hinge.app'],
    'match': ['com.match.android.matchmobile'],
    'okcupid': ['com.okcupid.okcupid'],
    
    // Social Media (Premium Features)
    'twitter_blue': ['com.twitter.android'],
    'x_premium': ['com.twitter.android'],
    'linkedin_premium': ['com.linkedin.android'],
    'discord_nitro': ['com.discord'],
    'telegram_premium': ['org.telegram.messenger'],
    'snapchat_plus': ['com.snapchat.android'],
    'tiktok': ['com.zhiliaoapp.musically', 'com.ss.android.ugc.trill'],
    'reddit_premium': ['com.reddit.frontpage'],
    'instagram': ['com.instagram.android'],
    'facebook': ['com.facebook.katana'],
    'whatsapp': ['com.whatsapp'],
    
    // Education
    'duolingo': ['com.duolingo'],
    'coursera': ['org.coursera.app'],
    'skillshare': ['com.skillshare.Skillshare'],
    'masterclass': ['com.masterclass.app'],
    'udemy': ['com.udemy.android'],
    'brilliant': ['org.brilliant.android'],
    'babbel': ['com.babbel.mobile.android.en'],
    'rosetta_stone': ['air.com.rosettastone.mobile.CoursePlayer'],
    
    // Food & Delivery
    'doordash_dashpass': ['com.dd.dasher'],
    'uber_eats': ['com.ubercab.eats'],
    'uber_one': ['com.ubercab', 'com.ubercab.eats'],
    'grubhub': ['com.grubhub.android'],
    'instacart': ['com.instacart.client'],
    
    // Other Services
    'amazon_prime_membership': ['com.amazon.mShop.android.shopping'],
    'costco': ['com.costco.app.android'],
    '1password': ['com.1password.android'],
    'lastpass': ['com.lastpass.lpandroid'],
    'bitwarden': ['com.x8bit.bitwarden'],
    'dashlane': ['com.dashlane'],
  };

  /// Reverse mapping: package name to service/brand IDs
  static Map<String, List<String>>? _packageToServices;
  
  static Map<String, List<String>> get packageToServices {
    if (_packageToServices == null) {
      _packageToServices = {};
      serviceToPackages.forEach((service, packages) {
        for (final package in packages) {
          _packageToServices![package] ??= [];
          if (!_packageToServices![package]!.contains(service)) {
            _packageToServices![package]!.add(service);
          }
        }
      });
    }
    return _packageToServices!;
  }

  /// Get package names for a service/brand
  static List<String> getPackagesForService(String serviceOrBrandId) {
    final key = serviceOrBrandId.toLowerCase().replaceAll(' ', '_').replaceAll('+', '_plus');
    return serviceToPackages[key] ?? [];
  }

  /// Get service names for a package
  static List<String> getServicesForPackage(String packageName) {
    return packageToServices[packageName] ?? [];
  }

  /// Check if a package belongs to any known subscription service
  static bool isSubscriptionApp(String packageName) {
    return packageToServices.containsKey(packageName);
  }

  /// Try to match a subscription name to packages using fuzzy matching
  static List<String> fuzzyMatchPackages(String subscriptionName) {
    final normalized = subscriptionName.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('+', '_plus')
        .replaceAll('-', '_');
    
    // First try exact match
    if (serviceToPackages.containsKey(normalized)) {
      return serviceToPackages[normalized]!;
    }

    // Try partial matching
    final matches = <String>[];
    for (final entry in serviceToPackages.entries) {
      if (entry.key.contains(normalized) || normalized.contains(entry.key)) {
        matches.addAll(entry.value);
      }
    }

    return matches.toSet().toList(); // Remove duplicates
  }

  /// Get app category for a package
  static String getCategoryForPackage(String packageName) {
    final services = getServicesForPackage(packageName);
    if (services.isEmpty) return 'Other';

    final service = services.first;
    
    // Video streaming
    if (['netflix', 'disney_plus', 'hbo_max', 'max', 'hulu', 'amazon_prime_video', 
         'paramount_plus', 'peacock', 'apple_tv_plus', 'crunchyroll', 'youtube_premium',
         'mubi', 'tubi', 'pluto_tv', 'hotstar'].contains(service)) {
      return 'Video Streaming';
    }
    
    // Music
    if (['spotify', 'apple_music', 'youtube_music', 'amazon_music', 'tidal',
         'deezer', 'pandora', 'soundcloud', 'audible', 'anghami'].contains(service)) {
      return 'Music & Audio';
    }
    
    // Gaming
    if (['xbox_game_pass', 'playstation_plus', 'ea_play', 'nintendo_online',
         'geforce_now', 'twitch', 'steam'].contains(service)) {
      return 'Gaming';
    }
    
    // Productivity
    if (['microsoft_365', 'notion', 'slack', 'adobe_creative_cloud', 
         'figma', 'canva', 'todoist'].contains(service)) {
      return 'Productivity';
    }
    
    // VPN
    if (['nordvpn', 'expressvpn', 'surfshark', 'proton_vpn'].contains(service)) {
      return 'VPN & Security';
    }
    
    // Fitness
    if (['peloton', 'fitbit_premium', 'strava', 'headspace', 'calm'].contains(service)) {
      return 'Fitness & Wellness';
    }
    
    // Social
    if (['twitter_blue', 'linkedin_premium', 'discord_nitro', 'tiktok',
         'telegram_premium', 'snapchat_plus'].contains(service)) {
      return 'Social Media';
    }
    
    // Education
    if (['duolingo', 'coursera', 'skillshare', 'masterclass', 'udemy'].contains(service)) {
      return 'Education';
    }
    
    return 'Other';
  }
}
