library auth_bloc;

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/auth_repository.dart' as repo;
import '../../domain/enums/auth_type.dart';

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
        add(CheckAuthStatusRequested());
      },
    );
  }

  void _onGoogleSignIn(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signInWithGoogle();

      if (result.isSuccess) {
        emit(AuthAuthenticated(
            userId: result.userId!,
            email: result.email ?? '',
            displayName: result.displayName ?? '',
            type: result.authType ?? AuthType.google));
      } else {
        emit(AuthError(AppError(
          message: result.errorMessage ?? 'Google sign in failed',
          type: ErrorType.authentication,
        )));
      }
    } catch (error) {
      emit(AuthError(AppError(
        message: error.toString(),
        type: ErrorType.authentication,
      )));
    }
  }

  void _onAppleSignIn(
      AppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await _authRepository.signInWithApple();

      if (result.isSuccess) {
        emit(AuthAuthenticated(
            userId: result.userId!,
            email: result.email ?? '',
            displayName: result.displayName ?? '',
            type: result.authType ?? AuthType.apple));
      } else {
        emit(AuthError(AppError(
          message: result.errorMessage ?? 'Apple sign in failed',
          type: ErrorType.authentication,
        )));
      }
    } catch (error) {
      emit(AuthError(AppError(
        message: error.toString(),
        type: ErrorType.authentication,
      )));
    }
  }

  void _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } catch (error) {
      emit(AuthError(AppError(
        message: error.toString(),
        type: ErrorType.authentication,
      )));
    }
  }

  void _onCheckAuthStatus(
      CheckAuthStatusRequested event, Emitter<AuthState> emit) async {
    try {
      final result = await _authRepository.getCurrentUser();

      if (result.isSuccess && result.userId != null) {
        emit(AuthAuthenticated(
            userId: result.userId!,
            email: result.email ?? '',
            displayName: result.displayName ?? '',
            type: result.authType ?? AuthType.google));
      } else {
        emit(AuthInitial());
      }
    } catch (error) {
      emit(AuthError(AppError(
        message: error.toString(),
        type: ErrorType.authentication,
      )));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
} // End of AuthBloc class
