import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Authentication-related failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

// Job-specific failures
class JobFailure extends Failure {
  const JobFailure(String message) : super(message);
}

// Helper function to convert exceptions to failures
Failure mapExceptionToFailure(dynamic exception) {
  if (exception is NetworkFailure) {
    return NetworkFailure(exception.message);
  } else if (exception is ServerFailure) {
    return ServerFailure(exception.message);
  } else if (exception is CacheFailure) {
    return CacheFailure(exception.message);
  } else if (exception is AuthenticationFailure) {
    return AuthenticationFailure(exception.message);
  } else if (exception is JobFailure) {
    return JobFailure(exception.message);
  } else {
    return JobFailure('An unexpected error occurred: ${exception.toString()}');
  }
}
