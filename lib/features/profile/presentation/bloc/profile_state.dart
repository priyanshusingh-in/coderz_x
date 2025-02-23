part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileCreated extends ProfileState {
  final ProfileEntity profile;

  const ProfileCreated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfilePictureUploaded extends ProfileState {
  final String imageUrl;

  const ProfilePictureUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ProfileError extends ProfileState {
  final AppError error;

  const ProfileError(this.error);

  @override
  List<Object?> get props => [error];
}
