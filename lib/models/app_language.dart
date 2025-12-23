/// Supported languages for the app.
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

/// Available languages in the app.
class AppLanguages {
  static const List<AppLanguage> all = [
    // Major Languages
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱'),
    AppLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski', flag: '🇵🇱'),
    AppLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska', flag: '🇸🇪'),
    AppLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk', flag: '🇩🇰'),
    AppLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk', flag: '🇳🇴'),
    AppLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi', flag: '🇫🇮'),
    
    // CIS Languages
    AppLanguage(code: 'uz', name: 'Uzbek', nativeName: "O'zbek", flag: '🇺🇿'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
    AppLanguage(code: 'uk', name: 'Ukrainian', nativeName: 'Українська', flag: '🇺🇦'),
    AppLanguage(code: 'kk', name: 'Kazakh', nativeName: 'Қазақ', flag: '🇰🇿'),
    AppLanguage(code: 'ky', name: 'Kyrgyz', nativeName: 'Кыргызча', flag: '🇰🇬'),
    AppLanguage(code: 'tg', name: 'Tajik', nativeName: 'Тоҷикӣ', flag: '🇹🇯'),
    AppLanguage(code: 'az', name: 'Azerbaijani', nativeName: 'Azərbaycan', flag: '🇦🇿'),
    AppLanguage(code: 'hy', name: 'Armenian', nativeName: 'Հայերեն', flag: '🇦🇲'),
    AppLanguage(code: 'ka', name: 'Georgian', nativeName: 'ქართული', flag: '🇬🇪'),
    AppLanguage(code: 'be', name: 'Belarusian', nativeName: 'Беларуская', flag: '🇧🇾'),
    
    // Asian Languages
    AppLanguage(code: 'zh', name: 'Chinese (Simplified)', nativeName: '中文', flag: '🇨🇳'),
    AppLanguage(code: 'zh_TW', name: 'Chinese (Traditional)', nativeName: '繁體中文', flag: '🇹🇼'),
    AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩'),
    AppLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย', flag: '🇹🇭'),
    AppLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩'),
    AppLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '🇲🇾'),
    AppLanguage(code: 'tl', name: 'Filipino', nativeName: 'Filipino', flag: '🇵🇭'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
    AppLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली', flag: '🇳🇵'),
    AppLanguage(code: 'si', name: 'Sinhala', nativeName: 'සිංහල', flag: '🇱🇰'),
    AppLanguage(code: 'my', name: 'Burmese', nativeName: 'မြန်မာ', flag: '🇲🇲'),
    AppLanguage(code: 'km', name: 'Khmer', nativeName: 'ខ្មែរ', flag: '🇰🇭'),
    AppLanguage(code: 'lo', name: 'Lao', nativeName: 'ລາວ', flag: '🇱🇦'),
    AppLanguage(code: 'mn', name: 'Mongolian', nativeName: 'Монгол', flag: '🇲🇳'),
    
    // Middle Eastern Languages
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    AppLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی', flag: '🇮🇷'),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
    AppLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית', flag: '🇮🇱'),
    AppLanguage(code: 'ku', name: 'Kurdish', nativeName: 'Kurdî', flag: '🌍'),
    
    // African Languages
    AppLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '🇰🇪'),
    AppLanguage(code: 'am', name: 'Amharic', nativeName: 'አማርኛ', flag: '🇪🇹'),
    AppLanguage(code: 'ha', name: 'Hausa', nativeName: 'Hausa', flag: '🇳🇬'),
    AppLanguage(code: 'yo', name: 'Yoruba', nativeName: 'Yorùbá', flag: '🇳🇬'),
    AppLanguage(code: 'ig', name: 'Igbo', nativeName: 'Igbo', flag: '🇳🇬'),
    AppLanguage(code: 'zu', name: 'Zulu', nativeName: 'isiZulu', flag: '🇿🇦'),
    AppLanguage(code: 'af', name: 'Afrikaans', nativeName: 'Afrikaans', flag: '🇿🇦'),
    
    // Other European Languages
    AppLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština', flag: '🇨🇿'),
    AppLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina', flag: '🇸🇰'),
    AppLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar', flag: '🇭🇺'),
    AppLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română', flag: '🇷🇴'),
    AppLanguage(code: 'bg', name: 'Bulgarian', nativeName: 'Български', flag: '🇧🇬'),
    AppLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά', flag: '🇬🇷'),
    AppLanguage(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski', flag: '🇭🇷'),
    AppLanguage(code: 'sr', name: 'Serbian', nativeName: 'Српски', flag: '🇷🇸'),
    AppLanguage(code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina', flag: '🇸🇮'),
    AppLanguage(code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių', flag: '🇱🇹'),
    AppLanguage(code: 'lv', name: 'Latvian', nativeName: 'Latviešu', flag: '🇱🇻'),
    AppLanguage(code: 'et', name: 'Estonian', nativeName: 'Eesti', flag: '🇪🇪'),
    AppLanguage(code: 'is', name: 'Icelandic', nativeName: 'Íslenska', flag: '🇮🇸'),
    AppLanguage(code: 'ga', name: 'Irish', nativeName: 'Gaeilge', flag: '🇮🇪'),
    AppLanguage(code: 'cy', name: 'Welsh', nativeName: 'Cymraeg', flag: '🏴󠁧󠁢󠁷󠁬󠁳󠁿'),
    AppLanguage(code: 'ca', name: 'Catalan', nativeName: 'Català', flag: '🇪🇸'),
    AppLanguage(code: 'eu', name: 'Basque', nativeName: 'Euskara', flag: '🇪🇸'),
    AppLanguage(code: 'gl', name: 'Galician', nativeName: 'Galego', flag: '🇪🇸'),
    AppLanguage(code: 'mt', name: 'Maltese', nativeName: 'Malti', flag: '🇲🇹'),
    AppLanguage(code: 'sq', name: 'Albanian', nativeName: 'Shqip', flag: '🇦🇱'),
    AppLanguage(code: 'mk', name: 'Macedonian', nativeName: 'Македонски', flag: '🇲🇰'),
    AppLanguage(code: 'bs', name: 'Bosnian', nativeName: 'Bosanski', flag: '🇧🇦'),
  ];

  /// Get popular languages shown first.
  static const List<String> popularCodes = [
    'en', 'es', 'fr', 'de', 'ru', 'uz', 'zh', 'ja', 'ko', 'ar', 'hi', 'pt',
  ];

  /// Supported UI languages for the app.
  static const List<String> supportedCodes = [
    'en',
    'ar',
    'fr',
    'es',
    'de',
    'pt',
    'ja',
    'tr',
    'zh',
    'ko',
  ];
  
  /// Get supported UI languages.
  static List<AppLanguage> get supportedLanguages {
    return [
      const AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
      const AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
      const AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
      const AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
      const AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
      const AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹'),
      const AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
      const AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷'),
      const AppLanguage(code: 'zh', name: 'Chinese (Simplified)', nativeName: '中文', flag: '🇨🇳'),
      const AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', flag: '🇰🇷'),
    ];
  }

  /// Get popular languages.
  static List<AppLanguage> get popular {
    return popularCodes
        .map((code) => getByCode(code))
        .whereType<AppLanguage>()
        .toList();
  }

  /// Get a language by code.
  static AppLanguage? getByCode(String code) {
    try {
      return all.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Search languages by code or name.
  static List<AppLanguage> search(String query) {
    final lowerQuery = query.toLowerCase();
    return all.where((l) => 
      l.code.toLowerCase().contains(lowerQuery) ||
      l.name.toLowerCase().contains(lowerQuery) ||
      l.nativeName.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
