import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for fetching and caching exchange rates.
///
/// Uses a free exchange rate API to convert between currencies.
/// Caches rates locally for 12 hours to minimize API calls.
///
/// CONFIGURATION:
/// Replace the API URL and key with your preferred exchange rate provider:
/// - Free options: exchangerate-api.com, open.er-api.com, fixer.io (limited)
/// - Paid options: currencylayer.com, openexchangerates.org
class ExchangeRateService {
  // ============================================================
  // CONFIGURATION - Replace with your API details
  // ============================================================
  
  /// Base URL for the exchange rate API.
  /// Current: ExchangeRate-API (free tier - 1500 requests/month)
  /// Sign up at: https://www.exchangerate-api.com/
  static const String _apiBaseUrl = 'https://v6.exchangerate-api.com/v6';
  
  /// API key - Replace with your own key.
  /// Get a free key at: https://www.exchangerate-api.com/
  /// Or use open.er-api.com which doesn't require a key for basic usage.
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  
  /// Alternative free API that doesn't require a key (backup).
  static const String _freeApiUrl = 'https://open.er-api.com/v6/latest';
  
  // ============================================================
  
  /// Cache duration in hours.
  static const int _cacheDurationHours = 12;
  
  /// Cached exchange rates (base currency -> rates).
  final Map<String, Map<String, double>> _ratesCache = {};
  
  /// Timestamp of last cache update per base currency.
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Converts an amount from one currency to another.
  ///
  /// Returns null if conversion fails or currencies are not supported.
  Future<double?> convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;
    
    try {
      final rates = await _getRates(fromCurrency);
      if (rates == null) return null;
      
      final rate = rates[toCurrency];
      if (rate == null) return null;
      
      return amount * rate;
    } catch (e) {
      debugPrint('ExchangeRateService: Conversion error: $e');
      return null;
    }
  }

  /// Gets the exchange rate from one currency to another.
  Future<double?> getRate(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return 1.0;
    
    final rates = await _getRates(fromCurrency);
    return rates?[toCurrency];
  }

  /// Gets all exchange rates for a base currency.
  Future<Map<String, double>?> _getRates(String baseCurrency) async {
    // Check memory cache
    if (_isCacheValid(baseCurrency)) {
      return _ratesCache[baseCurrency];
    }
    
    // Try to load from persistent cache
    final persistedRates = await _loadFromPersistentCache(baseCurrency);
    if (persistedRates != null) {
      _ratesCache[baseCurrency] = persistedRates;
      return persistedRates;
    }
    
    // Fetch fresh rates from API
    return await _fetchRates(baseCurrency);
  }

  /// Checks if the cache for a currency is still valid.
  bool _isCacheValid(String baseCurrency) {
    final timestamp = _cacheTimestamps[baseCurrency];
    if (timestamp == null) return false;
    
    final age = DateTime.now().difference(timestamp);
    return age.inHours < _cacheDurationHours && _ratesCache.containsKey(baseCurrency);
  }

  /// Fetches exchange rates from the API.
  Future<Map<String, double>?> _fetchRates(String baseCurrency) async {
    try {
      // Try primary API first
      Map<String, double>? rates = await _fetchFromPrimaryApi(baseCurrency);
      
      // Fallback to free API if primary fails
      if (rates == null) {
        rates = await _fetchFromFreeApi(baseCurrency);
      }
      
      if (rates != null) {
        // Update caches
        _ratesCache[baseCurrency] = rates;
        _cacheTimestamps[baseCurrency] = DateTime.now();
        await _saveToPersistentCache(baseCurrency, rates);
      }
      
      return rates;
    } catch (e) {
      debugPrint('ExchangeRateService: Fetch error: $e');
      return null;
    }
  }

  /// Fetches from primary API (ExchangeRate-API).
  Future<Map<String, double>?> _fetchFromPrimaryApi(String baseCurrency) async {
    if (_apiKey == 'YOUR_API_KEY_HERE') {
      // API key not configured, skip primary API
      return null;
    }
    
    try {
      final url = '$_apiBaseUrl/$_apiKey/latest/$baseCurrency';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final rates = data['conversion_rates'] as Map<String, dynamic>;
          return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      }
    } catch (e) {
      debugPrint('ExchangeRateService: Primary API error: $e');
    }
    
    return null;
  }

  /// Fetches from free API (open.er-api.com).
  Future<Map<String, double>?> _fetchFromFreeApi(String baseCurrency) async {
    try {
      final url = '$_freeApiUrl/$baseCurrency';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final rates = data['rates'] as Map<String, dynamic>;
          return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      }
    } catch (e) {
      debugPrint('ExchangeRateService: Free API error: $e');
    }
    
    return null;
  }

  /// Loads cached rates from persistent storage.
  Future<Map<String, double>?> _loadFromPersistentCache(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check timestamp
      final timestampStr = prefs.getString('fx_timestamp_$baseCurrency');
      if (timestampStr == null) return null;
      
      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;
      
      final age = DateTime.now().difference(timestamp);
      if (age.inHours >= _cacheDurationHours) return null;
      
      // Load rates
      final ratesStr = prefs.getString('fx_rates_$baseCurrency');
      if (ratesStr == null) return null;
      
      final ratesMap = json.decode(ratesStr) as Map<String, dynamic>;
      _cacheTimestamps[baseCurrency] = timestamp;
      
      return ratesMap.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } catch (e) {
      debugPrint('ExchangeRateService: Cache load error: $e');
      return null;
    }
  }

  /// Saves rates to persistent storage.
  Future<void> _saveToPersistentCache(
    String baseCurrency,
    Map<String, double> rates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fx_timestamp_$baseCurrency', DateTime.now().toIso8601String());
      await prefs.setString('fx_rates_$baseCurrency', json.encode(rates));
    } catch (e) {
      debugPrint('ExchangeRateService: Cache save error: $e');
    }
  }

  /// Clears all cached rates.
  Future<void> clearCache() async {
    _ratesCache.clear();
    _cacheTimestamps.clear();
    
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('fx_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Forces a refresh of rates for a specific currency.
  Future<Map<String, double>?> refreshRates(String baseCurrency) async {
    _cacheTimestamps.remove(baseCurrency);
    _ratesCache.remove(baseCurrency);
    return await _fetchRates(baseCurrency);
  }
}

/// Extension to convert subscription amounts.
extension CurrencyConversion on ExchangeRateService {
  /// Converts a list of amounts from different currencies to a single base currency.
  /// Returns a map of original currency -> converted amount.
  Future<Map<String, double>> convertMultiple(
    Map<String, double> amountsByCurrency,
    String toCurrency,
  ) async {
    final results = <String, double>{};
    
    for (final entry in amountsByCurrency.entries) {
      final converted = await convertAmount(entry.value, entry.key, toCurrency);
      if (converted != null) {
        results[entry.key] = converted;
      }
    }
    
    return results;
  }
}
