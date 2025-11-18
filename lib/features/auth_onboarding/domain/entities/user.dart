import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final String name;
  final double balance;
  final String type;

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, balance, type];
}

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool onboarded;
  final List<Wallet> wallets;
  final bool hasPin;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.onboarded = false,
    this.wallets = const [],
    this.hasPin = false,
  });

  @override
  List<Object?> get props => [id, name, email, onboarded, wallets, hasPin];
}
