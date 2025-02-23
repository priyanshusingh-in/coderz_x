import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/job_model.dart';
import '../../domain/repositories/job_repository.dart';

part 'job_listing_event.dart';
part 'job_listing_state.dart';

class JobListingBloc extends Bloc<JobListingEvent, JobListingState> {
  final JobRepository _jobRepository;

  JobListingBloc(this._jobRepository) : super(JobListingInitial()) {
    on<FetchJobsEvent>(_onFetchJobs);
    on<SearchJobsEvent>(_onSearchJobs);
  }

  void _onFetchJobs(FetchJobsEvent event, Emitter<JobListingState> emit) async {
    emit(JobListingLoading());

    try {
      final result = await _jobRepository.getJobs();

      result.fold(
        (failure) => emit(JobListingError(failure.message)),
        (jobs) => emit(JobListingLoaded(jobs
            .map((job) => JobModel(
                  id: job.id,
                  title: job.title,
                  company: job.company,
                  location: job.location,
                  description: job.description,
                  requirements: job.requirements,
                  type: job.type,
                  salary: job.salary,
                  postedDate: job.postedDate,
                  skills: job.skills,
                  applicationUrl: job.applicationUrl,
                ))
            .toList())),
      );
    } catch (e) {
      emit(JobListingError('Failed to fetch jobs'));
    }
  }

  void _onSearchJobs(
      SearchJobsEvent event, Emitter<JobListingState> emit) async {
    emit(JobListingLoading());

    try {
      final result = await _jobRepository.getJobs(
        searchQuery: event.query,
      );

      result.fold(
        (failure) => emit(JobListingError(failure.message)),
        (jobs) => emit(JobListingLoaded(jobs
            .map((job) => JobModel(
                  id: job.id,
                  title: job.title,
                  company: job.company,
                  location: job.location,
                  description: job.description,
                  requirements: job.requirements,
                  type: job.type,
                  salary: job.salary,
                  postedDate: job.postedDate,
                  skills: job.skills,
                  applicationUrl: job.applicationUrl,
                ))
            .toList())),
      );
    } catch (e) {
      emit(JobListingError('Failed to search jobs'));
    }
  }
}
