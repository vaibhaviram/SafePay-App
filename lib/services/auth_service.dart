import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up method
  Future<String> signup({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'phoneNumber': phoneNumber,
        'uid': userCredential.user!.uid,
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Login method
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Signs the user out
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}