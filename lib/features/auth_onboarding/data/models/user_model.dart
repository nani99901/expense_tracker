import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class WalletModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double balance;

  @HiveField(3)
  String type;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  Wallet toEntity() =>
      Wallet(id: id, name: name, balance: balance, type: type);

  static WalletModel fromEntity(Wallet w) => WalletModel(
        id: w.id,
        name: w.name,
        balance: w.balance,
        type: w.type,
      );
}

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  bool onboarded;

  @HiveField(4)
  List<WalletModel> wallets;

  @HiveField(5)
  bool hasPin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.onboarded = false,
    this.wallets = const [],
    this.hasPin = false,
  });

  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        onboarded: onboarded,
        wallets: wallets.map((w) => w.toEntity()).toList(),
        hasPin: hasPin,
      );

  static UserModel fromEntity(User u) => UserModel(
        id: u.id,
        name: u.name,
        email: u.email,
        onboarded: u.onboarded,
        wallets: u.wallets.map(WalletModel.fromEntity).toList(),
        hasPin: u.hasPin,
      );
}
