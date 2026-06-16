import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _taskRef => _firestore.collection('tasks');

  Stream<QuerySnapshot> getTasksStream() {
    String uid = _auth.currentUser?.uid ?? '';
    return _taskRef
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Future<void> addTask(String title, String category) async {
    String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await _taskRef.add({
      'userId': uid,
      'title': title,
      'category': category,
      'isDone': false,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> toggleTaskStatus(String docId, bool currentStatus) async {
    await _taskRef.doc(docId).update({
      'isDone': !currentStatus,
    });
  }

  Future<void> deleteTask(String docId) async {
    await _taskRef.doc(docId).delete();
  }
}