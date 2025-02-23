import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profession;
  final String? skills;
  final String? location;
  final DateTime? dateOfBirth;

  const ProfileEntity({
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profession,
    this.skills,
    this.location,
    this.dateOfBirth,
  });

  ProfileEntity copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profession,
    String? skills,
    String? location,
    DateTime? dateOfBirth,
  }) {
    return ProfileEntity(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profession: profession ?? this.profession,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profession': profession,
      'skills': skills,
      'location': location,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  factory ProfileEntity.fromMap(Map<String, dynamic> map, String userId) {
    return ProfileEntity(
      userId: userId,
      fullName: map['fullName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profession: map['profession'],
      skills: map['skills'],
      location: map['location'],
      dateOfBirth: map['dateOfBirth'] != null 
        ? DateTime.parse(map['dateOfBirth']) 
        : null,
    );
  }

  @override
  List<Object?> get props => [
    userId, fullName, email, phoneNumber, 
    profession, skills, location, dateOfBirth
  ];
}
