// PayMaye — Account Repository
import '../../../core/constants/demo_data.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/services/mock_bank_data_source.dart';

class Account {
  final String id;
  final String name;
  final String accountNumber;
  final double balance;
  final double availableBalance;
  final String currency;
  final String type;

  const Account({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.availableBalance,
    required this.currency,
    required this.type,
  });

  Account copyWith({
    double? balance,
    double? availableBalance,
  }) =>
      Account(
        id: id,
        name: name,
        accountNumber: accountNumber,
        balance: balance ?? this.balance,
        availableBalance: availableBalance ?? this.availableBalance,
        currency: currency,
        type: type,
      );

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        accountNumber: json['accountNumber'] as String,
        balance: (json['balance'] as num).toDouble(),
        availableBalance: (json['availableBalance'] as num).toDouble(),
        currency: json['currency'] as String,
        type: json['type'] as String,
      );
}

class Transaction {
  final String id;
  final String type;   // CREDIT | DEBIT
  final double amount;
  final String currency;
  final DateTime bookingDate;
  final String description;
  final String? merchantName;
  final String category;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.bookingDate,
    required this.description,
    this.merchantName,
    required this.category,
  });

  bool get isCredit => type == 'CREDIT';

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        bookingDate: DateTime.parse(json['bookingDate'] as String),
        description: json['description'] as String,
        merchantName: json['merchantName'] as String?,
        category: json['category'] as String? ?? 'Other',
      );
}

abstract class AccountRepository {
  Future<List<Account>> fetchAccounts();
  Future<List<Transaction>> fetchTransactions(String accountId, {int page = 0});
}

/// Offline implementation backed by the shared [MockBankDataSource]. Every
/// read goes through that single in-memory store, so a transfer applied via
/// [MockTransferRepository] is immediately visible here too — including
/// after switching accounts, pulling to refresh, or navigating away and
/// back — because there's exactly one source of truth instead of each
/// fetch re-generating fresh hardcoded data.
class MockAccountRepository implements AccountRepository {
  final MockBankDataSource _dataSource;
  MockAccountRepository(this._dataSource);

  @override
  Future<List<Account>> fetchAccounts() async {
    await Future.delayed(DemoData.accountsFetchDelay);
    return _dataSource.accounts;
  }

  @override
  Future<List<Transaction>> fetchTransactions(
    String accountId, {
    int page = 0,
  }) async {
    await Future.delayed(DemoData.transactionsFetchDelay);
    return _dataSource.transactionsFor(accountId);
  }
}

/// Placeholder for a real backend integration (REST/GraphQL/Firebase).
/// Implements the same [AccountRepository] interface as
/// [MockAccountRepository], so going live is a matter of filling these in
/// and swapping the instance constructed in main.dart — no BLoC or UI
/// changes required.
class ApiAccountRepository implements AccountRepository {
  final ApiClient _client;
  ApiAccountRepository(this._client);

  @override
  Future<List<Account>> fetchAccounts() {
    // TODO(backend): _client.get('/accounts', fromJson: ...)
    throw UnimplementedError('ApiAccountRepository.fetchAccounts is not wired up yet.');
  }

  @override
  Future<List<Transaction>> fetchTransactions(String accountId, {int page = 0}) {
    // TODO(backend): _client.get('/accounts/$accountId/transactions', ...)
    throw UnimplementedError('ApiAccountRepository.fetchTransactions is not wired up yet.');
  }
}
