// PayMaye — Demo/seed data & tunable prototype constants
//
// Every value the mock backend needs — seed accounts, seed transaction
// history, seed beneficiaries, simulated network delays, and business
// rules like transfer limits — lives here instead of being scattered as
// literals through repositories and blocs. When a real backend is wired
// up, this file (and MockBankDataSource, which consumes it) is simply
// deleted; nothing else needs to change since callers only depend on the
// AccountRepository / TransferRepository interfaces.
import '../../features/accounts/data/account_repository.dart';
import '../../features/transfers/data/transfer_repository.dart';

class DemoData {
  DemoData._();

  // ── Simulated network latency ──────────────────────────────────────
  // Kept short but non-zero so loading states are still exercised.
  static const accountsFetchDelay = Duration(milliseconds: 800);
  static const transactionsFetchDelay = Duration(milliseconds: 600);
  static const beneficiariesFetchDelay = Duration(milliseconds: 500);
  static const transferSubmitDelay = Duration(seconds: 2);
  static const transferStatusDelay = Duration(seconds: 1);

  // ── Business rules ──────────────────────────────────────────────────
  /// Transfers above this amount are declined by the mock backend, the
  /// same way a real one might enforce a daily/per-transaction limit.
  static const double transferLimit = 10000;

  /// Transfers below this amount settle "instantly"; at/above it they're
  /// routed on the slower rail. Purely cosmetic for the prototype.
  static const double instantRailThreshold = 1000;
  static const Duration instantEta = Duration(minutes: 2);
  static const Duration standardEta = Duration(hours: 24);

  /// Placeholder trend data for the Insights month-over-month chart, until
  /// a real backend can supply actual historical totals.
  static const List<double> insightsMonthlyTotalsPlaceholder = [
    980,
    1100,
    890,
    1250,
    1300,
    1150,
  ];

  // ── Seed data ────────────────────────────────────────────────────────
  // Note: this must NOT be a `const [...]` list — MockBankDataSource
  // mutates entries in place (`_accounts[index] = ...`) when a transfer is
  // applied, and a const list is immutable, which would throw at runtime
  // on the very first submitted transfer. The individual Account values
  // are still const; only the enclosing List is a regular, growable one.
  static List<Account> seedAccounts() => [
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

  /// Seed transaction history, keyed by account id. Each account starts
  /// with its own independent history; transfers append to whichever
  /// account they debit.
  static Map<String, List<Transaction>> seedTransactions() {
    final now = DateTime.now();
    return {
      'acc_001': [
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
      ],
      'acc_002': [
        Transaction(
          id: 'txn_101',
          type: 'CREDIT',
          amount: 200.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 4)),
          description: 'Interest Credit',
          merchantName: null,
          category: 'Income',
        ),
      ],
    };
  }

  static List<Beneficiary> seedBeneficiaries() => const [
        Beneficiary(id: 'b1', name: 'John Smith', accountNumber: '**** 1234', bankName: 'Chase Bank'),
        Beneficiary(id: 'b2', name: 'Sarah Johnson', accountNumber: '**** 5678', bankName: 'Bank of America'),
        Beneficiary(id: 'b3', name: 'Mike Williams', accountNumber: '**** 9012', bankName: 'Wells Fargo'),
      ];
}
