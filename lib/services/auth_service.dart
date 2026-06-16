import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  //Login
Future<User?> signIn (String email, String password) async{
  try{
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }catch(e) {
rethrow;
  }
}

//Signup
Future<User?> signUp (String email, String password) async {
  try{
UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
return result.user;
  }catch(e) {
    rethrow;
  }
  }

  //Logout

  Future<void> signOut () async{
    await _auth.signOut();
  }
}

