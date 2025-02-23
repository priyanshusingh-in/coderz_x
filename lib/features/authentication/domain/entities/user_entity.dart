import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? providerId;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providerId,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, providerId];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? providerId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId ?? this.providerId,
    );
  }
}
