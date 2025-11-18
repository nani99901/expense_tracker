import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

enum OnboardStep { intro, signup, verification, pinSetup, addWallet, success }

class OnboardingState extends Equatable {
  final OnboardStep step;
  final bool loading;
  final String? otp;
  final User? user;
  final String? error;

  OnboardingState({
    this.step = OnboardStep.intro,
    this.loading = false,
    this.otp,
    this.user,
    this.error,
  });

  OnboardingState copyWith({
    OnboardStep? step,
    bool? loading,
    String? otp,
    User? user,
    String? error,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      otp: otp ?? this.otp,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [step, loading, otp, user, error];
}
