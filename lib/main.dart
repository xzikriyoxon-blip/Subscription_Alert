import 'dart:async' show Zone, runZonedGuarded;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'models/subscription.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_providers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/ad_service.dart';
import 'services/widget_service.dart';
import 'services/auth_service.dart';
import 'services/purchase_service.dart';
import 'providers/premium_providers.dart';

/// Entry point of the Subscription Alert application.
/// 
/// Initializes Firebase and notification services before running the app.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // In release builds, widget build/layout exceptions can otherwise degrade into
  // a blank screen. Show a readable error UI instead.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    return Material(
      color: const Color(0xFFF7F7F7),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Catch framework errors.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Also forward into the zone so we get logs in release builds.
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  // Catch async errors.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error');
    debugPrint(stack.toString());
    return true; // handled
  };

  // Always start rendering immediately. All slow/fragile initialization happens
  // inside the bootstrap screen so the user never gets a blank white screen.
  runZonedGuarded(
    () {
      runApp(
        const ProviderScope(
          child: _BootstrapApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught zoned error: $error');
      debugPrint(stack.toString());
    },
  );
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    // Firebase
    // On Android/iOS we should rely on google-services.json / GoogleService-Info.plist.
    // The firebase_options.dart in this repo is placeholder and should NOT be
    // forced on mobile.
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 20));
    } else {
      await Firebase.initializeApp().timeout(const Duration(seconds: 20));
    }

    // Auth persistence
    // On web/desktop, make persistence explicit so users remain signed in until
    // they sign out.
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (e) {
      // Not supported on all platforms (mobile usually manages persistence).
      debugPrint('Bootstrap: setPersistence not supported (continuing): $e');
    }

    // Silent restore (mobile/desktop): if Firebase user is missing on cold
    // start, try to restore a cached Google sign-in without prompting.
    // This helps ensure "stay signed in until sign out".
    try {
      await AuthService()
          .restorePreviousSignInIfPossible()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Bootstrap: silent sign-in restore failed (continuing): $e');
    }

    // Notifications (required for reminders, but should not brick the app).
    final notificationService = NotificationService();
    await notificationService.initialize().timeout(const Duration(seconds: 15));
    await notificationService.requestPermissions().timeout(const Duration(seconds: 30));

    // Ads should never block app launch.
    try {
      final adService = AdService();
      await adService.initialize().timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Bootstrap: Ad init failed (continuing): $e');
    }

    // Initialize in-app purchases
    try {
      final purchaseService = PurchaseService();
      await purchaseService.initialize().timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Bootstrap: Purchase service init failed (continuing): $e');
    }
  }

  void _retry() {
    setState(() {
      _initFuture = _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Subscription Alert',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting…'),
                  ],
                ),
              ),
            ),
          );
        }

        final error = snapshot.error;
        if (error != null) {
          return _BootErrorApp(
            error: error,
            stack: snapshot.stackTrace,
            onRetry: _retry,
          );
        }

        return const SubscriptionAlertApp();
      },
    );
  }
}

class _BootErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stack;
  final VoidCallback? onRetry;

  const _BootErrorApp({
    required this.error,
    required this.stack,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Subscription Alert',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  'App failed to start',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
                if (stack != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    stack.toString(),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Root widget of the application.
/// 
/// Sets up the app theme and handles authentication-based routing.
class SubscriptionAlertApp extends ConsumerWidget {
  const SubscriptionAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp(
      title: 'Subscription Alert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode.toThemeMode(),
      home: const AuthWrapper(),
    );
  }
}

/// Widget that handles authentication state and routes accordingly.
/// 
/// Shows [LoginScreen] if user is not authenticated,
/// [HomeScreen] if user is authenticated.
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> with WidgetsBindingObserver {
  final WidgetService _widgetService = WidgetService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Keep home-screen widget in sync with subscriptions.
    // NOTE: This is Android-only in practice, but calling it elsewhere is harmless.
    _widgetService.initialize().catchError((e) {
      debugPrint('AuthWrapper: WidgetService init failed (continuing): $e');
    });

    ref.listen<List<Subscription>>(subscriptionsProvider, (previous, next) async {
      try {
        final baseCurrency = ref.read(baseCurrencyProvider);
        final totalMonthly = ref.read(totalMonthlyCostProvider);
        await _widgetService.updateWidget(
          subscriptions: next,
          baseCurrency: baseCurrency,
          totalMonthlyInBaseCurrency: totalMonthly,
          isPremium: ref.read(isPremiumProvider),
        );
      } catch (e) {
        debugPrint('AuthWrapper: Failed to update widget: $e');
      }
    });

    ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) async {
      final wasSignedIn = prev?.valueOrNull != null;
      final isSignedIn = next.valueOrNull != null;
      if (wasSignedIn && !isSignedIn) {
        try {
          await _widgetService.clearWidgetData();
        } catch (e) {
          debugPrint('AuthWrapper: Failed to clear widget data: $e');
        }
      }
    });

    // Schedule notification rescheduling after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      () async {
        try {
          await _rescheduleNotifications();
        } catch (e) {
          debugPrint('AuthWrapper: Failed to reschedule notifications: $e');
        }

        // Show app open ad on first launch
        try {
          await _showAppOpenAd();
        } catch (e) {
          debugPrint('AuthWrapper: Failed to show app open ad: $e');
        }
      }();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Show app open ad when app is resumed from background
      () async {
        try {
          await _showAppOpenAd();
        } catch (e) {
          debugPrint('AuthWrapper: Failed to show app open ad on resume: $e');
        }
      }();
    }
  }

  /// Show app open ad for non-premium users.
  Future<void> _showAppOpenAd() async {
    // Small delay to let the UI settle
    await Future.delayed(const Duration(milliseconds: 500));
    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium) {
      await AdService().showAppOpenAd();
    }
  }

  /// Reschedules all notifications when app starts.
  /// 
  /// This ensures notifications are up-to-date even if the app
  /// was closed for a while.
  Future<void> _rescheduleNotifications() async {
    final controller = ref.read(subscriptionControllerProvider);
    final subscriptions = ref.read(subscriptionsProvider);
    
    if (controller != null && subscriptions.isNotEmpty) {
      await controller.rescheduleAllNotifications(subscriptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text('Failed to initialize authentication'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(authStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        // If user is signed in, show home screen
        // Otherwise, show login screen
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
