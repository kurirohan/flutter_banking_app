// NexaBank — Firestore Test ViewModel
import 'package:flutter/foundation.dart';
import 'package:nexa_bank/models/account.dart';
import 'package:nexa_bank/models/transaction.dart';
import 'package:nexa_bank/models/user.dart';
import '../../../repositories/account_firestore_repository.dart';
import '../../../repositories/transaction_firestore_repository.dart';
import '../../../repositories/user_firestore_repository.dart';

class FirestoreTestViewModel extends ChangeNotifier {
  final AccountFirestoreRepository accountRepository;
  final TransactionFirestoreRepository transactionRepository;
  final UserFirestoreRepository userRepository;

  FirestoreTestViewModel({
    required this.accountRepository,
    required this.transactionRepository,
    required this.userRepository,
  });

  bool isLoading = false;
  String? errorMessage;
  List<Account> accounts = [];
  Account? selectedAccount;
  List<Transaction> transactions = [];
  List<User> users = [];
  User? selectedUser;

  Future<void> initialize() async {
    await reloadUsers();
    await reloadAccounts();
  }

  Future<void> reloadAccounts() async {
    await _runSafe(() async {
      final result = await accountRepository.fetchAccounts();
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

  Future<void> reloadUsers() async {
    await _runSafe(() async {
      users = await userRepository.fetchUsers();
      if (selectedUser != null) {
        selectedUser = users.isEmpty
            ? null
            : users.firstWhere(
                (user) => user.id == selectedUser!.id,
                orElse: () => users.first,
              );
      }
    });
  }

  Future<void> selectAccount(Account account) async {
    selectedAccount = account;
    await loadTransactions(account.id);
    notifyListeners();
  }

  void selectUser(User user) {
    selectedUser = user;
    notifyListeners();
  }

  Future<void> loadTransactions(String accountId) async {
    await _runSafe(() async {
      transactions = await transactionRepository.fetchTransactions(accountId);
    });
  }

  Future<void> createAccount(Account account) async {
    await _runSafe(() async {
      final created = await accountRepository.createAccount(account);
      accounts.add(created);
      await selectAccount(created);
    });
  }

  Future<void> updateAccount(Account account) async {
    await _runSafe(() async {
      await accountRepository.updateAccount(account);
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
      await accountRepository.deleteAccount(accountId);
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
          await transactionRepository.createTransaction(accountId, transaction);
      transactions.add(created);
    });
  }

  Future<void> updateTransaction(
      String accountId, Transaction transaction) async {
    await _runSafe(() async {
      await transactionRepository.updateTransaction(accountId, transaction);
      final index =
          transactions.indexWhere((item) => item.id == transaction.id);
      if (index >= 0) {
        transactions[index] = transaction;
      }
    });
  }

  Future<void> deleteTransaction(String accountId, String transactionId) async {
    await _runSafe(() async {
      await transactionRepository.deleteTransaction(accountId, transactionId);
      transactions.removeWhere((item) => item.id == transactionId);
    });
  }

  Future<void> createUser(User user) async {
    await _runSafe(() async {
      final created = await userRepository.createUser(user);
      users.add(created);
      selectedUser = created;
    });
  }

  Future<void> updateUser(User user) async {
    await _runSafe(() async {
      await userRepository.updateUser(user);
      final index = users.indexWhere((item) => item.id == user.id);
      if (index >= 0) {
        users[index] = user;
      }
      if (selectedUser?.id == user.id) {
        selectedUser = user;
      }
    });
  }

  Future<void> deleteUser(String userId) async {
    await _runSafe(() async {
      await userRepository.deleteUser(userId);
      users.removeWhere((item) => item.id == userId);
      if (selectedUser?.id == userId) {
        selectedUser = users.isNotEmpty ? users.first : null;
      }
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
