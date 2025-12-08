/// Model for regional pricing data for subscription services.
/// 
/// Used by the Regional Price Comparator feature to show
/// global prices for services like Netflix, Spotify, etc.
class RegionalPrice {
  final String serviceName;
  final String regionCode; // ISO country code: "TR", "IN", "AR", "US"
  final String regionName; // Human readable: "Turkey", "India", etc.
  final String currency;   // "TRY", "INR", "ARS", "USD"
  final double price;
  final String? planName;  // "Basic", "Standard", "Premium"
  final String flag;       // Emoji flag: "🇹🇷", "🇮🇳", etc.

  const RegionalPrice({
    required this.serviceName,
    required this.regionCode,
    required this.regionName,
    required this.currency,
    required this.price,
    this.planName,
    required this.flag,
  });

  /// Convert price to another currency using exchange rate
  double convertTo(String targetCurrency, Map<String, double> exchangeRates) {
    if (currency == targetCurrency) return price;
    
    // Convert to USD first (base), then to target
    final toUsd = exchangeRates['${currency}_USD'] ?? 1.0;
    final fromUsd = exchangeRates['USD_$targetCurrency'] ?? 1.0;
    
    return price * toUsd * fromUsd;
  }

  factory RegionalPrice.fromJson(Map<String, dynamic> json) {
    return RegionalPrice(
      serviceName: json['serviceName'] as String,
      regionCode: json['regionCode'] as String,
      regionName: json['regionName'] as String,
      currency: json['currency'] as String,
      price: (json['price'] as num).toDouble(),
      planName: json['planName'] as String?,
      flag: json['flag'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'regionCode': regionCode,
      'regionName': regionName,
      'currency': currency,
      'price': price,
      'planName': planName,
      'flag': flag,
    };
  }
}

/// Regional price comparison result with converted prices
class RegionalPriceComparison {
  final String serviceName;
  final List<RegionalPriceWithConversion> prices;
  final RegionalPriceWithConversion? cheapest;
  final RegionalPriceWithConversion? mostExpensive;

  RegionalPriceComparison({
    required this.serviceName,
    required this.prices,
    this.cheapest,
    this.mostExpensive,
  });
}

/// Regional price with conversion to user's base currency
class RegionalPriceWithConversion {
  final RegionalPrice original;
  final double convertedPrice;
  final String targetCurrency;
  final double savingsPercent; // Compared to most expensive

  RegionalPriceWithConversion({
    required this.original,
    required this.convertedPrice,
    required this.targetCurrency,
    this.savingsPercent = 0,
  });
}
