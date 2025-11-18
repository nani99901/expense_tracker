import 'package:equatable/equatable.dart';

class Txn extends Equatable {
  final String id;
  final double amount; 
  final bool isIncome; // true = income, false = expense
  final String category;
  final String description;
  final DateTime date;
  final String walletId;

  const Txn({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.description,
    required this.date,
    required this.walletId,
  });

  @override
  List<Object?> get props => [id, amount, isIncome, category, description, date, walletId];
}

enum TxnFilter { today, week, month, year }
