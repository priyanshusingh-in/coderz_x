import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';

part 'job_detail_event.dart';
part 'job_detail_state.dart';

class JobDetailBloc extends Bloc<JobDetailEvent, JobDetailState> {
  final JobRepository _jobRepository;

  JobDetailBloc({required JobRepository jobRepository}) 
    : _jobRepository = jobRepository, 
      super(JobDetailInitial()) {
    on<FetchJobDetailRequested>(_onFetchJobDetail);
  }

  void _onFetchJobDetail(
    FetchJobDetailRequested event, 
    Emitter<JobDetailState> emit
  ) async {
    emit(JobDetailLoading());
    
    try {
      final result = await _jobRepository.getJobById(event.jobId);
      
      result.fold(
        (failure) => emit(JobDetailError(message: failure.message)),
        (job) => emit(JobDetailLoaded(job: job))
      );
    } catch (e) {
      emit(JobDetailError(message: 'Failed to load job details'));
    }
  }
}
