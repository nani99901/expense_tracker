import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

class HomeState extends Equatable {
  final List<Txn> txns;
  final TxnFilter filter;
  final bool loading;

  const HomeState({
    this.txns = const [],
    this.filter = TxnFilter.month,
    this.loading = false,
  });

  HomeState copyWith({
    List<Txn>? txns,
    TxnFilter? filter,
    bool? loading,
  }) => HomeState(
        txns: txns ?? this.txns,
        filter: filter ?? this.filter,
        loading: loading ?? this.loading,
      );

  // Derived summaries for current filter window
  double get totalIncome => _filtered.fold(0.0, (p, t) => p + (t.isIncome ? t.amount : 0.0));
  double get totalExpense => _filtered.fold(0.0, (p, t) => p + (!t.isIncome ? t.amount : 0.0));
  double get balance => totalIncome - totalExpense;

  List<Txn> get filteredTxns => _filtered..sort((a, b) => b.date.compareTo(a.date));

  Map<DateTime, List<Txn>> get groupedByDate {
    final map = <DateTime, List<Txn>>{};
    for (final t in filteredTxns) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  List<Txn> get _filtered {
    final now = DateTime.now();
    DateTime start;
    switch (filter) {
      case TxnFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case TxnFilter.week:
        final weekday = now.weekday; // 1 Mon..7 Sun
        final diff = weekday - DateTime.monday;
        final monday = now.subtract(Duration(days: diff));
        start = DateTime(monday.year, monday.month, monday.day);
        break;
      case TxnFilter.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case TxnFilter.year:
        start = DateTime(now.year, 1, 1);
        break;
    }
    return txns.where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1)))).toList();
  }

  @override
  List<Object?> get props => [txns, filter, loading];
}
