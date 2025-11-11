import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_hostel_app/backend/model/user_model.dart';


class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;


  Future<String?> registerUser(
      String email, String password, String name) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: userCred.user!.uid,
      name: name,
      email: email,
      role: "user",
    );

    await _db.collection("users").doc(user.uid).set(user.toMap());

    return user.uid;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }


  Future<void> logout() async => await _auth.signOut();
}
