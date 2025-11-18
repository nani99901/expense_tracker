import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartSignup extends OnboardingEvent {
  final String name;
  final String email;
  StartSignup({required this.name, required this.email});
}

class SubmitOtp extends OnboardingEvent {
  final String code;
  SubmitOtp(this.code);
}

class SetPinEvent extends OnboardingEvent {
  final String pin;
  SetPinEvent(this.pin);
}

class AddWalletEvent extends OnboardingEvent {
  final Wallet wallet;
  AddWalletEvent(this.wallet);
}

class CompleteOnboarding extends OnboardingEvent {}
