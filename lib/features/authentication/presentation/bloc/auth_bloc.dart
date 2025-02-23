library auth_bloc;

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/auth_repository.dart' as repo;
import '../../domain/enums/auth_type.dart';
import '../../domain/models/pigeon_user_details.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final repo.AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required repo.AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<AppleSignInRequested>(_onAppleSignIn);
    on<SignOutRequested>(_onSignOut);
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);

    // Listen to Firebase auth state changes
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          add(SignOutRequested());
        }
      },
      onError: (error) {
        emit(AuthError(AppError(
          message: 'Authentication state error: ${error.toString()}',
          type: ErrorType.authentication,
        )));
      },
    );
  }

  void _onGoogleSignIn(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signInWithGoogle();

      if (result.isSuccess) {
        try {
          // Add a delay to ensure Firebase auth state is fully updated
          await Future.delayed(const Duration(seconds: 1));
          
          final userDetails = PigeonUserDetails.fromAuthResult(result);
          
          // Verify the current Firebase user matches our authenticated user
          final currentUser = await _authRepository.getCurrentUser();
          if (currentUser.isSuccess && currentUser.userId == userDetails.userId) {
            emit(AuthAuthenticated(
                userId: userDetails.userId,
                email: userDetails.email,
                displayName: userDetails.displayName,
                type: userDetails.authType));
          } else {
            throw Exception('Failed to verify authenticated user');
          }
        } catch (e) {
          final appError = AppError(
              message: 'Authentication state verification failed: ${e.toString()}',
              type: ErrorType.authentication);
          emit(AuthError(appError));
        }
      } else {
        final appError = AppError(
            message: result.errorMessage ?? 'Authentication failed',
            type: ErrorType.authentication);
        emit(AuthError(appError));
      }
    } catch (e) {
      final appError = AppError(
          message: e.toString(),
          type: ErrorType.authentication);
      emit(AuthError(appError));
    }
  }

  void _onAppleSignIn(
      AppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signInWithApple();

      if (result.isSuccess) {
        try {
          // Add a delay to ensure Firebase auth state is fully updated
          await Future.delayed(const Duration(seconds: 1));
          
          final userDetails = PigeonUserDetails.fromAuthResult(result);
          
          // Verify the current Firebase user matches our authenticated user
          final currentUser = await _authRepository.getCurrentUser();
          if (currentUser.isSuccess && currentUser.userId == userDetails.userId) {
            emit(AuthAuthenticated(
                userId: userDetails.userId,
                email: userDetails.email,
                displayName: userDetails.displayName,
                type: userDetails.authType));
          } else {
            throw Exception('Failed to verify authenticated user');
          }
        } catch (e) {
          final appError = AppError(
              message: 'Authentication state verification failed: ${e.toString()}',
              type: ErrorType.authentication);
          emit(AuthError(appError));
        }
      } else {
        final appError = AppError(
            message: result.errorMessage ?? 'Authentication failed',
            type: ErrorType.authentication);
        emit(AuthError(appError));
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      ErrorHandler.logError(appError);
      emit(AuthError(appError));
    }
  }

  void _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } catch (error) {
      final appError = ErrorHandler.handleError(error);
      ErrorHandler.logError(appError);
      emit(AuthError(appError));
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }

  void _onCheckAuthStatus(
      CheckAuthStatusRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(AuthInitial());
        return;
      }

      final result = await _authRepository.getCurrentUser();

      if (result.isSuccess) {
        try {
          final userDetails = PigeonUserDetails.fromAuthResult(result);
          
          // Verify the current Firebase user matches our authenticated user
          if (currentUser.uid == userDetails.userId) {
            emit(AuthAuthenticated(
                userId: userDetails.userId,
                email: userDetails.email,
                displayName: userDetails.displayName,
                type: userDetails.authType));
          } else {
            emit(AuthInitial());
          }
        } catch (e) {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }
} // End of AuthBloc class


