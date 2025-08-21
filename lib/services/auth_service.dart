import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register user
  Future<AppUser?> register(
      String name, String email, String phone, String password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    AppUser user = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      phone: phone,
    );
    await _db.collection("users").doc(user.uid).set(user.toMap());
    return user;
  }

  // Login
  Future<AppUser?> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    DocumentSnapshot snapshot =
    await _db.collection("users").doc(cred.user!.uid).get();
    return AppUser.fromMap(snapshot.data() as Map<String, dynamic>, cred.user!.uid);
  }

  // Get current user
  Future<AppUser?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    DocumentSnapshot snapshot =
    await _db.collection("users").doc(user.uid).get();
    return AppUser.fromMap(snapshot.data() as Map<String, dynamic>, user.uid);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
