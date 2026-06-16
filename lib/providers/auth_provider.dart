import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Apni service ka sahi path dena

class AuthProvider with ChangeNotifier {
  final AuthService _auth = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Stream<User?> get user => _auth.user;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Login FUNCTION WITH PROVIDER
  Future<bool> loginUser(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.signIn(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "An error occurred";
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  //SIGNUP FUNCTION WITH PROVIDER
  Future<bool> signUpUser(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "An error occurred";
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
