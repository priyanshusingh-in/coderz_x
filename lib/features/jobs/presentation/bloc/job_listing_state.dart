part of 'job_listing_bloc.dart';

abstract class JobListingState extends Equatable {
  const JobListingState();
  
  @override
  List<Object> get props => [];
}

class JobListingInitial extends JobListingState {}

class JobListingLoading extends JobListingState {}

class JobListingLoaded extends JobListingState {
  final List<JobModel> jobs;

  const JobListingLoaded(this.jobs);

  @override
  List<Object> get props => [jobs];
}

class JobListingError extends JobListingState {
  final String message;

  const JobListingError(this.message);

  @override
  List<Object> get props => [message];
}

class JobBookmarkSuccess extends JobListingLoaded {
  const JobBookmarkSuccess(List<JobModel> jobs) : super(jobs);
}
