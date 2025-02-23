import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppError {
  final String message;
  final ErrorType type;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    required this.type,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError: $message (Type: $type)';
  }
}

enum ErrorType {
  network,
  authentication,
  database,
  validation,
  permission,
  unknown,
}

class ErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is AppError) return error;

    // Network Errors
    if (error is SocketException) {
      return AppError(
        message: 'No internet connection. Please check your network settings.',
        type: ErrorType.network,
        stackTrace: StackTrace.current,
      );
    }

    // Firebase Authentication Errors
    if (error is FirebaseAuthException) {
      return AppError(
        message: _mapFirebaseAuthError(error),
        type: ErrorType.authentication,
        stackTrace: StackTrace.current,
      );
    }

    // Platform Exceptions
    if (error is PlatformException) {
      return AppError(
        message: error.message ?? 'An unexpected platform error occurred.',
        type: ErrorType.permission,
        stackTrace: StackTrace.current,
      );
    }

    // Timeout Errors
    if (error is TimeoutException) {
      return AppError(
        message: 'Operation timed out. Please try again.',
        type: ErrorType.network,
        stackTrace: StackTrace.current,
      );
    }

    // Generic Error Handling
    return AppError(
      message: error.toString(),
      type: ErrorType.unknown,
      stackTrace: error is Error ? error.stackTrace : null,
    );
  }

  static String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static void logError(AppError error) {
    if (kDebugMode) {
      print('Error Type: ${error.type}');
      print('Error Message: ${error.message}');
      if (error.stackTrace != null) {
        print('Stack Trace: ${error.stackTrace}');
      }
    }
    
    // TODO: Implement crash reporting (e.g., Firebase Crashlytics)
    // FirebaseCrashlytics.instance.recordError(
    //   error.message,
    //   error.stackTrace,
    //   fatal: false,
    // );
  }

  static void handleUncaughtErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final appError = handleError(details.exception);
      logError(appError);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      final appError = handleError(error);
      logError(appError);
      return true;
    };
  }
}

// Extension for easy error handling
extension ErrorHandling on Object {
  AppError toAppError() => ErrorHandler.handleError(this);
}
