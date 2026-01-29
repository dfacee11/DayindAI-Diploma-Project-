import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    // 1. Создание пользователя
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Отправка письма подтверждения
    await userCredential.user!.sendEmailVerification();

    // 3. Сохранение данных в Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': false,
    });
  }
}