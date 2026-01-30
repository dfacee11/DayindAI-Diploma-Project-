import 'package:flutter/foundation.dart';
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
    debugPrint('AuthService.registerUser: start email=$email');

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Пользователь не создан',
      );
    }

    // Обновляем displayName (опционально)
    await user.updateDisplayName('$name $surname');

    // 🔥 ВАЖНО: отправляем письмо
    await user.sendEmailVerification();

    // Сохраняем профиль
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('AuthService.registerUser: success uid=${user.uid}');
    return userCredential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    debugPrint('AuthService.signIn: email=$email');
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      debugPrint('AuthService.signIn: success uid=${cred.user?.uid}');
      return cred;
    } catch (e, st) {
      debugPrint('AuthService.signIn: ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('AuthService.sendPasswordResetEmail: email=$email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('AuthService.sendPasswordResetEmail: sent');
    } catch (e, st) {
      debugPrint('AuthService.sendPasswordResetEmail: ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint('AuthService.signOut');
    await _auth.signOut();
  }

  User? currentUser() => _auth.currentUser;
}
