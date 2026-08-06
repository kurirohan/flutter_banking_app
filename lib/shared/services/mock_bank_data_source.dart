// PayMaye — In-memory mock banking data source
//
// This is the prototype's single source of truth for account balances,
// transaction history, and beneficiaries. MockAccountRepository and
// MockTransferRepository both read from (and, on a successful transfer,
// write to) the *same* instance of this class, so it doesn't matter which
// screen or bloc triggers a read — Home, Accounts, Insights, and a
// just-completed Transfer all see the same numbers.
//
// This is also what makes the app "backend-ready": everything above this
// class only ever talks to the AccountRepository / TransferRepository
// interfaces. Swapping in a real API later means writing
// ApiAccountRepository / ApiTransferRepository and deleting this file —
// no bloc or widget code changes.
import '../../features/accounts/data/account_repository.dart';
import '../../features/transfers/data/transfer_repository.dart';
import '../../core/constants/demo_data.dart';

class MockBankDataSource {
  MockBankDataSource({
    List<Account>? accounts,
    Map<String, List<Transaction>>? transactions,
    List<Beneficiary>? beneficiaries,
  })  : _accounts = accounts ?? DemoData.seedAccounts(),
        _transactionsByAccount = transactions ?? DemoData.seedTransactions(),
        _beneficiaries = beneficiaries ?? DemoData.seedBeneficiaries();

  final List<Account> _accounts;
  final Map<String, List<Transaction>> _transactionsByAccount;
  final List<Beneficiary> _beneficiaries;

  List<Account> get accounts => List.unmodifiable(_accounts);

  List<Transaction> transactionsFor(String accountId) =>
      List.unmodifiable(_transactionsByAccount[accountId] ?? const []);

  List<Beneficiary> get beneficiaries => List.unmodifiable(_beneficiaries);

  /// Applies a completed transfer: debits [accountId]'s balance and
  /// available balance by [amount], and inserts [transaction] at the
  /// front of that account's history. This is the only place the mock
  /// backend's state mutates, so balance and history can never drift
  /// out of sync with each other.
  void applyTransfer({
    required String accountId,
    required double amount,
    required Transaction transaction,
  }) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return;

    final current = _accounts[index];
    _accounts[index] = current.copyWith(
      balance: current.balance - amount,
      availableBalance: current.availableBalance - amount,
    );

    final history = _transactionsByAccount.putIfAbsent(accountId, () => []);
    history.insert(0, transaction);
  }
}
