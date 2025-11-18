import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/home/domain/entities/transaction.dart';

class MonthlyTotals {
  final double income;
  final double expense;
  const MonthlyTotals({required this.income, required this.expense});
  double get balance => income - expense;
}

abstract class HomeRepository {
  Stream<List<Txn>> streamTransactions(String uid);
  Future<void> addTransaction(String uid, Txn txn);
  Stream<MonthlyTotals> streamMonthlyTotals(String uid, DateTime start, DateTime end);
  Future<void> updateTransaction(String uid, Txn before, Txn after);
  Future<void> deleteTransaction(String uid, Txn txn);
}

class HomeRepositoryFirestore implements HomeRepository {
  final FirebaseFirestore fs;
  HomeRepositoryFirestore({FirebaseFirestore? firestore}) : fs = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _txnsCol(String uid) => fs.collection('users').doc(uid).collection('transactions');
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => fs.collection('users').doc(uid);

  @override
  Stream<List<Txn>> streamTransactions(String uid) {
    return _txnsCol(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return Txn(
                id: data['id'] as String? ?? d.id,
                amount: (data['amount'] as num).toDouble(),
                isIncome: data['isIncome'] as bool? ?? false,
                category: data['category'] as String? ?? '',
                description: data['description'] as String? ?? '',
                date: (data['date'] as Timestamp).toDate(),
                walletId: data['walletId'] as String? ?? 'default',
              );
            }).toList());
  }

  @override
  Future<void> addTransaction(String uid, Txn txn) async {
    final userDoc = _userDoc(uid);
    final txnDoc = _txnsCol(uid).doc(txn.id);
    final batch = fs.batch();
    batch.set(txnDoc, {
      'id': txn.id,
      'amount': txn.amount,
      'isIncome': txn.isIncome,
      'category': txn.category,
      'description': txn.description,
      'date': Timestamp.fromDate(txn.date),
      'walletId': txn.walletId,
    }, SetOptions(merge: true));
    batch.set(userDoc, {
      'totalIncome': FieldValue.increment(txn.isIncome ? txn.amount : 0),
      'totalExpense': FieldValue.increment(txn.isIncome ? 0 : txn.amount),
      'balance': FieldValue.increment(txn.isIncome ? txn.amount : -txn.amount),
      'txnCount': FieldValue.increment(1),
      'lastTxnAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Stream<MonthlyTotals> streamMonthlyTotals(String uid, DateTime start, DateTime end) {
    return _txnsCol(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) {
          double income = 0, expense = 0;
          for (final d in snap.docs) {
            final data = d.data();
            final amt = (data['amount'] as num).toDouble();
            final isIncome = (data['isIncome'] as bool?) ?? false;
            if (isIncome) income += amt; else expense += amt;
          }
          return MonthlyTotals(income: income, expense: expense);
        });
  }

  @override
  Future<void> updateTransaction(String uid, Txn before, Txn after) async {
    final userDoc = _userDoc(uid);
    final txnDoc = _txnsCol(uid).doc(before.id);

    // Compute aggregate deltas
    final beforeIncome = before.isIncome ? before.amount : 0.0;
    final beforeExpense = before.isIncome ? 0.0 : before.amount;
    final afterIncome = after.isIncome ? after.amount : 0.0;
    final afterExpense = after.isIncome ? 0.0 : after.amount;

    final incomeDelta = afterIncome - beforeIncome;
    final expenseDelta = afterExpense - beforeExpense;
    final balanceDelta = (after.isIncome ? after.amount : -after.amount) - (before.isIncome ? before.amount : -before.amount);

    final batch = fs.batch();
    batch.set(txnDoc, {
      'id': after.id,
      'amount': after.amount,
      'isIncome': after.isIncome,
      'category': after.category,
      'description': after.description,
      'date': Timestamp.fromDate(after.date),
      'walletId': after.walletId,
    }, SetOptions(merge: true));

    batch.set(userDoc, {
      'totalIncome': FieldValue.increment(incomeDelta),
      'totalExpense': FieldValue.increment(expenseDelta),
      'balance': FieldValue.increment(balanceDelta),
      'lastTxnAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<void> deleteTransaction(String uid, Txn txn) async {
    final userDoc = _userDoc(uid);
    final txnDoc = _txnsCol(uid).doc(txn.id);

    final batch = fs.batch();
    batch.delete(txnDoc);
    batch.set(userDoc, {
      'totalIncome': FieldValue.increment(txn.isIncome ? -txn.amount : 0),
      'totalExpense': FieldValue.increment(txn.isIncome ? 0 : -txn.amount),
      'balance': FieldValue.increment(txn.isIncome ? -txn.amount : txn.amount),
      'txnCount': FieldValue.increment(-1),
      'lastTxnAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
