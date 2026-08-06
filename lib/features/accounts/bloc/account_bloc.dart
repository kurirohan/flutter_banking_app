// PayMaye — Account BLoC (full state machine)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/account_repository.dart';

// ── Events ──────────────────────────────────
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override List<Object?> get props => [];
}
class AccountFetchRequested extends AccountEvent { const AccountFetchRequested(); }

/// Re-fetches every account's balance and (if [focusAccountId] is given, or
/// otherwise whichever account is already selected) that account's
/// transaction history — in one handler, so the two reads can't be split
/// apart by another event and end up emitting stale data over each other.
///
/// This is the only way account/transaction data is ever refreshed after
/// the initial load: because both AccountRepository and TransferRepository
/// read/write through the same shared MockBankDataSource, a plain re-fetch
/// here always reflects the latest state — including a transfer that was
/// just submitted — without any separate "patch local state" event.
class AccountRefreshRequested extends AccountEvent {
  final String? focusAccountId;
  const AccountRefreshRequested({this.focusAccountId});
  @override List<Object?> get props => [focusAccountId];
}
class AccountSelected extends AccountEvent {
  final String id;
  const AccountSelected(this.id);
  @override List<Object?> get props => [id];
}
class AccountTransactionsRequested extends AccountEvent {
  final String accountId;
  final int page;
  const AccountTransactionsRequested(this.accountId, {this.page = 0});
  @override List<Object?> get props => [accountId, page];
}

// ── States ──────────────────────────────────
abstract class AccountState extends Equatable {
  const AccountState();
  @override List<Object?> get props => [];
}
class AccountInitial extends AccountState { const AccountInitial(); }
class AccountLoading extends AccountState { const AccountLoading(); }
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

  Account? get selectedAccount =>
      accounts.cast<Account?>().firstWhere(
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
  List<Object?> get props =>
      [accounts, selectedAccountId, transactions, transactionsLoading, isRefreshing];
}
class AccountError extends AccountState {
  final String message;
  final bool isNetworkError;
  const AccountError({required this.message, this.isNetworkError = false});
  @override List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _repo;

  AccountBloc(this._repo) : super(const AccountInitial()) {
    on<AccountFetchRequested>(_onFetch);
    on<AccountRefreshRequested>(_onRefresh);
    on<AccountSelected>(_onSelect);
    on<AccountTransactionsRequested>(_onTransactions);
  }

  Future<void> _onFetch(AccountFetchRequested _, Emitter<AccountState> emit) async {
    emit(const AccountLoading());
    try {
      final accounts = await _repo.fetchAccounts();
      emit(AccountLoaded(
        accounts: accounts,
        selectedAccountId: accounts.isNotEmpty ? accounts.first.id : null,
      ));
    } catch (e) {
      emit(AccountError(
        message: 'Failed to load accounts. Please try again.',
        isNetworkError: true,
      ));
    }
  }

  Future<void> _onRefresh(AccountRefreshRequested event, Emitter<AccountState> emit) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(current.copyWith(isRefreshing: true));

    final targetAccountId = event.focusAccountId ?? current.selectedAccountId;
    try {
      final accounts = await _repo.fetchAccounts();
      final txns = targetAccountId != null
          ? await _repo.fetchTransactions(targetAccountId)
          : null;

      // Re-read `state` (rather than reusing the `current` captured before
      // these awaits) so this emit can't clobber a change made by another
      // event that ran while this fetch was in flight.
      final latest = state;
      if (latest is AccountLoaded) {
        emit(latest.copyWith(
          accounts: accounts,
          selectedAccountId: targetAccountId,
          transactions: txns ?? latest.transactions,
          isRefreshing: false,
        ));
      }
    } catch (_) {
      final latest = state;
      if (latest is AccountLoaded) {
        emit(latest.copyWith(isRefreshing: false));
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
        final txns = await _repo.fetchTransactions(event.accountId, page: event.page);
        final latest = state;
        if (latest is AccountLoaded) {
          emit(latest.copyWith(transactions: txns, transactionsLoading: false));
        }
      } catch (_) {
        final latest = state;
        if (latest is AccountLoaded) {
          emit(latest.copyWith(transactionsLoading: false));
        }
      }
    }
  }
}
