// NexaBank — Firestore User Service
import 'package:cloud_firestore/cloud_firestore.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore;

  UserFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection('users');

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchUsers() async {
    final snapshot = await users.get();
    return snapshot.docs;
  }

  Future<DocumentReference<Map<String, dynamic>>> createUser(
      Map<String, dynamic> data) async {
    return await users.add(data);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await users.doc(id).update(data);
  }

  Future<void> deleteUser(String id) async {
    await users.doc(id).delete();
  }
}
