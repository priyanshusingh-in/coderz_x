import '../enums/auth_type.dart';

abstract class AuthRepository {
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<void> signOut();
  Future<AuthResult> getCurrentUser();
}

class AuthResult {
  final bool isSuccess;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? errorMessage;
  final AuthType? authType;

  AuthResult._({
    required this.isSuccess,
    this.userId,
    this.email,
    this.displayName,
    this.errorMessage,
    this.authType,
  });

  factory AuthResult.success({
    required String? userId,
    required String? email,
    required String? displayName,
    required AuthType authType,
  }) {
    return AuthResult._(
      isSuccess: true,
      userId: userId,
      email: email,
      displayName: displayName,
      authType: authType,
    );
  }

  factory AuthResult.error({required String message}) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  factory AuthResult.cancelled() {
    return AuthResult._(
      isSuccess: false,
      errorMessage: 'Authentication cancelled',
    );
  }
}
