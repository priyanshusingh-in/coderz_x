import 'package:equatable/equatable.dart';
import '../../domain/enums/auth_type.dart';
import '../../domain/repositories/auth_repository.dart';

class PigeonUserDetails extends Equatable {
  final String userId;
  final String email;
  final String displayName;
  final AuthType authType;

  const PigeonUserDetails({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.authType,
  });

  factory PigeonUserDetails.fromAuthResult(AuthResult result) {
    if (!result.isSuccess || result.userId == null || result.userId!.isEmpty) {
      throw Exception('Invalid authentication result: ${result.errorMessage ?? 'Unknown error'}');
    }

    // Ensure we have valid values for all required fields
    final email = result.email ?? '';
    final displayName = result.displayName ?? 'User';
    final authType = result.authType ?? AuthType.unknown;

    // Validate and sanitize the data
    if (email.isEmpty && displayName.isEmpty) {
      throw Exception('Both email and display name cannot be empty');
    }

    return PigeonUserDetails(
      userId: result.userId!,
      email: email,
      displayName: displayName,
      authType: authType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'authType': authType.toString(),
    };
  }

  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      userId: map['userId'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      authType: _parseAuthType(map['authType'] as String),
    );
  }

  static AuthType _parseAuthType(String value) {
    switch (value) {
      case 'AuthType.google':
        return AuthType.google;
      case 'AuthType.apple':
        return AuthType.apple;
      default:
        return AuthType.unknown;
    }
  }

  @override
  List<Object?> get props => [userId, email, displayName, authType];
}