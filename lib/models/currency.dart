/// Model and data for world currencies.
class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  @override
  String toString() => '$code - $name';
}

/// List of all world currencies.
class Currencies {
  static const List<Currency> all = [
    // Major Currencies
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flag: '🇨🇭'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', flag: '🇳🇿'),
    
    // CIS Countries
    Currency(code: 'UZS', name: 'Uzbek Som', symbol: "so'm", flag: '🇺🇿'),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', flag: '🇷🇺'),
    Currency(code: 'KZT', name: 'Kazakh Tenge', symbol: '₸', flag: '🇰🇿'),
    Currency(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴', flag: '🇺🇦'),
    Currency(code: 'BYN', name: 'Belarusian Ruble', symbol: 'Br', flag: '🇧🇾'),
    Currency(code: 'GEL', name: 'Georgian Lari', symbol: '₾', flag: '🇬🇪'),
    Currency(code: 'AMD', name: 'Armenian Dram', symbol: '֏', flag: '🇦🇲'),
    Currency(code: 'AZN', name: 'Azerbaijani Manat', symbol: '₼', flag: '🇦🇿'),
    Currency(code: 'KGS', name: 'Kyrgyz Som', symbol: 'с', flag: '🇰🇬'),
    Currency(code: 'TJS', name: 'Tajik Somoni', symbol: 'SM', flag: '🇹🇯'),
    Currency(code: 'TMT', name: 'Turkmen Manat', symbol: 'm', flag: '🇹🇲'),
    Currency(code: 'MDL', name: 'Moldovan Leu', symbol: 'L', flag: '🇲🇩'),
    
    // Asian Currencies
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', flag: '🇭🇰'),
    Currency(code: 'TWD', name: 'Taiwan Dollar', symbol: 'NT\$', flag: '🇹🇼'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭'),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾'),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '🇮🇩'),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', flag: '🇵🇭'),
    Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', flag: '🇻🇳'),
    Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: '₨', flag: '🇵🇰'),
    Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', flag: '🇧🇩'),
    Currency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs', flag: '🇱🇰'),
    Currency(code: 'NPR', name: 'Nepalese Rupee', symbol: 'रू', flag: '🇳🇵'),
    Currency(code: 'MMK', name: 'Myanmar Kyat', symbol: 'K', flag: '🇲🇲'),
    Currency(code: 'KHR', name: 'Cambodian Riel', symbol: '៛', flag: '🇰🇭'),
    Currency(code: 'LAK', name: 'Lao Kip', symbol: '₭', flag: '🇱🇦'),
    Currency(code: 'MNT', name: 'Mongolian Tugrik', symbol: '₮', flag: '🇲🇳'),
    
