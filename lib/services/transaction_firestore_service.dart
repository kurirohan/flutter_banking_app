// NexaBank — Firestore Transaction Service
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionFirestoreService {
  final FirebaseFirestore _firestore;

  TransactionFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> transactions(String accountId) {
    return _firestore
        .collection('accounts')
        .doc(accountId)
        .collection('transactions');
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
