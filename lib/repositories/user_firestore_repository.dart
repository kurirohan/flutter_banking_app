// NexaBank — Firestore User Repository
import '../services/user_firestore_service.dart';
import '../models/user.dart';

class UserFirestoreRepository {
  final UserFirestoreService _service;

  UserFirestoreRepository(this._service);

  Future<List<User>> fetchUsers() async {
    final documents = await _service.fetchUsers();
    return documents
        .map((doc) => User.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<User> createUser(User user) async {
    final reference = await _service.createUser(user.toJson());
    return user.copyWith(id: reference.id);
  }

  Future<void> updateUser(User user) async {
    await _service.updateUser(user.id, user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await _service.deleteUser(userId);
  }
}
