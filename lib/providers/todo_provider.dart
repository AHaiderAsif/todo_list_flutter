import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/todo_service.dart';

class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();
  bool _isActionLoading = false;

  bool get isActionLoading => _isActionLoading;

  // Live Stream Getter
  Stream<QuerySnapshot> get tasksStream => _todoService.getTasksStream();

  // Add Task Function
  Future<void> createNewTask(String title, String category) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _todoService.addTask(title, category);
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // Toggle Task Function
  Future<void> toggleTask(String docId, bool currentStatus) async {
    await _todoService.toggleTaskStatus(docId, currentStatus);
  }

  // Remove Task Function
  Future<void> removeTask(String docId) async {
    await _todoService.deleteTask(docId);
  }
}