import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Service class for handling Firebase Authentication with Google Sign-In.
/// 
/// Provides methods for signing in, signing out, and accessing the current user.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb 
        ? '537197819060-sa7fb612732t24o9ivt5p8gj9ssdhps0.apps.googleusercontent.com'
        : null,
  );

  /// Returns a stream of authentication state changes.
  /// 
  /// Emits the current user when auth state changes (sign in/out).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Returns the currently signed-in user, or null if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Attempts to restore a previous Google sign-in silently.
  ///
  /// Why this exists:
  /// - Firebase Auth should normally persist on mobile/desktop, but some setups
  ///   (or certain platform/plugin edge cases) can result in `currentUser`
  ///   being null after a cold start.
  /// - Google Sign-In can often restore the last account without UI.
  ///
  /// This method:
  /// - does nothing if a Firebase user already exists
  /// - does nothing on web (handled via Firebase persistence)
  /// - never shows UI (silent only)
  Future<void> restorePreviousSignInIfPossible() async {
    if (kIsWeb) return;
    if (_firebaseAuth.currentUser != null) return;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (_) {
      // Ignore restore failures; user can always sign in manually.
    }
  }

  /// Signs in the user with Google.
  /// 
  /// Returns the [UserCredential] on success, throws an exception on failure.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Ensure persistence so the user stays signed in across reloads.
        try {
          await _firebaseAuth.setPersistence(Persistence.LOCAL);
        } catch (_) {
          // Ignore if unsupported.
        }

        // Web: Use Firebase Auth directly with popup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        return await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the sign-in
          return null;
        }

        // Obtain the auth details from the Google Sign-In
        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;

        // Create a new credential for Firebase
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        return await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      throw AuthException('Error: ${e.runtimeType} - $e');
    }
  }

  /// Signs out the current user from both Firebase and Google.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      // Ensure Google Sign-In session is cleared so we don't immediately
      // restore via signInSilently on next launch.
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
