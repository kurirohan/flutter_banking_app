// NexaBank — Firestore Service
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get accounts =>
      _firestore.collection('accounts');

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchAccounts() async {
    final snapshot = await accounts.get();
    return snapshot.docs;
  }

  Future<DocumentReference<Map<String, dynamic>>> createAccount(
      Map<String, dynamic> data) async {
    return await accounts.add(data);
  }

  Future<void> updateAccount(String id, Map<String, dynamic> data) async {
    await accounts.doc(id).update(data);
  }

  Future<void> deleteAccount(String id) async {
    await accounts.doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> transactions(String accountId) {
    return accounts.doc(accountId).collection('transactions');
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchTransactions(
      String accountId) async {
    final snapshot = await transactions(accountId).get();
    return snapshot.docs;
  }

  Future<DocumentReference<Map<String, dynamic>>> createTransaction(
      String accountId, Map<String, dynamic> data) async {
    return await transactions(accountId).add(data);
  }

  Future<void> updateTransaction(
      String accountId, String transactionId, Map<String, dynamic> data) async {
    await transactions(accountId).doc(transactionId).update(data);
  }

  Future<void> deleteTransaction(String accountId, String transactionId) async {
    await transactions(accountId).doc(transactionId).delete();
  }
}
