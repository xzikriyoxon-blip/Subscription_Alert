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
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
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

  /// Signs in the user with email and password.
  ///
  /// Returns the [UserCredential] on success, throws an exception on failure.
  /// Throws [EmailNotVerifiedException] if the email is not verified.
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (credential.user != null && !credential.user!.emailVerified) {
        // Sign out and throw exception
        await _firebaseAuth.signOut();
        throw EmailNotVerifiedException(
          'Please verify your email before signing in. Check your inbox for the verification link.',
        );
      }

      return credential;
    } on EmailNotVerifiedException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email address.');
        case 'wrong-password':
          throw AuthException('Incorrect password. Please try again.');
        case 'invalid-email':
          throw AuthException('Please enter a valid email address.');
        case 'user-disabled':
          throw AuthException('This account has been disabled.');
        case 'invalid-credential':
          throw AuthException('Invalid email or password.');
        default:
          throw AuthException('Sign in failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Creates a new user account with email and password.
  ///
  /// Returns the [UserCredential] on success, throws an exception on failure.
  /// Automatically sends a verification email after successful sign-up.
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      await credential.user?.sendEmailVerification();

      // Sign out immediately - user must verify email first
      await _firebaseAuth.signOut();

      return credential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException('An account already exists with this email.');
        case 'invalid-email':
          throw AuthException('Please enter a valid email address.');
        case 'weak-password':
          throw AuthException(
              'Password is too weak. Use at least 6 characters.');
        case 'operation-not-allowed':
          throw AuthException('Email/password sign up is not enabled.');
        default:
          throw AuthException('Sign up failed: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Checks if the current user's email is verified.
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Resends the verification email to the current user.
  Future<void> resendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('No user is signed in.');
    }
    if (user.emailVerified) {
      throw AuthException('Email is already verified.');
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to send verification email: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to send verification email: $e');
    }
  }

  /// Reloads the current user to check for email verification status updates.
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email address.');
        case 'invalid-email':
          throw AuthException('Please enter a valid email address.');
        default:
          throw AuthException('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Failed to send reset email: $e');
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

/// Exception thrown when email verification is required.
class EmailNotVerifiedException implements Exception {
  final String message;

  EmailNotVerifiedException(this.message);

  @override
  String toString() => message;
}
