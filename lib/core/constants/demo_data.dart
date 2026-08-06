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
          name: 'Everyday Spend',
          accountNumber: '**** **** **** 7146',
          balance: 18420.35,
          availableBalance: 17850.00,
          currency: 'PHP',
          type: 'current',
        ),
        const Account(
          id: 'acc_002',
          name: 'Grow Save',
          accountNumber: '**** **** **** 3392',
          balance: 62150.80,
          availableBalance: 62150.80,
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
          amount: 189.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(hours: 3)),
          description: 'Jollibee — Lunch',
          merchantName: 'Jollibee',
          category: 'Food & Drinks',
        ),
        Transaction(
          id: 'txn_002',
          type: 'DEBIT',
          amount: 1249.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 1)),
          description: 'Shopee — Order #PH88213',
          merchantName: 'Shopee',
          category: 'Shopping',
        ),
        Transaction(
          id: 'txn_003',
          type: 'DEBIT',
          amount: 149.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 2)),
          description: 'Spotify — Monthly',
          merchantName: 'Spotify',
          category: 'Entertainment',
        ),
        Transaction(
          id: 'txn_004',
          type: 'CREDIT',
          amount: 32000.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 3)),
          description: 'Payroll — Acme Studios',
          merchantName: null,
          category: 'Income',
        ),
        Transaction(
          id: 'txn_005',
          type: 'DEBIT',
          amount: 850.00,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 5)),
          description: 'Petron — Fuel',
          merchantName: 'Petron',
          category: 'Transport',
        ),
      ],
      'acc_002': [
        Transaction(
          id: 'txn_101',
          type: 'CREDIT',
          amount: 312.40,
          currency: 'PHP',
          bookingDate: now.subtract(const Duration(days: 4)),
          description: 'Savings Interest',
          merchantName: null,
          category: 'Income',
        ),
      ],
    };
  }

  static List<Beneficiary> seedBeneficiaries() => const [
        Beneficiary(id: 'b1', name: 'Maria Santos', accountNumber: '**** 2210', bankName: 'BDO'),
        Beneficiary(id: 'b2', name: 'Carlo Reyes', accountNumber: '**** 7745', bankName: 'BPI'),
        Beneficiary(id: 'b3', name: 'Angela Cruz', accountNumber: '**** 3390', bankName: 'Metrobank'),
      ];
}
