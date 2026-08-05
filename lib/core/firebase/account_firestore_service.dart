// NexaBank — Firestore Account Service
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountFirestoreService {
  final FirebaseFirestore _firestore;

  AccountFirestoreService({FirebaseFirestore? firestore})
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
}
