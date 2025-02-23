part of 'job_bloc.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<JobEntity> jobs;

  const JobLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobError extends JobState {
  final AppError error;

  const JobError(this.error);

  @override
  List<Object?> get props => [error];
}
