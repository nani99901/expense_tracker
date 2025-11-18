import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/secure_pin_manager.dart';

class SetPinUseCase extends UseCase<void, String> {
  final SecurePinManager pinManager;

  SetPinUseCase(this.pinManager);

  @override
  Future<void> call(String pin) async {
    await pinManager.storePin(pin);
  }
}
