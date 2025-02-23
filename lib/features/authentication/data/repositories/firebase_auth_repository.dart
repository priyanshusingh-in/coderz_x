import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/enums/auth_type.dart';

import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _userIdKey = 'user_id';
  static const String _displayNameKey = 'display_name';
  static const String _emailKey = 'user_email';
  static const String _authTypeKey = 'auth_type';

  @override
  Future<AuthResult> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      final displayName = prefs.getString(_displayNameKey);
      final email = prefs.getString(_emailKey);
      final authTypeStr = prefs.getString(_authTypeKey);

      // Check Firebase current user as a fallback
      final currentUser = _firebaseAuth.currentUser;

      if (userId == null && currentUser == null) {
        return AuthResult.error(message: 'No user signed in');
      }

      AuthType authType = AuthType.unknown;
      if (authTypeStr != null) {
        authType = authTypeStr == 'google' ? AuthType.google : 
                   authTypeStr == 'apple' ? AuthType.apple : 
                   AuthType.unknown;
      }

      return AuthResult.success(
        userId: userId ?? currentUser?.uid,
        displayName: displayName ?? currentUser?.displayName,
        email: email ?? currentUser?.email,
        authType: authType,
      );
    } catch (e) {
      return AuthResult.error(message: 'Failed to get current user: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error(message: 'Google Sign-In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResult.error(message: 'Invalid Google Sign-In credentials');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.error(message: 'Failed to retrieve user details');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, firebaseUser.uid);
      await prefs.setString(_displayNameKey, firebaseUser.displayName ?? '');
      await prefs.setString(_emailKey, firebaseUser.email ?? '');
      await prefs.setString(_authTypeKey, 'google');

      return AuthResult.success(
        userId: firebaseUser.uid,
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        authType: AuthType.google,
      );
    } catch (e) {
      return AuthResult.error(message: 'Google Sign-In failed: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      // Perform Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Firebase credential
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Ensure non-null user ID
      final userId = userCredential.user?.uid;
      if (userId == null) {
        return AuthResult.error(message: 'Failed to retrieve user ID');
      }

      // Save user details to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_displayNameKey,
          appleCredential.givenName ?? userCredential.user?.displayName ?? '');
      await prefs.setString(_emailKey, userCredential.user?.email ?? '');

      return AuthResult.success(
        userId: userId,
        displayName:
            appleCredential.givenName ?? userCredential.user?.displayName ?? '',
        email: userCredential.user?.email ?? '',
        authType: AuthType.apple,
      );
    } catch (e) {
      return AuthResult.error(message: 'Apple Sign-In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google if signed in with Google
      await _googleSignIn.signOut();

      // Clear stored user preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_displayNameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_authTypeKey);
    } catch (e) {
      // Handle sign-out errors
      print('Sign out error: $e');
    }
  }
}
