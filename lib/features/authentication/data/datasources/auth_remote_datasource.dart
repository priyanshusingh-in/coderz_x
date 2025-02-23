import 'package:coderz_x/features/authentication/domain/enums/auth_type.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    required firebase.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error(message: 'Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final firebase.AuthCredential credential =
          firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final firebase.User? user = userCredential.user;
      if (user == null) {
        return AuthResult.error(message: 'Failed to sign in with Google');
      }

      return AuthResult.success(
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        authType: AuthType.google,
      );
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  Future<AuthResult> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final firebase.OAuthCredential credential =
          firebase.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final firebase.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final firebase.User? user = userCredential.user;
      if (user == null) {
        return AuthResult.error(message: 'Failed to sign in with Apple');
      }

      return AuthResult.success(
        userId: user.uid,
        email: user.email,
        displayName: appleCredential.givenName ?? user.displayName,
        authType: AuthType.apple,
      );
    } catch (e) {
      return AuthResult.error(message: e.toString());
    }
  }

  Future<AuthResult> getCurrentUser() async {
    final firebase.User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return AuthResult.error(message: 'No user signed in');
    }

    return AuthResult.success(
      userId: user.uid,
      email: user.email,
      displayName: user.displayName,
      authType: AuthType.unknown,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
