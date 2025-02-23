import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository}) 
    : _profileRepository = profileRepository,
      super(ProfileInitial()) {
    on<CreateProfileRequested>(_onCreateProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<FetchProfileRequested>(_onFetchProfile);
  }

  void _onCreateProfile(
    CreateProfileRequested event, 
    Emitter<ProfileState> emit
  ) async {
    emit(ProfileLoading());
    
    try {
      final result = await _profileRepository.createProfile(event.profile);
      
      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(ProfileError(appError));
        },
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(ProfileError(appError));
    }
  }

  void _onUpdateProfile(
    UpdateProfileRequested event, 
    Emitter<ProfileState> emit
  ) async {
    emit(ProfileLoading());
    
    try {
      final result = await _profileRepository.updateProfile(event.profile);
      
      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(ProfileError(appError));
        },
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(ProfileError(appError));
    }
  }

  void _onFetchProfile(
    FetchProfileRequested event, 
    Emitter<ProfileState> emit
  ) async {
    emit(ProfileLoading());
    
    try {
      final result = await _profileRepository.getProfile(event.userId);
      
      result.fold(
        (failure) {
          final appError = failure.toAppError();
          emit(ProfileError(appError));
        },
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(ProfileError(appError));
    }
  }
}
