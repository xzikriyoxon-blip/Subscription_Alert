import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_providers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/ad_service.dart';

/// Entry point of the Subscription Alert application.
/// 
/// Initializes Firebase and notification services before running the app.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize AdMob
  final adService = AdService();
  await adService.initialize();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: SubscriptionAlertApp(),
    ),
  );
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

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Schedule notification rescheduling after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rescheduleNotifications();
    });
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
