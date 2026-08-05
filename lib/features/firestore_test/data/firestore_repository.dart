// NexaBank — Firestore Repository
import '../../../core/firebase/firestore_service.dart';
import '../../accounts/data/account_repository.dart';

class FirestoreRepository {
  final FirestoreService _firestoreService;

  FirestoreRepository(this._firestoreService);

  Future<List<Account>> fetchAccounts() async {
    final documents = await _firestoreService.fetchAccounts();
    return documents
        .map((doc) => Account.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Account> createAccount(Account account) async {
    final reference = await _firestoreService.createAccount(account.toJson());
    return account.copyWith(id: reference.id);
  }

  Future<void> updateAccount(Account account) async {
    await _firestoreService.updateAccount(account.id, account.toJson());
  }

  Future<void> deleteAccount(String accountId) async {
    await _firestoreService.deleteAccount(accountId);
  }

  Future<List<Transaction>> fetchTransactions(String accountId) async {
    final documents = await _firestoreService.fetchTransactions(accountId);
    return documents
        .map((doc) => Transaction.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Transaction> createTransaction(
      String accountId, Transaction transaction) async {
    final reference = await _firestoreService.createTransaction(
        accountId, transaction.toJson());
    return transaction.copyWith(id: reference.id);
  }

  Future<void> updateTransaction(
      String accountId, Transaction transaction) async {
    await _firestoreService.updateTransaction(
      accountId,
      transaction.id,
      transaction.toJson(),
    );
  }

  Future<void> deleteTransaction(String accountId, String transactionId) async {
    await _firestoreService.deleteTransaction(accountId, transactionId);
  }
}
