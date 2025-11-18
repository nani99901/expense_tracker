import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDataSource local;

  AuthRepositoryImpl(this.local);

  @override
  Future<User?> getLocalUser() async {
    final data = await local.getUser();
    return data?.toEntity();
  }

  @override
  Future<void> saveLocalUser(User user) async =>
      local.saveUser(UserModel.fromEntity(user));

  @override
  Future<void> clearLocalUser() async => local.clearUser();

  @override
  Future<void> storePinHash(String hash) async =>
      local.savePinHash(hash);

  @override
  Future<String?> getPinHash() async => local.getPinHash();
}
