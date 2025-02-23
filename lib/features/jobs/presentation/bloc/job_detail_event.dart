part of 'job_detail_bloc.dart';

abstract class JobDetailEvent extends Equatable {
  const JobDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchJobDetailRequested extends JobDetailEvent {
  final String jobId;

  const FetchJobDetailRequested({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}
