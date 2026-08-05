// NexaBank — Firestore Transaction Repository
import '../../../core/firebase/transaction_firestore_service.dart';
import '../../accounts/data/account_repository.dart';

class TransactionFirestoreRepository {
  final TransactionFirestoreService _service;

  TransactionFirestoreRepository(this._service);

  Future<List<Transaction>> fetchTransactions(String accountId) async {
    final documents = await _service.fetchTransactions(accountId);
    return documents
        .map((doc) => Transaction.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Transaction> createTransaction(
      String accountId, Transaction transaction) async {
    final reference = await _service.createTransaction(
      accountId,
      transaction.toJson(),
    );
    return transaction.copyWith(id: reference.id);
  }

  Future<void> updateTransaction(
      String accountId, Transaction transaction) async {
    await _service.updateTransaction(
      accountId,
      transaction.id,
      transaction.toJson(),
    );
  }

  Future<void> deleteTransaction(String accountId, String transactionId) async {
    await _service.deleteTransaction(accountId, transactionId);
  }
}
