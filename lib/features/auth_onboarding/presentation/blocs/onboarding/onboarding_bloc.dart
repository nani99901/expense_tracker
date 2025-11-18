import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/signup.dart';
import '../../../domain/usecases/verify_otp.dart';
import '../../../domain/usecases/set_pin.dart';
import '../../../domain/usecases/add_wallet.dart';
import 'package:uuid/uuid.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SignupUseCase signupUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SetPinUseCase setPinUseCase;
  final AddWalletUseCase addWalletUseCase;

  OnboardingBloc({
    required this.signupUseCase,
    required this.verifyOtpUseCase,
    required this.setPinUseCase,
    required this.addWalletUseCase,
  }) : super(OnboardingState()) {
    on<StartSignup>(_onStartSignup);
    on<SubmitOtp>(_onSubmitOtp);
    on<SetPinEvent>(_onSetPin);
    on<AddWalletEvent>(_onAddWallet);
    on<CompleteOnboarding>(_onComplete);
  }

  Future<void> _onStartSignup(
      StartSignup e, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(loading: true));

    final user = User(
      id: const Uuid().v4(),
      name: e.name,
      email: e.email,
    );

    await signupUseCase(user);

    final otp = (Random().nextInt(900000) + 100000).toString();
    emit(state.copyWith(
      loading: false,
      otp: otp,
      user: user,
      step: OnboardStep.verification,
    ));
  }

  Future<void> _onSubmitOtp(SubmitOtp e, Emitter<OnboardingState> emit) async {
    final ok = await verifyOtpUseCase(
      VerifyOtpParams(expected: state.otp!, entered: e.code),
    );
    if (!ok) {
      emit(state.copyWith(error: "Invalid OTP"));
      return;
    }
    emit(state.copyWith(step: OnboardStep.pinSetup, error: null));
  }

  Future<void> _onSetPin(SetPinEvent e, Emitter<OnboardingState> emit) async {
    await setPinUseCase(e.pin);

    final u = state.user!;
    final updated = User(
      id: u.id,
      name: u.name,
      email: u.email,
      hasPin: true,
      wallets: u.wallets,
    );

    emit(state.copyWith(
      step: OnboardStep.addWallet,
      user: updated,
    ));
  }

  Future<void> _onAddWallet(
      AddWalletEvent e, Emitter<OnboardingState> emit) async {
    final updated =
        await addWalletUseCase(AddWalletParams(user: state.user!, wallet: e.wallet));
    emit(state.copyWith(user: updated));
  }

  Future<void> _onComplete(
      CompleteOnboarding e, Emitter<OnboardingState> emit) async {
    final u = state.user!;
    final updated = User(
      id: u.id,
      name: u.name,
      email: u.email,
      hasPin: true,
      wallets: u.wallets,
      onboarded: true,
    );
    await signupUseCase(updated);
    emit(state.copyWith(step: OnboardStep.success, user: updated));
  }
}
