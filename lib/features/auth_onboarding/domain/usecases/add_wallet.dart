import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AddWalletParams {
  final User user;
  final Wallet wallet;

  AddWalletParams({required this.user, required this.wallet});
}

class AddWalletUseCase extends UseCase<User, AddWalletParams> {
  final AuthRepository repo;

  AddWalletUseCase(this.repo);

  @override
  Future<User> call(AddWalletParams params) async {
    final updated = User(
      id: params.user.id,
      name: params.user.name,
      email: params.user.email,
      onboarded: params.user.onboarded,
      hasPin: params.user.hasPin,
      wallets: [...params.user.wallets, params.wallet],
    );

    await repo.saveLocalUser(updated);
    return updated;
  }
}
