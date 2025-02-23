import 'package:equatable/equatable.dart';

class PigeonUserDetails extends Equatable {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final List<String>? providers;

  const PigeonUserDetails({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.providers,
  });

  factory PigeonUserDetails.fromMap(Map<String, dynamic> map) {
    return PigeonUserDetails(
      uid: map['uid'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      providers: (map['providers'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'providers': providers,
    };
  }

  PigeonUserDetails copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? providers,
  }) {
    return PigeonUserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      providers: providers ?? this.providers,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoURL, providers];
}