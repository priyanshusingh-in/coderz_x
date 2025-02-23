part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String displayName;
  final AuthType type;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.type
  });

  @override
  List<Object?> get props => [userId, email, displayName, type];
}

class AuthError extends AuthState {
  final AppError error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}
