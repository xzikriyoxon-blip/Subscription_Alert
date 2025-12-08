/// Category of subscription deal
enum DealCategory {
  streaming,
  music,
  gaming,
  cloud,
  software,
  vpn,
  education,
  fitness,
  other,
}

/// Model for location-based deals.
/// 
/// GeoDeal represents a deal that is specific to a region/country.
/// Used by the Geo Deals feature to show local offers.
class GeoDeal {
  final String id;
  final String title;
  final String description;
  final String regionCode;    // ISO country code: "UZ", "TR", "IN", "US"
  final String regionName;    // Human readable name
  final double? price;
  final String currency;
  final String serviceName;
  final DealCategory category;
  final String? url;          // Non-affiliate link
  final String? imageUrl;
  final String? discountText; // "50% OFF", "3 months free"
  final int? discountPercent; // Discount percentage (e.g., 50 for 50%)
  final DateTime? expiresAt;
  final bool isVerified;
  final String flag;          // Emoji flag: "🇺🇿", "🇹🇷", etc.

  const GeoDeal({
    required this.id,
    required this.title,
    required this.description,
    required this.regionCode,
    required this.regionName,
    this.price,
    required this.currency,
    required this.serviceName,
    required this.category,
    this.url,
    this.imageUrl,
    this.discountText,
    this.discountPercent,
    this.expiresAt,
    this.isVerified = false,
    required this.flag,
  });

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory GeoDeal.fromJson(Map<String, dynamic> json) {
    return GeoDeal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      regionCode: json['regionCode'] as String,
      regionName: json['regionName'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      currency: json['currency'] as String,
      serviceName: json['serviceName'] as String,
      category: DealCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => DealCategory.other,
      ),
      url: json['url'] as String?,
      imageUrl: json['imageUrl'] as String?,
      discountText: json['discountText'] as String?,
      discountPercent: json['discountPercent'] as int?,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      flag: json['flag'] as String? ?? '🏳️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'regionCode': regionCode,
      'regionName': regionName,
      'price': price,
      'currency': currency,
      'serviceName': serviceName,
      'category': category.name,
      'url': url,
      'imageUrl': imageUrl,
      'discountText': discountText,
      'discountPercent': discountPercent,
      'expiresAt': expiresAt?.toIso8601String(),
      'isVerified': isVerified,
      'flag': flag,
    };
  }
}

/// Supported regions for geo deals
class GeoRegions {
  static const Map<String, String> supported = {
    'UZ': 'Uzbekistan',
    'TR': 'Turkey',
    'IN': 'India',
    'AR': 'Argentina',
    'US': 'United States',
    'UK': 'United Kingdom',
    'DE': 'Germany',
    'BR': 'Brazil',
    'RU': 'Russia',
    'PK': 'Pakistan',
    'EG': 'Egypt',
    'NG': 'Nigeria',
    'PH': 'Philippines',
    'ID': 'Indonesia',
    'MX': 'Mexico',
  };

  static const Map<String, String> flags = {
    'UZ': '🇺🇿',
    'TR': '🇹🇷',
    'IN': '🇮🇳',
    'AR': '🇦🇷',
    'US': '🇺🇸',
    'UK': '🇬🇧',
    'DE': '🇩🇪',
    'BR': '🇧🇷',
    'RU': '🇷🇺',
    'PK': '🇵🇰',
    'EG': '🇪🇬',
    'NG': '🇳🇬',
    'PH': '🇵🇭',
    'ID': '🇮🇩',
    'MX': '🇲🇽',
  };

  static String getRegionName(String code) => supported[code] ?? code;
  static String getFlag(String code) => flags[code] ?? '🌍';
}
