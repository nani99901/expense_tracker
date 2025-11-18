import '../entities/user.dart';

// import 'package:expense_tracker/features/auth_onboarding/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> getLocalUser();
  Future<void> saveLocalUser(User user);
  Future<void> clearLocalUser();

  Future<void> storePinHash(String hash);
  Future<String?> getPinHash();
}
