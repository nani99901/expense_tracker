import 'package:hive/hive.dart';
import '../models/user_model.dart';

abstract class LocalAuthDataSource {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();

  Future<void> savePinHash(String hash);
  Future<String?> getPinHash();
}

class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final Box<UserModel> userBox;
  final Box settingsBox;

  LocalAuthDataSourceImpl({required this.userBox, required this.settingsBox});

  @override
  Future<UserModel?> getUser() async => userBox.get('current_user');

  @override
  Future<void> saveUser(UserModel user) async =>
      userBox.put('current_user', user);

  @override
  Future<void> clearUser() async {
    await userBox.delete('current_user');
    await settingsBox.delete('pin_hash');
  }

  @override
  Future<void> savePinHash(String hash) async =>
      settingsBox.put('pin_hash', hash);

  @override
  Future<String?> getPinHash() async => settingsBox.get('pin_hash');
}
