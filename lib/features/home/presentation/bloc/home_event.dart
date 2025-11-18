import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInitialHome extends HomeEvent {}

class AddTransaction extends HomeEvent {
  final Txn txn;
  AddTransaction(this.txn);
}

class SetFilter extends HomeEvent {
  final TxnFilter filter;
  SetFilter(this.filter);
}

class UpdateTransaction extends HomeEvent {
  final Txn before;
  final Txn after;
  UpdateTransaction({required this.before, required this.after});

  @override
  List<Object?> get props => [before, after];
}

class DeleteTransaction extends HomeEvent {
  final Txn txn;
  DeleteTransaction(this.txn);

  @override
  List<Object?> get props => [txn];
}
