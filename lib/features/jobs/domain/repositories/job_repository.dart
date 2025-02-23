import 'package:coderz_x/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/job_entity.dart';
import '../enums/job_type.dart';

abstract class JobRepository {
  // Fetch jobs with optional filtering
  Future<Either<Failure, List<JobEntity>>> getJobs({
    String? searchQuery,
    JobType? jobType,
    String? location,
    List<String>? requirements = const [],
  });

  // Get job details by ID
  Future<Either<Failure, JobEntity>> getJobById(String jobId,
      {List<String>? requirements = const []});

  // Open job application URL
  Future<Either<ServerFailure, void>> openJobApplicationUrl(String applicationUrl);
}
