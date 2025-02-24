import 'package:equatable/equatable.dart';
import '../enums/auth_type.dart';
import '../repositories/auth_repository.dart';

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

    final email = result.email ?? '';
    final displayName = result.displayName ?? 'User';
    final authType = result.authType ?? AuthType.unknown;

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
      userId: map['userId']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      authType: _parseAuthType(map['authType']?.toString() ?? ''),
    );
  }

  factory PigeonUserDetails.fromList(List<Object?> list) {
    if (list.length < 4) {
      throw Exception('Invalid list format for PigeonUserDetails');
    }

    final Map<String, dynamic> map = {
      'userId': list[0],
      'email': list[1],
      'displayName': list[2],
      'authType': list[3]
    };

    return PigeonUserDetails.fromMap(map);
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