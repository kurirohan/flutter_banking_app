// NexaBank — Account BLoC (full state machine)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/account_firestore_repository.dart';
import '../../../repositories/transaction_firestore_repository.dart';
import 'package:nexa_bank/models/account.dart';
import 'package:nexa_bank/models/transaction.dart';

// ── Events ──────────────────────────────────
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

class AccountFetchRequested extends AccountEvent {
  const AccountFetchRequested();
}

class AccountRefreshRequested extends AccountEvent {
  const AccountRefreshRequested();
}

class AccountSelected extends AccountEvent {
  final String id;
  const AccountSelected(this.id);
  @override
  List<Object?> get props => [id];
}

class AccountTransactionsRequested extends AccountEvent {
  final String accountId;
  final int page;
  const AccountTransactionsRequested(this.accountId, {this.page = 0});
  @override
  List<Object?> get props => [accountId, page];
}

// ── States ──────────────────────────────────
abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  final String? selectedAccountId;
  final List<Transaction> transactions;
  final bool transactionsLoading;
  final bool isRefreshing;

  const AccountLoaded({
    required this.accounts,
    this.selectedAccountId,
    this.transactions = const [],
    this.transactionsLoading = false,
    this.isRefreshing = false,
  });

  double get totalBalance => accounts.fold(0.0, (s, a) => s + a.balance);

  Account? get selectedAccount => accounts.cast<Account?>().firstWhere(
        (a) => a?.id == selectedAccountId,
        orElse: () => null,
      );

  AccountLoaded copyWith({
    List<Account>? accounts,
    String? selectedAccountId,
    List<Transaction>? transactions,
    bool? transactionsLoading,
    bool? isRefreshing,
  }) =>
      AccountLoaded(
        accounts: accounts ?? this.accounts,
        selectedAccountId: selectedAccountId ?? this.selectedAccountId,
        transactions: transactions ?? this.transactions,
        transactionsLoading: transactionsLoading ?? this.transactionsLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [
        accounts,
        selectedAccountId,
        transactions,
        transactionsLoading,
        isRefreshing
      ];
}

class AccountError extends AccountState {
  final String message;
  final bool isNetworkError;
  const AccountError({required this.message, this.isNetworkError = false});
  @override
  List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountFirestoreRepository _accountRepo;
  final TransactionFirestoreRepository _transactionRepo;

  AccountBloc(
    this._accountRepo,
    this._transactionRepo,
  ) : super(const AccountInitial()) {
    on<AccountFetchRequested>(_onFetch);
    on<AccountRefreshRequested>(_onRefresh);
    on<AccountSelected>(_onSelect);
    on<AccountTransactionsRequested>(_onTransactions);
  }

  Future<void> _onFetch(
      AccountFetchRequested _, Emitter<AccountState> emit) async {
    emit(const AccountLoading());
    try {
      final accounts = await _accountRepo.fetchAccounts();
      emit(AccountLoaded(
        accounts: accounts,
        selectedAccountId: accounts.isNotEmpty ? accounts.first.id : null,
      ));
    } catch (e) {
      emit(const AccountError(
        message: 'Failed to load accounts. Please try again.',
        isNetworkError: true,
      ));
    }
  }

  Future<void> _onRefresh(
      AccountRefreshRequested _, Emitter<AccountState> emit) async {
    final current = state;
    if (current is AccountLoaded) {
      emit(current.copyWith(isRefreshing: true));
      try {
        final accounts = await _accountRepo.fetchAccounts();
        emit(current.copyWith(accounts: accounts, isRefreshing: false));
      } catch (_) {
        emit(current.copyWith(isRefreshing: false));
      }
    }
  }

  void _onSelect(AccountSelected event, Emitter<AccountState> emit) {
    final current = state;
    if (current is AccountLoaded) {
      emit(current.copyWith(
        selectedAccountId: event.id,
        transactions: const [],
      ));
      add(AccountTransactionsRequested(event.id));
    }
  }

  Future<void> _onTransactions(
    AccountTransactionsRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is AccountLoaded) {
      emit(current.copyWith(transactionsLoading: true));
      try {
        final txns = await _transactionRepo.fetchTransactions(event.accountId);
        emit(current.copyWith(transactions: txns, transactionsLoading: false));
      } catch (_) {
        emit(current.copyWith(transactionsLoading: false));
      }
    }
  }
}
