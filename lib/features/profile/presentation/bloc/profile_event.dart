part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class CreateProfileRequested extends ProfileEvent {
  final ProfileEntity profile;

  const CreateProfileRequested({required this.profile});

  @override
  List<Object> get props => [profile];
}

class UpdateProfileRequested extends ProfileEvent {
  final ProfileEntity profile;

  const UpdateProfileRequested({required this.profile});

  @override
  List<Object> get props => [profile];
}

class FetchProfileRequested extends ProfileEvent {
  final String userId;

  const FetchProfileRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}
