import '../models/regional_price.dart';

/// Service for fetching and comparing regional subscription prices.
/// 
/// Premium-only feature that shows global prices for services
/// like Netflix, Spotify, etc. in different countries.
class RegionalPriceService {
  static final RegionalPriceService _instance = RegionalPriceService._internal();
  factory RegionalPriceService() => _instance;
  RegionalPriceService._internal();

  /// Fetch regional prices for a service
  /// In production, this would call an API. For now, returns stub data.
  Future<List<RegionalPrice>> fetchRegionalPrices(String serviceName) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    final prices = _regionalPriceData[serviceName.toLowerCase()];
    return prices ?? [];
  }

  /// Compare prices and return sorted by converted price
  Future<RegionalPriceComparison> compareRegionalPrices({
    required String serviceName,
    required String targetCurrency,
    required Map<String, double> exchangeRates,
  }) async {
    final prices = await fetchRegionalPrices(serviceName);
    
    if (prices.isEmpty) {
      return RegionalPriceComparison(
        serviceName: serviceName,
        prices: [],
      );
    }

    // Convert all prices to target currency
    final convertedPrices = prices.map((price) {
      final converted = _convertPrice(
        price.price,
        price.currency,
        targetCurrency,
        exchangeRates,
      );
      return RegionalPriceWithConversion(
        original: price,
        convertedPrice: converted,
        targetCurrency: targetCurrency,
      );
    }).toList();

    // Sort by converted price (cheapest first)
    convertedPrices.sort((a, b) => a.convertedPrice.compareTo(b.convertedPrice));

    // Calculate savings percentage
    if (convertedPrices.isNotEmpty) {
      final mostExpensive = convertedPrices.last.convertedPrice;
      for (var i = 0; i < convertedPrices.length; i++) {
        final savings = ((mostExpensive - convertedPrices[i].convertedPrice) / 
            mostExpensive * 100);
        convertedPrices[i] = RegionalPriceWithConversion(
          original: convertedPrices[i].original,
          convertedPrice: convertedPrices[i].convertedPrice,
          targetCurrency: targetCurrency,
          savingsPercent: savings,
        );
      }
    }

    return RegionalPriceComparison(
      serviceName: serviceName,
      prices: convertedPrices,
      cheapest: convertedPrices.isNotEmpty ? convertedPrices.first : null,
      mostExpensive: convertedPrices.isNotEmpty ? convertedPrices.last : null,
    );
  }

  /// Get list of supported services
  List<String> get supportedServices => _regionalPriceData.keys.toList();

  /// Convert price between currencies
  double _convertPrice(
    double amount,
    String fromCurrency,
    String toCurrency,
    Map<String, double> rates,
  ) {
    if (fromCurrency == toCurrency) return amount;
    
    // Try direct conversion
    final directKey = '${fromCurrency}_$toCurrency';
    if (rates.containsKey(directKey)) {
      return amount * rates[directKey]!;
    }
    
    // Try via USD
    final toUsdKey = '${fromCurrency}_USD';
    final fromUsdKey = 'USD_$toCurrency';
    
    if (rates.containsKey(toUsdKey) && rates.containsKey(fromUsdKey)) {
      return amount * rates[toUsdKey]! * rates[fromUsdKey]!;
    }
    
    // Fallback: return original amount
    return amount;
  }

  /// Stub data for regional prices
  /// In production, this would be fetched from an API or Firestore
  static final Map<String, List<RegionalPrice>> _regionalPriceData = {
    'netflix': [
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 99.99,
        planName: 'Standard',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 499,
        planName: 'Standard',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'AR',
        regionName: 'Argentina',
        currency: 'ARS',
        price: 2499,
        planName: 'Standard',
        flag: '🇦🇷',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 15.49,
        planName: 'Standard',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'UK',
        regionName: 'United Kingdom',
        currency: 'GBP',
        price: 10.99,
        planName: 'Standard',
        flag: '🇬🇧',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'DE',
        regionName: 'Germany',
        currency: 'EUR',
        price: 12.99,
        planName: 'Standard',
        flag: '🇩🇪',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'PK',
        regionName: 'Pakistan',
        currency: 'PKR',
        price: 1100,
        planName: 'Standard',
        flag: '🇵🇰',
      ),
      const RegionalPrice(
        serviceName: 'Netflix',
        regionCode: 'EG',
        regionName: 'Egypt',
        currency: 'EGP',
        price: 165,
        planName: 'Standard',
        flag: '🇪🇬',
      ),
    ],
    'spotify': [
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 57.99,
        planName: 'Premium',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 119,
        planName: 'Premium',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'AR',
        regionName: 'Argentina',
        currency: 'ARS',
        price: 1169,
        planName: 'Premium',
        flag: '🇦🇷',
      ),
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 11.99,
        planName: 'Premium',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'PH',
        regionName: 'Philippines',
        currency: 'PHP',
        price: 194,
        planName: 'Premium',
        flag: '🇵🇭',
      ),
      const RegionalPrice(
        serviceName: 'Spotify',
        regionCode: 'ID',
        regionName: 'Indonesia',
        currency: 'IDR',
        price: 54990,
        planName: 'Premium',
        flag: '🇮🇩',
      ),
    ],
    'disney_plus': [
      const RegionalPrice(
        serviceName: 'Disney+',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 64.90,
        planName: 'Standard',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'Disney+',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 299,
        planName: 'Standard',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'Disney+',
        regionCode: 'AR',
        regionName: 'Argentina',
        currency: 'ARS',
        price: 1650,
        planName: 'Standard',
        flag: '🇦🇷',
      ),
      const RegionalPrice(
        serviceName: 'Disney+',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 13.99,
        planName: 'Standard',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'Disney+',
        regionCode: 'BR',
        regionName: 'Brazil',
        currency: 'BRL',
        price: 43.90,
        planName: 'Standard',
        flag: '🇧🇷',
      ),
    ],
    'youtube_premium': [
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 57.99,
        planName: 'Individual',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 139,
        planName: 'Individual',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'AR',
        regionName: 'Argentina',
        currency: 'ARS',
        price: 1190,
        planName: 'Individual',
        flag: '🇦🇷',
      ),
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 13.99,
        planName: 'Individual',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'PK',
        regionName: 'Pakistan',
        currency: 'PKR',
        price: 499,
        planName: 'Individual',
        flag: '🇵🇰',
      ),
      const RegionalPrice(
        serviceName: 'YouTube Premium',
        regionCode: 'UA',
        regionName: 'Ukraine',
        currency: 'UAH',
        price: 99,
        planName: 'Individual',
        flag: '🇺🇦',
      ),
    ],
    'apple_music': [
      const RegionalPrice(
        serviceName: 'Apple Music',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 39.99,
        planName: 'Individual',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'Apple Music',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 99,
        planName: 'Individual',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'Apple Music',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 10.99,
        planName: 'Individual',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'Apple Music',
        regionCode: 'NG',
        regionName: 'Nigeria',
        currency: 'NGN',
        price: 900,
        planName: 'Individual',
        flag: '🇳🇬',
      ),
    ],
    'amazon_prime': [
      const RegionalPrice(
        serviceName: 'Amazon Prime',
        regionCode: 'TR',
        regionName: 'Turkey',
        currency: 'TRY',
        price: 39,
        planName: 'Monthly',
        flag: '🇹🇷',
      ),
      const RegionalPrice(
        serviceName: 'Amazon Prime',
        regionCode: 'IN',
        regionName: 'India',
        currency: 'INR',
        price: 299,
        planName: 'Monthly',
        flag: '🇮🇳',
      ),
      const RegionalPrice(
        serviceName: 'Amazon Prime',
        regionCode: 'US',
        regionName: 'United States',
        currency: 'USD',
        price: 14.99,
        planName: 'Monthly',
        flag: '🇺🇸',
      ),
      const RegionalPrice(
        serviceName: 'Amazon Prime',
        regionCode: 'DE',
        regionName: 'Germany',
        currency: 'EUR',
        price: 8.99,
        planName: 'Monthly',
        flag: '🇩🇪',
      ),
    ],
  };
}
