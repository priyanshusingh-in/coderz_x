part of 'job_listing_bloc.dart';

abstract class JobListingEvent extends Equatable {
  const JobListingEvent();

  @override
  List<Object> get props => [];
}

class FetchJobsEvent extends JobListingEvent {}

class SearchJobsEvent extends JobListingEvent {
  final String query;

  const SearchJobsEvent(this.query);

  @override
  List<Object> get props => [query];
}
