// NexaBank — Firestore Account Repository
import '../services/account_firestore_service.dart';
import '../models/account.dart';

class AccountFirestoreRepository {
  final AccountFirestoreService _service;

  AccountFirestoreRepository(this._service);

  Future<List<Account>> fetchAccounts() async {
    final documents = await _service.fetchAccounts();
    return documents
        .map((doc) => Account.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Account> createAccount(Account account) async {
    final reference = await _service.createAccount(account.toJson());
    return account.copyWith(id: reference.id);
  }

  Future<void> updateAccount(Account account) async {
    await _service.updateAccount(account.id, account.toJson());
  }

  Future<void> deleteAccount(String accountId) async {
    await _service.deleteAccount(accountId);
  }
}
