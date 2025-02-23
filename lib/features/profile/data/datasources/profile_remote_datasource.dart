import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSource({required FirebaseFirestore firestore}) 
    : _firestore = firestore;

  Future<ProfileEntity> createProfile(ProfileEntity profile) async {
    try {
      await _firestore
        .collection('users')
        .doc(profile.userId)
        .set(profile.toMap());
      return profile;
    } catch (e) {
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }

  Future<ProfileEntity> updateProfile(ProfileEntity profile) async {
    try {
      await _firestore
        .collection('users')
        .doc(profile.userId)
        .update(profile.toMap());
      return profile;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<ProfileEntity?> getProfile(String userId) async {
    try {
      final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
      
      if (!doc.exists) return null;

      return ProfileEntity.fromMap(
        doc.data() ?? {}, 
        userId
      );
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }
}
