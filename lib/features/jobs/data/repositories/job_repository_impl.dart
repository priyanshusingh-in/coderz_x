import 'package:coderz_x/core/errors/failures.dart';
import 'package:coderz_x/features/jobs/domain/entities/job_entity.dart';
import 'package:coderz_x/features/jobs/domain/enums/job_type.dart';
import 'package:coderz_x/features/jobs/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/network_info.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  JobRepositoryImpl({
    required JobRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({
    String? searchQuery,
    JobType? jobType,
    String? location,
    List<String>? requirements = const [],
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final jobs = await _remoteDataSource.getJobs(
          searchQuery: searchQuery,
          jobType: jobType,
          location: location,
          requirements: requirements,
        );
        return Right(jobs);
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobEntity>> getJobById(
    String jobId, {
    List<String>? requirements = const [],
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final job = await _remoteDataSource.getJobById(jobId);
        return Right(job);
      } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<ServerFailure, void>> openJobApplicationUrl(String applicationUrl) async {
    try {
      final success = await launchUrl(Uri.parse(applicationUrl));
      if (!success) {
        return Left(ServerFailure('Could not launch $applicationUrl'));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to open job application URL: ${e.toString()}'));
    }
  }
}
