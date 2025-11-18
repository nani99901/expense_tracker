import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../domain/entities/transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../data/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<List<Txn>>? _sub;
  final HomeRepository repo;
  final FirebaseAuth auth;

  HomeBloc(this.repo, this.auth) : super(const HomeState()) {
    on<LoadInitialHome>(_onLoad);
    on<AddTransaction>(_onAddTxn);
    on<SetFilter>(_onSetFilter);
    on<UpdateTransaction>(_onUpdateTxn);
    on<DeleteTransaction>(_onDeleteTxn);
  }

  Future<void> _onLoad(LoadInitialHome e, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true));
    final user = auth.currentUser;
    if (user == null) {
      // Not authenticated yet; show current in-memory list only
      emit(state.copyWith(loading: false));
      return;
    }
    await _sub?.cancel();
    _sub = repo.streamTransactions(user.uid).listen((txns) {
      add(SetFilter(state.filter)); // trigger recompute if needed
      emit(state.copyWith(loading: false, txns: txns));
    });
  }

  void _onAddTxn(AddTransaction e, Emitter<HomeState> emit) {
    final updated = List.of(state.txns)..add(e.txn);
    emit(state.copyWith(txns: updated));
    _persistToRepo(e.txn);
  }

  void _onSetFilter(SetFilter e, Emitter<HomeState> emit) {
    emit(state.copyWith(filter: e.filter));
  }

  Future<void> _persistToRepo(Txn txn) async {
    final user = auth.currentUser;
    if (user == null) return;
    await repo.addTransaction(user.uid, txn);
  }

  Future<void> _onUpdateTxn(UpdateTransaction e, Emitter<HomeState> emit) async {
    final user = auth.currentUser;
    if (user == null) return;
    // Update local list optimistically
    final updated = state.txns.map((t) => t.id == e.before.id ? e.after : t).toList();
    emit(state.copyWith(txns: updated));
    await repo.updateTransaction(user.uid, e.before, e.after);
  }

  Future<void> _onDeleteTxn(DeleteTransaction e, Emitter<HomeState> emit) async {
    final user = auth.currentUser;
    if (user == null) return;
    final updated = state.txns.where((t) => t.id != e.txn.id).toList();
    emit(state.copyWith(txns: updated));
    await repo.deleteTransaction(user.uid, e.txn);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
