// NexaBank — Account Repository
import '../../../core/network/dio_client.dart';

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

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        accountNumber: json['accountNumber'] as String,
        balance: (json['balance'] as num).toDouble(),
        availableBalance: (json['availableBalance'] as num).toDouble(),
        currency: json['currency'] as String,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'accountNumber': accountNumber,
        'balance': balance,
        'availableBalance': availableBalance,
        'currency': currency,
        'type': type,
      };

  Account copyWith({
    String? id,
    String? name,
    String? accountNumber,
    double? balance,
    double? availableBalance,
    String? currency,
    String? type,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      type: type ?? this.type,
    );
  }
}

class Transaction {
  final String id;
  final String type; // CREDIT | DEBIT
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

  Map<String, dynamic> toJson() => {
        'type': type,
        'amount': amount,
        'currency': currency,
        'bookingDate': bookingDate.toIso8601String(),
        'description': description,
        'merchantName': merchantName,
        'category': category,
      };

  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? currency,
    DateTime? bookingDate,
    String? description,
    String? merchantName,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      bookingDate: bookingDate ?? this.bookingDate,
      description: description ?? this.description,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
    );
  }
}

abstract class AccountRepository {
  Future<List<Account>> fetchAccounts();
  Future<List<Transaction>> fetchTransactions(String accountId, {int page = 0});
}

class RemoteAccountRepository implements AccountRepository {
  final ApiClient _client;
  RemoteAccountRepository(this._client);

  @override
  Future<List<Account>> fetchAccounts() async {
    // Simulate API response for demo
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const Account(
        id: 'acc_001',
        name: 'Personal Current Account',
        accountNumber: '**** **** **** 4521',
        balance: 12500.75,
        availableBalance: 12000.00,
        currency: 'PHP',
        type: 'current',
      ),
      const Account(
        id: 'acc_002',
        name: 'Savings Account',
        accountNumber: '**** **** **** 8834',
        balance: 45200.00,
        availableBalance: 45200.00,
        currency: 'PHP',
        type: 'savings',
      ),
    ];
  }

  @override
  Future<List<Transaction>> fetchTransactions(
    String accountId, {
    int page = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    return [
      Transaction(
        id: 'txn_001',
        type: 'DEBIT',
        amount: 4.50,
        currency: 'PHP',
        bookingDate: now.subtract(const Duration(hours: 2)),
        description: 'Starbucks — Coffee',
        merchantName: 'Starbucks',
        category: 'Food & Drinks',
      ),
      Transaction(
        id: 'txn_002',
        type: 'DEBIT',
        amount: 89.99,
        currency: 'PHP',
        bookingDate: now.subtract(const Duration(days: 1)),
        description: 'Amazon.com — Purchase',
        merchantName: 'Amazon',
        category: 'Shopping',
      ),
      Transaction(
        id: 'txn_003',
        type: 'DEBIT',
        amount: 15.99,
        currency: 'PHP',
        bookingDate: now.subtract(const Duration(days: 2)),
        description: 'Netflix — Monthly',
        merchantName: 'Netflix',
        category: 'Entertainment',
      ),
      Transaction(
        id: 'txn_004',
        type: 'CREDIT',
        amount: 5000.00,
        currency: 'PHP',
        bookingDate: now.subtract(const Duration(days: 3)),
        description: 'Salary Credit — July 2024',
        merchantName: null,
        category: 'Income',
      ),
      Transaction(
        id: 'txn_005',
        type: 'DEBIT',
        amount: 45.00,
        currency: 'PHP',
        bookingDate: now.subtract(const Duration(days: 5)),
        description: 'Shell Gas Station',
        merchantName: 'Shell',
        category: 'Transport',
      ),
    ];
  }
}