    // Middle East
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪'),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦'),
    Currency(code: 'QAR', name: 'Qatari Riyal', symbol: 'ر.ق', flag: '🇶🇦'),
    Currency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'د.ك', flag: '🇰🇼'),
    Currency(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD', flag: '🇧🇭'),
    Currency(code: 'OMR', name: 'Omani Rial', symbol: 'ر.ع.', flag: '🇴🇲'),
    Currency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪', flag: '🇮🇱'),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷'),
    Currency(code: 'IRR', name: 'Iranian Rial', symbol: '﷼', flag: '🇮🇷'),
    Currency(code: 'IQD', name: 'Iraqi Dinar', symbol: 'ع.د', flag: '🇮🇶'),
    Currency(code: 'JOD', name: 'Jordanian Dinar', symbol: 'د.ا', flag: '🇯🇴'),
    Currency(code: 'LBP', name: 'Lebanese Pound', symbol: 'ل.ل', flag: '🇱🇧'),
    Currency(code: 'SYP', name: 'Syrian Pound', symbol: '£S', flag: '🇸🇾'),
    Currency(code: 'YER', name: 'Yemeni Rial', symbol: '﷼', flag: '🇾🇪'),
    
    // European Currencies
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flag: '🇸🇪'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flag: '🇳🇴'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flag: '🇩🇰'),
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', flag: '🇵🇱'),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', flag: '🇨🇿'),
    Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', flag: '🇭🇺'),
    Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', flag: '🇷🇴'),
    Currency(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', flag: '🇧🇬'),
    Currency(code: 'HRK', name: 'Croatian Kuna', symbol: 'kn', flag: '🇭🇷'),
    Currency(code: 'RSD', name: 'Serbian Dinar', symbol: 'дин', flag: '🇷🇸'),
    Currency(code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', flag: '🇮🇸'),
    Currency(code: 'MKD', name: 'Macedonian Denar', symbol: 'ден', flag: '🇲🇰'),
    Currency(code: 'ALL', name: 'Albanian Lek', symbol: 'L', flag: '🇦🇱'),
    Currency(code: 'BAM', name: 'Bosnia Mark', symbol: 'KM', flag: '🇧🇦'),
    
    // African Currencies
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', flag: '🇿🇦'),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', flag: '🇪🇬'),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', flag: '🇳🇬'),
    Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', flag: '🇰🇪'),
    Currency(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', flag: '🇬🇭'),
    Currency(code: 'MAD', name: 'Moroccan Dirham', symbol: 'د.م.', flag: '🇲🇦'),
    Currency(code: 'TND', name: 'Tunisian Dinar', symbol: 'د.ت', flag: '🇹🇳'),
    Currency(code: 'DZD', name: 'Algerian Dinar', symbol: 'د.ج', flag: '🇩🇿'),
    Currency(code: 'ETB', name: 'Ethiopian Birr', symbol: 'Br', flag: '🇪🇹'),
    Currency(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh', flag: '🇹🇿'),
    Currency(code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh', flag: '🇺🇬'),
    Currency(code: 'XOF', name: 'West African CFA', symbol: 'CFA', flag: '🌍'),
    Currency(code: 'XAF', name: 'Central African CFA', symbol: 'FCFA', flag: '🌍'),
    Currency(code: 'MUR', name: 'Mauritian Rupee', symbol: '₨', flag: '🇲🇺'),
    Currency(code: 'BWP', name: 'Botswana Pula', symbol: 'P', flag: '🇧🇼'),
    Currency(code: 'ZMW', name: 'Zambian Kwacha', symbol: 'ZK', flag: '🇿🇲'),
    
    // Latin American Currencies
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: 'Mex\$', flag: '🇲🇽'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', flag: '🇧🇷'),
    Currency(code: 'ARS', name: 'Argentine Peso', symbol: '\$', flag: '🇦🇷'),
    Currency(code: 'CLP', name: 'Chilean Peso', symbol: '\$', flag: '🇨🇱'),
    Currency(code: 'COP', name: 'Colombian Peso', symbol: '\$', flag: '🇨🇴'),
    Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', flag: '🇵🇪'),
    Currency(code: 'VES', name: 'Venezuelan Bolívar', symbol: 'Bs', flag: '🇻🇪'),
    Currency(code: 'UYU', name: 'Uruguayan Peso', symbol: '\$U', flag: '🇺🇾'),
    Currency(code: 'BOB', name: 'Bolivian Boliviano', symbol: 'Bs.', flag: '🇧🇴'),
    Currency(code: 'PYG', name: 'Paraguayan Guaraní', symbol: '₲', flag: '🇵🇾'),
    Currency(code: 'CRC', name: 'Costa Rican Colón', symbol: '₡', flag: '🇨🇷'),
    Currency(code: 'PAB', name: 'Panamanian Balboa', symbol: 'B/.', flag: '🇵🇦'),
    Currency(code: 'DOP', name: 'Dominican Peso', symbol: 'RD\$', flag: '🇩🇴'),
    Currency(code: 'GTQ', name: 'Guatemalan Quetzal', symbol: 'Q', flag: '🇬🇹'),
    Currency(code: 'HNL', name: 'Honduran Lempira', symbol: 'L', flag: '🇭🇳'),
    Currency(code: 'NIO', name: 'Nicaraguan Córdoba', symbol: 'C\$', flag: '🇳🇮'),
    Currency(code: 'CUP', name: 'Cuban Peso', symbol: '₱', flag: '🇨🇺'),
    Currency(code: 'JMD', name: 'Jamaican Dollar', symbol: 'J\$', flag: '🇯🇲'),
    Currency(code: 'TTD', name: 'Trinidad Dollar', symbol: 'TT\$', flag: '🇹🇹'),
    
    // Caribbean
    Currency(code: 'BSD', name: 'Bahamian Dollar', symbol: 'B\$', flag: '🇧🇸'),
    Currency(code: 'BBD', name: 'Barbadian Dollar', symbol: 'Bds\$', flag: '🇧🇧'),
    Currency(code: 'XCD', name: 'East Caribbean Dollar', symbol: 'EC\$', flag: '🌴'),
    Currency(code: 'HTG', name: 'Haitian Gourde', symbol: 'G', flag: '🇭🇹'),
    
    // Oceania
    Currency(code: 'FJD', name: 'Fijian Dollar', symbol: 'FJ\$', flag: '🇫🇯'),
    Currency(code: 'PGK', name: 'Papua New Guinea Kina', symbol: 'K', flag: '🇵🇬'),
    Currency(code: 'WST', name: 'Samoan Tala', symbol: 'WS\$', flag: '🇼🇸'),
    Currency(code: 'TOP', name: 'Tongan Paʻanga', symbol: 'T\$', flag: '🇹🇴'),
    Currency(code: 'VUV', name: 'Vanuatu Vatu', symbol: 'VT', flag: '🇻🇺'),
    
    // Crypto (Popular)
    Currency(code: 'BTC', name: 'Bitcoin', symbol: '₿', flag: '🪙'),
    Currency(code: 'ETH', name: 'Ethereum', symbol: 'Ξ', flag: '🪙'),
    Currency(code: 'USDT', name: 'Tether', symbol: '₮', flag: '🪙'),
    Currency(code: 'USDC', name: 'USD Coin', symbol: '\$', flag: '🪙'),
  ];

  /// Map of country codes to currency codes for locale detection.
  static const Map<String, String> _countryToCurrency = {
    'US': 'USD', 'EU': 'EUR', 'GB': 'GBP', 'JP': 'JPY', 'CN': 'CNY',
    'CH': 'CHF', 'CA': 'CAD', 'AU': 'AUD', 'NZ': 'NZD', 'UZ': 'UZS',
    'RU': 'RUB', 'KZ': 'KZT', 'UA': 'UAH', 'BY': 'BYN', 'GE': 'GEL',
    'AM': 'AMD', 'AZ': 'AZN', 'KG': 'KGS', 'TJ': 'TJS', 'TM': 'TMT',
    'MD': 'MDL', 'IN': 'INR', 'KR': 'KRW', 'SG': 'SGD', 'HK': 'HKD',
    'TW': 'TWD', 'TH': 'THB', 'MY': 'MYR', 'ID': 'IDR', 'PH': 'PHP',
    'VN': 'VND', 'PK': 'PKR', 'BD': 'BDT', 'AE': 'AED', 'SA': 'SAR',
    'IL': 'ILS', 'TR': 'TRY', 'EG': 'EGP', 'NG': 'NGN', 'ZA': 'ZAR',
    'KE': 'KES', 'GH': 'GHS', 'MA': 'MAD', 'BR': 'BRL', 'MX': 'MXN',
    'AR': 'ARS', 'CL': 'CLP', 'CO': 'COP', 'PE': 'PEN', 'PL': 'PLN',
    'CZ': 'CZK', 'HU': 'HUF', 'RO': 'RON', 'BG': 'BGN', 'HR': 'HRK',
    'RS': 'RSD', 'SE': 'SEK', 'NO': 'NOK', 'DK': 'DKK', 'IS': 'ISK',
    // Eurozone countries
    'DE': 'EUR', 'FR': 'EUR', 'IT': 'EUR', 'ES': 'EUR', 'PT': 'EUR',
    'NL': 'EUR', 'BE': 'EUR', 'AT': 'EUR', 'IE': 'EUR', 'FI': 'EUR',
    'GR': 'EUR', 'SK': 'EUR', 'SI': 'EUR', 'LT': 'EUR', 'LV': 'EUR',
    'EE': 'EUR', 'LU': 'EUR', 'MT': 'EUR', 'CY': 'EUR',
  };

  /// Get currency code for a given country code (ISO 3166-1 alpha-2).
  static String? getCurrencyForCountry(String countryCode) {
    return _countryToCurrency[countryCode.toUpperCase()];
  }

  /// Get default currency based on device locale.
  /// Falls back to USD if locale cannot be determined.
  static String getDefaultCurrencyFromLocale(String? localeString) {
    if (localeString == null || localeString.isEmpty) {
      return 'USD';
    }
    
    // Locale can be "en_US", "en-US", "en", etc.
    String? countryCode;
    if (localeString.contains('_')) {
      countryCode = localeString.split('_').last;
    } else if (localeString.contains('-')) {
      countryCode = localeString.split('-').last;
    }
    
    if (countryCode != null && countryCode.length == 2) {
      final currency = getCurrencyForCountry(countryCode);
      if (currency != null) {
        return currency;
      }
    }
    
    return 'USD';
  }

  /// Popular currencies shown at the top.
  static const List<String> popularCodes = [
    'UZS', 'USD', 'EUR', 'RUB', 'GBP', 'KZT', 'UAH', 'TRY', 'CNY', 'JPY', 'INR', 'AED',
  ];

  /// Get popular currencies.
  static List<Currency> get popular {
    return popularCodes
        .map((code) => getByCode(code))
        .whereType<Currency>()
        .toList();
  }

  /// Get all currencies sorted by code.
  static List<Currency> get sorted {
    final list = List<Currency>.from(all);
    list.sort((a, b) => a.code.compareTo(b.code));
    return list;
  }

  /// Get a currency by code.
  static Currency? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Search currencies by code or name.
  static List<Currency> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((c) => 
      c.code.toLowerCase().contains(lowerQuery) ||
      c.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get symbol for a currency code.
  static String getSymbol(String code) {
    return getByCode(code)?.symbol ?? code;
  }

  /// Format amount with currency.
  static String format(double amount, String currencyCode) {
    final currency = getByCode(currencyCode);
    if (currency != null) {
      return '${currency.symbol}${amount.toStringAsFixed(2)}';
    }
    return '$currencyCode ${amount.toStringAsFixed(2)}';
  }
}
