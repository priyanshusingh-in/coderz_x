import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../../features/jobs/data/datasources/job_remote_datasource.dart';
import '../../features/jobs/data/repositories/job_repository_impl.dart';
import '../../features/jobs/domain/repositories/job_repository.dart';
import '../../features/jobs/presentation/bloc/job_bloc.dart';
import '../../features/jobs/presentation/bloc/job_detail_bloc.dart';

import '../network/network_info.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> setup() async {
    // Network
    _getIt.registerLazySingleton<Connectivity>(() => Connectivity());
    _getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(_getIt<Connectivity>()),
    );

    // Firestore
    _getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    // Firebase Auth
    _getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    
    // Google Sign In
    _getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

    // Authentication
    _getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        firebaseAuth: _getIt<FirebaseAuth>(),
        googleSignIn: _getIt<GoogleSignIn>(),
      ),
    );

    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: _getIt<AuthRemoteDataSource>(),
      ),
    );

    _getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        authRepository: _getIt<AuthRepository>(),
      ),
    );

    // Profile
    _getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(
        firestore: _getIt<FirebaseFirestore>(),
      ),
    );

    _getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: _getIt<ProfileRemoteDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    _getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        profileRepository: _getIt<ProfileRepository>(),
      ),
    );

    // Jobs
    _getIt.registerLazySingleton<JobRemoteDataSource>(
      () => JobRemoteDataSource(
        firestore: _getIt<FirebaseFirestore>(),
      ),
    );

    _getIt.registerLazySingleton<JobRepository>(
      () => JobRepositoryImpl(
        remoteDataSource: _getIt<JobRemoteDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    _getIt.registerFactory<JobBloc>(
      () => JobBloc(
        jobRepository: _getIt<JobRepository>(),
      ),
    );

    _getIt.registerFactory<JobDetailBloc>(
      () => JobDetailBloc(
        jobRepository: _getIt<JobRepository>(),
      ),
    );
  }

  static T get<T extends Object>() => _getIt<T>();
}
