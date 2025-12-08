/// Model for subscription deals and offers.
class SubscriptionDeal {
  final String id;
  final String brandId;
  final String brandName;
  final String title;
  final String description;
  final String? discountText; // e.g., "50% OFF", "Free Trial"
  final String? originalPrice;
  final String? dealPrice;
  final String affiliateUrl;
  final String affiliateNetwork; // 'admitad' or 'impact'
  final DateTime? expiresAt;
  final String? imageUrl;
  final String? promoCode;
  final DealType dealType;
  final List<String>
      regions; // ['WW'] for worldwide, or ['US', 'UK', 'DE'] for specific

  SubscriptionDeal({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.title,
    required this.description,
    this.discountText,
    this.originalPrice,
    this.dealPrice,
    required this.affiliateUrl,
    required this.affiliateNetwork,
    this.expiresAt,
    this.imageUrl,
    this.promoCode,
    this.dealType = DealType.discount,
    this.regions = const ['WW'], // Default to worldwide
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  String get networkLabel =>
      affiliateNetwork == 'admitad' ? 'Admitad' : 'Impact';

  /// Check if deal is available in a specific region
  bool isAvailableIn(String countryCode) {
    if (regions.contains('WW')) return true; // Worldwide
    return regions.contains(countryCode.toUpperCase());
  }
}

enum DealType {
  freeTrial,
  discount,
  bundle,
  studentDiscount,
  familyPlan,
  annualSavings,
}

extension DealTypeExtension on DealType {
  String get label {
    switch (this) {
      case DealType.freeTrial:
        return '🆓 Free Trial';
      case DealType.discount:
        return '💰 Discount';
      case DealType.bundle:
        return '📦 Bundle';
      case DealType.studentDiscount:
        return '🎓 Student';
      case DealType.familyPlan:
        return '👨‍👩‍👧‍👦 Family';
      case DealType.annualSavings:
        return '📅 Annual';
    }
  }

  String get emoji {
    switch (this) {
      case DealType.freeTrial:
        return '🆓';
      case DealType.discount:
        return '💰';
      case DealType.bundle:
        return '📦';
      case DealType.studentDiscount:
        return '🎓';
      case DealType.familyPlan:
        return '👨‍👩‍👧‍👦';
      case DealType.annualSavings:
        return '📅';
    }
  }
}

/// Static deals data - In production, this would come from an API
/// Replace affiliate URLs with your actual Admitad/Impact tracking links
class DealsRepository {
  /// Get all available deals
  static List<SubscriptionDeal> getAllDeals() {
    return [
      // Streaming Deals
      SubscriptionDeal(
        id: 'netflix_1',
        brandId: 'netflix',
        brandName: 'Netflix',
        title: 'Netflix Basic with Ads',
        description: 'Start streaming for less with the ad-supported plan',
        dealPrice: '\$6.99/mo',
        affiliateUrl:
            'https://www.netflix.com/', // Replace with Admitad/Impact link
        affiliateNetwork: 'impact',
        dealType: DealType.discount,
      ),
      SubscriptionDeal(
        id: 'disney_1',
        brandId: 'disney_plus',
        brandName: 'Disney+',
        title: 'Disney+ Annual Plan',
        description: 'Save 16% with annual subscription',
        discountText: 'Save 16%',
        originalPrice: '\$95.88/yr',
        dealPrice: '\$79.99/yr',
        affiliateUrl:
            'https://www.disneyplus.com/', // Replace with Admitad/Impact link
        affiliateNetwork: 'impact',
        dealType: DealType.annualSavings,
      ),
      SubscriptionDeal(
        id: 'disney_bundle',
        brandId: 'disney_plus',
        brandName: 'Disney+ Bundle',
        title: 'Disney+, Hulu, ESPN+ Bundle',
        description: 'Get all three streaming services in one bundle',
        discountText: 'Best Value',
        dealPrice: '\$14.99/mo',
        affiliateUrl: 'https://www.disneyplus.com/bundle',
        affiliateNetwork: 'impact',
        dealType: DealType.bundle,
      ),
      SubscriptionDeal(
        id: 'hbo_1',
        brandId: 'hbo_max',
        brandName: 'Max',
        title: 'Max with Ads',
        description: 'Stream HBO originals, movies & more',
        dealPrice: '\$9.99/mo',
        affiliateUrl: 'https://www.max.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.discount,
      ),
      SubscriptionDeal(
        id: 'hulu_1',
        brandId: 'hulu',
        brandName: 'Hulu',
        title: 'Hulu Free Trial',
        description: '30-day free trial for new subscribers',
        discountText: '30 Days Free',
        affiliateUrl: 'https://www.hulu.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'hulu_student',
        brandId: 'hulu',
        brandName: 'Hulu',
        title: 'Hulu Student Discount',
        description: 'Students get Hulu for just \$1.99/month',
        discountText: '75% OFF',
        originalPrice: '\$7.99/mo',
        dealPrice: '\$1.99/mo',
        affiliateUrl: 'https://www.hulu.com/student',
        affiliateNetwork: 'impact',
        dealType: DealType.studentDiscount,
      ),
      SubscriptionDeal(
        id: 'paramount_1',
        brandId: 'paramount_plus',
        brandName: 'Paramount+',
        title: 'Paramount+ Essential',
        description: '7-day free trial available',
        discountText: '7 Days Free',
        dealPrice: '\$5.99/mo',
        affiliateUrl: 'https://www.paramountplus.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'peacock_1',
        brandId: 'peacock',
        brandName: 'Peacock',
        title: 'Peacock Premium',
        description: 'Annual plan saves you over 15%',
        discountText: 'Save 15%',
        dealPrice: '\$49.99/yr',
        affiliateUrl: 'https://www.peacocktv.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.annualSavings,
      ),
      SubscriptionDeal(
        id: 'apple_tv_1',
        brandId: 'apple_tv_plus',
        brandName: 'Apple TV+',
        title: 'Apple TV+ Free Trial',
        description: '7-day free trial for new subscribers',
        discountText: '7 Days Free',
        dealPrice: '\$9.99/mo',
        affiliateUrl: 'https://tv.apple.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'prime_1',
        brandId: 'amazon_prime',
        brandName: 'Amazon Prime',
        title: 'Prime Video Free Trial',
        description: '30-day free trial includes Prime Video + shipping',
        discountText: '30 Days Free',
        affiliateUrl: 'https://www.amazon.com/prime',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'prime_student',
        brandId: 'amazon_prime',
        brandName: 'Amazon Prime',
        title: 'Prime Student',
        description: '6 months FREE then 50% off for students',
        discountText: '6 Months Free',
        dealPrice: '\$7.49/mo after',
        affiliateUrl: 'https://www.amazon.com/primestudent',
        affiliateNetwork: 'impact',
        dealType: DealType.studentDiscount,
      ),

      // Music Deals
      SubscriptionDeal(
        id: 'spotify_1',
        brandId: 'spotify',
        brandName: 'Spotify',
        title: 'Spotify Premium',
        description: '1 month free trial for new users',
        discountText: '1 Month Free',
        dealPrice: '\$10.99/mo after',
        affiliateUrl: 'https://www.spotify.com/premium/',
        affiliateNetwork: 'admitad',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'spotify_family',
        brandId: 'spotify',
        brandName: 'Spotify',
        title: 'Spotify Premium Family',
        description: '6 accounts for the whole family',
        discountText: 'Best for Families',
        dealPrice: '\$16.99/mo',
        affiliateUrl: 'https://www.spotify.com/family/',
        affiliateNetwork: 'admitad',
        dealType: DealType.familyPlan,
      ),
      SubscriptionDeal(
        id: 'spotify_student',
        brandId: 'spotify',
        brandName: 'Spotify',
        title: 'Spotify Student',
        description: 'Premium + Hulu + SHOWTIME for students',
        discountText: '50% OFF',
        dealPrice: '\$5.99/mo',
        affiliateUrl: 'https://www.spotify.com/student/',
        affiliateNetwork: 'admitad',
        dealType: DealType.studentDiscount,
      ),
      SubscriptionDeal(
        id: 'apple_music_1',
        brandId: 'apple_music',
        brandName: 'Apple Music',
        title: 'Apple Music Free Trial',
        description: '1 month free for new subscribers',
        discountText: '1 Month Free',
        dealPrice: '\$10.99/mo after',
        affiliateUrl: 'https://music.apple.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'apple_music_family',
        brandId: 'apple_music',
        brandName: 'Apple Music',
        title: 'Apple Music Family',
        description: 'Up to 6 family members',
        discountText: 'Family Plan',
        dealPrice: '\$16.99/mo',
        affiliateUrl: 'https://music.apple.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.familyPlan,
      ),
      SubscriptionDeal(
        id: 'youtube_premium_1',
        brandId: 'youtube_premium',
        brandName: 'YouTube Premium',
        title: 'YouTube Premium Trial',
        description: '1 month free - ad-free videos & music',
        discountText: '1 Month Free',
        dealPrice: '\$13.99/mo after',
        affiliateUrl: 'https://www.youtube.com/premium',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'youtube_family',
        brandId: 'youtube_premium',
        brandName: 'YouTube Premium',
        title: 'YouTube Premium Family',
        description: 'Share with up to 5 family members',
        discountText: 'Family Plan',
        dealPrice: '\$22.99/mo',
        affiliateUrl: 'https://www.youtube.com/premium/family',
        affiliateNetwork: 'impact',
        dealType: DealType.familyPlan,
      ),

      // Other Services
      SubscriptionDeal(
        id: 'nordvpn_1',
        brandId: 'nordvpn',
        brandName: 'NordVPN',
        title: 'NordVPN 2-Year Plan',
        description: 'Best VPN deal - up to 68% off',
        discountText: '68% OFF',
        originalPrice: '\$11.99/mo',
        dealPrice: '\$3.79/mo',
        affiliateUrl: 'https://nordvpn.com/',
        affiliateNetwork: 'admitad',
        dealType: DealType.discount,
      ),
      SubscriptionDeal(
        id: 'expressvpn_1',
        brandId: 'expressvpn',
        brandName: 'ExpressVPN',
        title: 'ExpressVPN Annual Plan',
        description: '3 months free with 12-month plan',
        discountText: '3 Months Free',
        dealPrice: '\$6.67/mo',
        affiliateUrl: 'https://www.expressvpn.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.discount,
      ),
      SubscriptionDeal(
        id: 'crunchyroll_1',
        brandId: 'crunchyroll',
        brandName: 'Crunchyroll',
        title: 'Crunchyroll Premium',
        description: '14-day free trial for anime fans',
        discountText: '14 Days Free',
        dealPrice: '\$7.99/mo after',
        affiliateUrl: 'https://www.crunchyroll.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
      ),
      SubscriptionDeal(
        id: 'duolingo_1',
        brandId: 'duolingo',
        brandName: 'Duolingo',
        title: 'Duolingo Plus Annual',
        description: 'Save 60% with yearly subscription',
        discountText: '60% OFF',
        dealPrice: '\$6.99/mo',
        affiliateUrl: 'https://www.duolingo.com/plus',
        affiliateNetwork: 'impact',
        dealType: DealType.annualSavings,
      ),
    ];
  }

  /// Get deals by category
  static List<SubscriptionDeal> getDealsByType(DealType type) {
    return getAllDeals().where((d) => d.dealType == type).toList();
  }

  /// Get deals for a specific brand
  static List<SubscriptionDeal> getDealsForBrand(String brandId) {
    return getAllDeals().where((d) => d.brandId == brandId).toList();
  }

  /// Get deals available in a specific region/country
  static List<SubscriptionDeal> getDealsForRegion(String countryCode) {
    return getAllDeals().where((d) => d.isAvailableIn(countryCode)).toList();
  }

  /// Get featured deals (free trials and big discounts)
  static List<SubscriptionDeal> getFeaturedDeals() {
    return getAllDeals()
        .where(
            (d) => d.dealType == DealType.freeTrial || d.discountText != null)
        .take(10)
        .toList();
  }

  /// Get student deals
  static List<SubscriptionDeal> getStudentDeals() {
    return getAllDeals()
        .where((d) => d.dealType == DealType.studentDiscount)
        .toList();
  }

  /// Get family plan deals
  static List<SubscriptionDeal> getFamilyDeals() {
    return getAllDeals()
        .where((d) => d.dealType == DealType.familyPlan)
        .toList();
  }

  /// Get region-specific deals (deals only for certain countries)
  static List<SubscriptionDeal> getRegionalDeals() {
    return [
      // US-only deals
      SubscriptionDeal(
        id: 'hulu_us',
        brandId: 'hulu',
        brandName: 'Hulu',
        title: 'Hulu Free Trial',
        description: '30-day free trial for new subscribers',
        discountText: '30 Days Free',
        affiliateUrl: 'https://www.hulu.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
        regions: ['US'],
      ),
      // UK deals
      SubscriptionDeal(
        id: 'now_tv_uk',
        brandId: 'now_tv',
        brandName: 'NOW TV',
        title: 'NOW Entertainment Pass',
        description: '7-day free trial',
        discountText: '7 Days Free',
        dealPrice: '£9.99/mo after',
        affiliateUrl: 'https://www.nowtv.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
        regions: ['GB', 'UK'],
      ),
      SubscriptionDeal(
        id: 'britbox_uk',
        brandId: 'britbox',
        brandName: 'BritBox',
        title: 'BritBox UK',
        description: '7-day free trial - Best of British TV',
        discountText: '7 Days Free',
        dealPrice: '£5.99/mo after',
        affiliateUrl: 'https://www.britbox.co.uk/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
        regions: ['GB', 'UK'],
      ),
      // Germany deals
      SubscriptionDeal(
        id: 'wow_de',
        brandId: 'wow',
        brandName: 'WOW',
        title: 'WOW Serien & Filme',
        description: 'HBO content in Germany',
        discountText: '7 Tage Gratis',
        dealPrice: '€7.99/mo',
        affiliateUrl: 'https://www.wowtv.de/',
        affiliateNetwork: 'impact',
        dealType: DealType.freeTrial,
        regions: ['DE'],
      ),
      SubscriptionDeal(
        id: 'rtl_de',
        brandId: 'rtl_plus',
        brandName: 'RTL+',
        title: 'RTL+ Premium',
        description: 'German TV streaming',
        discountText: '30 Tage Gratis',
        dealPrice: '€6.99/mo',
        affiliateUrl: 'https://plus.rtl.de/',
        affiliateNetwork: 'admitad',
        dealType: DealType.freeTrial,
        regions: ['DE', 'AT', 'CH'],
      ),
      // Russia/CIS deals
      SubscriptionDeal(
        id: 'kinopoisk_ru',
        brandId: 'kinopoisk',
        brandName: 'Кинопоиск',
        title: 'Кинопоиск HD',
        description: 'Фильмы и сериалы',
        discountText: '30 дней бесплатно',
        dealPrice: '199₽/мес',
        affiliateUrl: 'https://www.kinopoisk.ru/',
        affiliateNetwork: 'admitad',
        dealType: DealType.freeTrial,
        regions: ['RU', 'BY', 'KZ', 'UZ'],
      ),
      SubscriptionDeal(
        id: 'ivi_ru',
        brandId: 'ivi',
        brandName: 'IVI',
        title: 'IVI Подписка',
        description: 'Онлайн-кинотеатр №1',
        discountText: '14 дней бесплатно',
        dealPrice: '399₽/мес',
        affiliateUrl: 'https://www.ivi.ru/',
        affiliateNetwork: 'admitad',
        dealType: DealType.freeTrial,
        regions: ['RU', 'BY', 'KZ', 'UZ'],
      ),
      SubscriptionDeal(
        id: 'okko_ru',
        brandId: 'okko',
        brandName: 'Okko',
        title: 'Okko Оптимум',
        description: 'Сбер подписка на фильмы',
        discountText: '7 дней бесплатно',
        dealPrice: '299₽/мес',
        affiliateUrl: 'https://okko.tv/',
        affiliateNetwork: 'admitad',
        dealType: DealType.freeTrial,
        regions: ['RU', 'BY', 'KZ', 'UZ'],
      ),
      SubscriptionDeal(
        id: 'yandex_plus_ru',
        brandId: 'yandex_plus',
        brandName: 'Яндекс Плюс',
        title: 'Яндекс Плюс Мульти',
        description: 'Музыка, Кинопоиск, Лавка и другое',
        discountText: '90 дней за 1₽',
        dealPrice: '299₽/мес',
        affiliateUrl: 'https://plus.yandex.ru/',
        affiliateNetwork: 'admitad',
        dealType: DealType.discount,
        regions: ['RU', 'BY', 'KZ', 'UZ'],
      ),
      // India deals
      SubscriptionDeal(
        id: 'hotstar_in',
        brandId: 'hotstar',
        brandName: 'Disney+ Hotstar',
        title: 'Hotstar Premium',
        description: 'Disney+ content in India',
        discountText: '₹299/mo',
        dealPrice: '₹1499/yr',
        affiliateUrl: 'https://www.hotstar.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.annualSavings,
        regions: ['IN'],
      ),
      SubscriptionDeal(
        id: 'jiocinema_in',
        brandId: 'jiocinema',
        brandName: 'JioCinema',
        title: 'JioCinema Premium',
        description: 'HBO, Peacock content in India',
        discountText: 'Free with Jio',
        dealPrice: '₹29/mo',
        affiliateUrl: 'https://www.jiocinema.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.discount,
        regions: ['IN'],
      ),
      // Worldwide VPN deals (available everywhere)
      SubscriptionDeal(
        id: 'nordvpn_ww',
        brandId: 'nordvpn',
        brandName: 'NordVPN',
        title: 'NordVPN 2-Year Plan',
        description: 'Best VPN deal - up to 68% off worldwide',
        discountText: '68% OFF',
        originalPrice: '\$11.99/mo',
        dealPrice: '\$3.79/mo',
        affiliateUrl: 'https://nordvpn.com/',
        affiliateNetwork: 'admitad',
        dealType: DealType.discount,
        regions: ['WW'],
      ),
      SubscriptionDeal(
        id: 'surfshark_ww',
        brandId: 'surfshark',
        brandName: 'Surfshark',
        title: 'Surfshark 2-Year Deal',
        description: 'Unlimited devices VPN',
        discountText: '82% OFF',
        originalPrice: '\$12.95/mo',
        dealPrice: '\$2.49/mo',
        affiliateUrl: 'https://surfshark.com/',
        affiliateNetwork: 'admitad',
        dealType: DealType.discount,
        regions: ['WW'],
      ),
      SubscriptionDeal(
        id: 'expressvpn_ww',
        brandId: 'expressvpn',
        brandName: 'ExpressVPN',
        title: 'ExpressVPN Annual Plan',
        description: '3 months free with 12-month plan',
        discountText: '3 Months Free',
        dealPrice: '\$6.67/mo',
        affiliateUrl: 'https://www.expressvpn.com/',
        affiliateNetwork: 'impact',
        dealType: DealType.discount,
        regions: ['WW'],
      ),
    ];
  }

  /// Get all deals including regional ones
  static List<SubscriptionDeal> getAllDealsWithRegional() {
    return [...getAllDeals(), ...getRegionalDeals()];
  }

  /// Get deals filtered by region
  static List<SubscriptionDeal> getDealsForCountry(String countryCode) {
    return getAllDealsWithRegional()
        .where((d) => d.isAvailableIn(countryCode))
        .toList();
  }
}
