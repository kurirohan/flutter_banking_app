// NexaBank — Firestore Test ViewModel
import 'package:flutter/foundation.dart';
import '../../accounts/data/account_repository.dart';
import '../data/firestore_repository.dart';

class FirestoreTestViewModel extends ChangeNotifier {
  final FirestoreRepository repository;

  FirestoreTestViewModel({required this.repository});

  bool isLoading = false;
  String? errorMessage;
  List<Account> accounts = [];
  Account? selectedAccount;
  List<Transaction> transactions = [];

  Future<void> initialize() async {
    await reloadAccounts();
  }

  Future<void> reloadAccounts() async {
    await _runSafe(() async {
      final result = await repository.fetchAccounts();
      accounts = result;
      if (selectedAccount != null) {
        selectedAccount = accounts.isEmpty
            ? null
            : accounts.firstWhere(
                (account) => account.id == selectedAccount!.id,
                orElse: () => accounts.first,
              );
      }
      if (selectedAccount != null) {
        await loadTransactions(selectedAccount!.id);
      } else {
        transactions = [];
      }
    });
  }

  Future<void> selectAccount(Account account) async {
    selectedAccount = account;
    await loadTransactions(account.id);
    notifyListeners();
  }

  Future<void> loadTransactions(String accountId) async {
    await _runSafe(() async {
      transactions = await repository.fetchTransactions(accountId);
    });
  }

  Future<void> createAccount(Account account) async {
    await _runSafe(() async {
      final created = await repository.createAccount(account);
      accounts.add(created);
      await selectAccount(created);
    });
  }

  Future<void> updateAccount(Account account) async {
    await _runSafe(() async {
      await repository.updateAccount(account);
      final index = accounts.indexWhere((item) => item.id == account.id);
      if (index >= 0) {
        accounts[index] = account;
      }
      if (selectedAccount?.id == account.id) {
        selectedAccount = account;
      }
    });
  }

  Future<void> deleteAccount(String accountId) async {
    await _runSafe(() async {
      await repository.deleteAccount(accountId);
      accounts.removeWhere((element) => element.id == accountId);
      if (selectedAccount?.id == accountId) {
        selectedAccount = accounts.isNotEmpty ? accounts.first : null;
        if (selectedAccount != null) {
          await loadTransactions(selectedAccount!.id);
        } else {
          transactions = [];
        }
      }
    });
  }

  Future<void> createTransaction(
      String accountId, Transaction transaction) async {
    await _runSafe(() async {
      final created =
          await repository.createTransaction(accountId, transaction);
      transactions.add(created);
    });
  }

  Future<void> updateTransaction(
      String accountId, Transaction transaction) async {
    await _runSafe(() async {
      await repository.updateTransaction(accountId, transaction);
      final index =
          transactions.indexWhere((item) => item.id == transaction.id);
      if (index >= 0) {
        transactions[index] = transaction;
      }
    });
  }

  Future<void> deleteTransaction(String accountId, String transactionId) async {
    await _runSafe(() async {
      await repository.deleteTransaction(accountId, transactionId);
      transactions.removeWhere((item) => item.id == transactionId);
    });
  }

  Future<void> _runSafe(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
