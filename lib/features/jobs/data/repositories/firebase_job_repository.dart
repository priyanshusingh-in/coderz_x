import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/enums/job_type.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_local_datasource.dart';
import '../datasources/job_remote_datasource.dart';

class FirebaseJobRepository implements JobRepository {
  final JobLocalDataSource _localDataSource = JobLocalDataSource();
  final JobRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final FirebaseFirestore _firestore;

  FirebaseJobRepository({
    required JobRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required FirebaseFirestore firestore,
  })
      : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _firestore = firestore;

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
      } catch (e) {
        // If remote fetch fails, fall back to local data
        return _getLocalJobs(
          searchQuery: searchQuery,
          jobType: jobType,
          location: location,
          requirements: requirements,
        );
      }
    } else {
      return _getLocalJobs(
        searchQuery: searchQuery,
        jobType: jobType,
        location: location,
        requirements: requirements,
      );
    }
  }

  Future<Either<Failure, List<JobEntity>>> _getLocalJobs({
    String? searchQuery,
    JobType? jobType,
    String? location,
    List<String>? requirements = const [],
  }) async {
    try {
      final jobs = await _localDataSource.getJobs(
        searchQuery: searchQuery,
        jobType: jobType,
        location: location,
        requirements: requirements,
      );
      return Right(jobs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
      } catch (e) {
        // If remote fetch fails, fall back to local data
        return _getLocalJobById(jobId);
      }
    } else {
      return _getLocalJobById(jobId);
    }
  }

  Future<Either<Failure, JobEntity>> _getLocalJobById(String jobId) async {
    try {
      final job = await _localDataSource.getJobById(jobId);
      return Right(job);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  Future<bool> launchJobUrl(String url) async {
    try {
      final Uri parsedUrl = Uri.parse(url);
      return await launchUrl(parsedUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<ServerFailure, void>> openJobApplicationUrl(String applicationUrl) async {
    try {
      final success = await launchJobUrl(applicationUrl);
      if (!success) {
        return Left(ServerFailure('Could not launch $applicationUrl'));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to open job application URL: ${e.toString()}'));
    }
  }

  // Method to get application URL for a specific job
  Future<String?> getJobApplicationUrl(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      
      if (!doc.exists) {
        return null;
      }

      final jobData = doc.data();
      return jobData?['applicationUrl'];
    } catch (e) {
      print('Error fetching job application URL: $e');
      return null;
    }
  }
}
