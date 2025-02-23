part of 'job_detail_bloc.dart';

abstract class JobDetailState extends Equatable {
  const JobDetailState();

  @override
  List<Object?> get props => [];
}

class JobDetailInitial extends JobDetailState {}

class JobDetailLoading extends JobDetailState {}

class JobDetailLoaded extends JobDetailState {
  final JobEntity job;

  const JobDetailLoaded({required this.job});

  @override
  List<Object?> get props => [job];
}

class JobDetailError extends JobDetailState {
  final String message;

  const JobDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
