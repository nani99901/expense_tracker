import '../../../../core/usecases/usecase.dart';

class VerifyOtpParams {
  final String expected;
  final String entered;

  VerifyOtpParams({required this.expected, required this.entered});
}

class VerifyOtpUseCase extends UseCase<bool, VerifyOtpParams> {
  @override
  Future<bool> call(VerifyOtpParams params) async {
    return params.expected == params.entered;
  }
}
