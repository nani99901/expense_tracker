import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase extends UseCase<void, User> {
  final AuthRepository repo;

  SignupUseCase(this.repo);

  @override
  Future<void> call(User user) async {
    await repo.saveLocalUser(user);
  }
}
