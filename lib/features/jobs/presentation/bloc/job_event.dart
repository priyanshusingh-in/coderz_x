part of 'job_bloc.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class FetchJobsRequested extends JobEvent {}

class SearchJobsRequested extends JobEvent {
  final String query;

  const SearchJobsRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class FilterJobsRequested extends JobEvent {
  final JobType? jobType;
  final String? location;

  const FilterJobsRequested({
    this.jobType,
    this.location,
  });

  @override
  List<Object?> get props => [jobType, location];
}

class SearchAndFilterJobsRequested extends JobEvent {
  final String query;
  final JobType? jobType;
  final String? location;

  const SearchAndFilterJobsRequested({
    required this.query,
    this.jobType,
    this.location,
  });

  @override
  List<Object?> get props => [query, jobType, location];
}

class RemoveBookmarkRequested extends JobEvent {
  final String jobId;

  const RemoveBookmarkRequested(this.jobId);

  @override
  List<Object> get props => [jobId];
}

class FetchBookmarkedJobsRequested extends JobEvent {
  @override
  List<Object> get props => [];
}
