import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<AuthResult> signInWithGoogle() async {
    return await _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AuthResult> signInWithApple() async {
    return await _remoteDataSource.signInWithApple();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<AuthResult> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }
}
