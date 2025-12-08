import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_language.dart';
import '../models/currency.dart';
import '../l10n/app_strings.dart';
import '../providers/premium_providers.dart';
import '../services/theme_service.dart';
import 'report_screen.dart';
import 'usage_analytics_screen.dart';

/// Provider for app language
final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});

/// Provider for localized strings
final stringsProvider = Provider<AppStrings>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppStrings(language.code);
});

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  AppLanguageNotifier() : super(AppLanguages.supportedLanguages.first) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'en';
    final language =
        AppLanguages.getByCode(code) ?? AppLanguages.supportedLanguages.first;
    state = language;
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', language.code);
    state = language;
  }
}

/// Settings screen with language selection and premium features.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(appLanguageProvider);
    final strings = ref.watch(stringsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final calendarSyncEnabled = ref.watch(calendarSyncEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Premium Status Card
          _buildPremiumCard(context, ref, isPremium, strings),
          const SizedBox(height: 24),

          // Language Section
          Text(
            strings.language,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.selectLanguage,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Language selector card
          Card(
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  currentLanguage.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              title: Text(currentLanguage.name),
              subtitle: Text(currentLanguage.nativeName),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () =>
                  _showLanguageDialog(context, ref, currentLanguage, strings),
            ),
          ),

          const SizedBox(height: 32),

          // Theme Section
          Text(
            strings.theme,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeSection(context, ref, isPremium, themeMode, strings),

          const SizedBox(height: 32),

          // Base Currency Section (Premium)
          Text(
            strings.baseCurrency,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.selectBaseCurrency,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildCurrencySection(context, ref, isPremium, baseCurrency, strings),

          const SizedBox(height: 32),

          // Calendar Sync Section (Premium)
          Text(
            strings.calendarSync,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.calendarSyncDescription,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildCalendarSyncSection(
              context, ref, isPremium, calendarSyncEnabled, strings),

          const SizedBox(height: 32),

          // Usage Analytics Section (Premium)
          Text(
            strings.usageAnalytics,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track how much you use your subscriptions',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildUsageAnalyticsSection(context, ref, isPremium, strings),

          const SizedBox(height: 32),

          // Reports Section (Premium)
          Text(
            strings.reports,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate detailed PDF reports of your subscriptions',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildReportsSection(context, ref, isPremium, strings),

          const SizedBox(height: 32),

          // App Info Section
          Text(
            strings.about,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(strings.appVersion),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.subscriptions),
                  title: const Text('Subscription Alert'),
                  subtitle: Text(strings.trackSubscriptions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
      BuildContext context, WidgetRef ref, bool isPremium, dynamic strings) {
    final isLifetime = ref.watch(isLifetimePremiumProvider);
    final daysRemaining = ref.watch(premiumDaysRemainingProvider);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isPremium
                ? [Colors.amber[600]!, Colors.orange[400]!]
                : [Colors.grey[600]!, Colors.grey[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.star : Icons.star_border,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? strings.premiumActive : strings.freePlan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isPremium)
                    Text(
                      isLifetime
                          ? strings.lifetimePremium
                          : strings.daysRemaining(daysRemaining),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  if (!isPremium)
                    Text(
                      strings.inviteToGetPremium,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ),
            if (!isPremium)
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to premium purchase screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.amber[700],
                ),
                child: Text(strings.upgradeToPremium),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    AppThemeMode currentTheme,
    dynamic strings,
  ) {
    return Card(
      child: Column(
        children: [
          // System Default - always available
          RadioListTile<AppThemeMode>(
            title: Row(
              children: [
                const Icon(Icons.brightness_auto, size: 20),
                const SizedBox(width: 12),
                Text(strings.systemDefault),
              ],
            ),
            value: AppThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              ref
                  .read(appThemeModeProvider.notifier)
                  .setTheme(AppThemeMode.system);
            },
          ),
          const Divider(height: 1),

          // Light Mode - premium only
          RadioListTile<AppThemeMode>(
            title: Row(
              children: [
                const Icon(Icons.light_mode, size: 20),
                const SizedBox(width: 12),
                Text(strings.lightMode),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  _buildPremiumBadge(),
                ],
              ],
            ),
            value: AppThemeMode.light,
            groupValue: currentTheme,
            onChanged: isPremium
                ? (value) => ref
                    .read(appThemeModeProvider.notifier)
                    .setTheme(AppThemeMode.light)
                : (value) => _showPremiumDialog(
                    context, strings.themePremiumOnly, strings),
          ),
          const Divider(height: 1),

          // Dark Mode - premium only
          RadioListTile<AppThemeMode>(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20),
                const SizedBox(width: 12),
                Text(strings.darkMode),
                if (!isPremium) ...[
                  const SizedBox(width: 8),
                  _buildPremiumBadge(),
                ],
              ],
            ),
            value: AppThemeMode.dark,
            groupValue: currentTheme,
            onChanged: isPremium
                ? (value) => ref
                    .read(appThemeModeProvider.notifier)
                    .setTheme(AppThemeMode.dark)
                : (value) => _showPremiumDialog(
                    context, strings.themePremiumOnly, strings),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    String currentCurrency,
    dynamic strings,
  ) {
    final currency = Currencies.all.firstWhere(
      (c) => c.code == currentCurrency,
      orElse: () => Currencies.all.first,
    );

    return Card(
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Text(currency.flag, style: const TextStyle(fontSize: 24)),
        ),
        title: Row(
          children: [
            Text('${currency.code} - ${currency.name}'),
            if (!isPremium) ...[
              const SizedBox(width: 8),
              _buildPremiumBadge(),
            ],
          ],
        ),
        subtitle: Text(strings.currencyConversionPremium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isPremium
            ? () => _showCurrencyDialog(context, ref, currentCurrency, strings)
            : () => _showPremiumDialog(
                context, strings.currencyConversionPremium, strings),
      ),
    );
  }

  Widget _buildCalendarSyncSection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    bool isEnabled,
    dynamic strings,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.calendar_month,
          color: isEnabled && isPremium ? Colors.blue : Colors.grey,
        ),
        title: Row(
          children: [
            Text(strings.connectCalendar),
            if (!isPremium) ...[
              const SizedBox(width: 8),
              _buildPremiumBadge(),
            ],
          ],
        ),
        subtitle: Text(
          isPremium
              ? (isEnabled ? 'Calendar sync is enabled' : 'Tap to enable')
              : strings.calendarSyncPremiumOnly,
        ),
        trailing: isPremium
            ? Switch(
                value: isEnabled,
                onChanged: (value) async {
                  final controller = ref.read(premiumControllerProvider);
                  await controller?.setCalendarSync(enabled: value);
                },
              )
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: isPremium
            ? null
            : () => _showPremiumDialog(
                context, strings.calendarSyncPremiumOnly, strings),
      ),
    );
  }

  Widget _buildUsageAnalyticsSection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    dynamic strings,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.analytics,
          color: isPremium ? Colors.blue : Colors.grey,
        ),
        title: Row(
          children: [
            Text(strings.usageTracker),
            if (!isPremium) ...[
              const SizedBox(width: 8),
              _buildPremiumBadge(),
            ],
          ],
        ),
        subtitle: Text(
          isPremium
              ? 'Track app usage time and find underused subscriptions'
              : 'Premium feature - Upgrade to access',
        ),
        trailing: isPremium
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: isPremium
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsageAnalyticsScreen()),
                )
            : () => _showPremiumDialog(
                context, strings.unlockUsageTracking, strings),
      ),
    );
  }

  Widget _buildReportsSection(
    BuildContext context,
    WidgetRef ref,
    bool isPremium,
    dynamic strings,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.picture_as_pdf,
          color: isPremium ? Colors.red : Colors.grey,
        ),
        title: Row(
          children: [
            Text(strings.generateReport),
            if (!isPremium) ...[
              const SizedBox(width: 8),
              _buildPremiumBadge(),
            ],
          ],
        ),
        subtitle: Text(
          isPremium
              ? 'Generate monthly or yearly reports'
              : 'Premium feature - Upgrade to access',
        ),
        trailing: isPremium
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: isPremium
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                )
            : () => _showPremiumDialog(context,
                'PDF Report Generation is a premium feature.', strings),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPremiumDialog(
      BuildContext context, String message, dynamic strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(strings.premiumFeature),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium purchase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase coming soon!')),
              );
            },
            child: Text(strings.upgradeToPremium),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref,
      AppLanguage currentLanguage, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.language),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: AppLanguages.supportedLanguages.length,
            itemBuilder: (context, index) {
              final language = AppLanguages.supportedLanguages[index];
              final isSelected = language.code == currentLanguage.code;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                title: Text(
                  language.name,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(language.nativeName),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                selected: isSelected,
                onTap: () {
                  ref.read(appLanguageProvider.notifier).setLanguage(language);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.languageChangedTo(language.name)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref,
      String currentCurrency, dynamic strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.baseCurrency),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: Currencies.all.length,
            itemBuilder: (context, index) {
              final currency = Currencies.all[index];
              final isSelected = currency.code == currentCurrency;

              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child:
                      Text(currency.flag, style: const TextStyle(fontSize: 24)),
                ),
                title: Text(
                  '${currency.code} - ${currency.name}',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(currency.symbol),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                selected: isSelected,
                onTap: () async {
                  // Update local state immediately
                  ref
                      .read(baseCurrencyNotifierProvider.notifier)
                      .setCurrency(currency.code);

                  // Also update in Firestore if user is logged in
                  final controller = ref.read(premiumControllerProvider);
                  if (controller != null) {
                    await controller.setBaseCurrency(currency.code);
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Base currency changed to ${currency.code}'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }
}
