import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../domain/enums/job_type.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;

  JobBloc({required JobRepository jobRepository})
      : _jobRepository = jobRepository,
        super(JobInitial()) {
    on<FetchJobsRequested>(_onFetchJobs);
    on<SearchJobsRequested>(_onSearchJobs);
    on<FilterJobsRequested>(_onFilterJobs);
    on<SearchAndFilterJobsRequested>(_onSearchAndFilterJobs);
  }

  void _onFetchJobs(FetchJobsRequested event, Emitter<JobState> emit) async {
    emit(JobLoading());

    try {
      final result = await _jobRepository.getJobs();

      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(JobError(appError));
        },
        (jobs) => emit(JobLoaded(jobs)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(JobError(appError));
    }
  }

  void _onSearchJobs(SearchJobsRequested event, Emitter<JobState> emit) async {
    emit(JobLoading());

    try {
      final result = await _jobRepository.getJobs(searchQuery: event.query);

      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(JobError(appError));
        },
        (jobs) => emit(JobLoaded(jobs)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(JobError(appError));
    }
  }

  void _onFilterJobs(FilterJobsRequested event, Emitter<JobState> emit) async {
    emit(JobLoading());

    try {
      final result = await _jobRepository.getJobs(
        location: event.location,
        jobType: event.jobType,
      );

      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(JobError(appError));
        },
        (jobs) => emit(JobLoaded(jobs)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(JobError(appError));
    }
  }

  void _onSearchAndFilterJobs(
    SearchAndFilterJobsRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());

    try {
      final result = await _jobRepository.getJobs(
        searchQuery: event.query,
        location: event.location,
        jobType: event.jobType,
      );

      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(JobError(appError));
        },
        (jobs) => emit(JobLoaded(jobs)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(JobError(appError));
    }
  }
}
