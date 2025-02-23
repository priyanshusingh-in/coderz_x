import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ProfileEntity>> createProfile(ProfileEntity profile) async {
    if (await _networkInfo.isConnected) {
      try {
        final createdProfile = await _remoteDataSource.createProfile(profile);
        return Right(createdProfile);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile) async {
    if (await _networkInfo.isConnected) {
      try {
        final updatedProfile = await _remoteDataSource.updateProfile(profile);
        return Right(updatedProfile);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final profile = await _remoteDataSource.getProfile(userId);
        if (profile == null) {
          return Left(CacheFailure('Profile not found'));
        }
        return Right(profile);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
