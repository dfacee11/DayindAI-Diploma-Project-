import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Обновим displayName (необязательно, но полезно)
    await userCredential.user?.updateDisplayName('$name $surname');

    // Отправим письмо подтверждения
    await userCredential.user?.sendEmailVerification();

    // Сохраним профиль в Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': userCredential.user!.emailVerified ?? false,
    });

    return userCredential;
  }
}