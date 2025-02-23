part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class GoogleSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class CheckAuthStatusRequested extends AuthEvent {}
