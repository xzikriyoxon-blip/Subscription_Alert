import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Provider for the AuthService singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider that streams the current authentication state.
/// 
/// Emits the current [User] when signed in, or null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the current user's ID.
/// 
/// Returns null if the user is not signed in.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid;
});

/// Provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return userId != null;
});
