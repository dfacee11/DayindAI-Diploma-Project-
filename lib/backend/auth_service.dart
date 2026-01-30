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

    // Создаём пользователя и возвращаем UserCredential как можно быстрее
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

    // Обновляем displayName (await, короткая операция)
    try {
      await user.updateDisplayName('$name $surname');
    } catch (e) {
      debugPrint('AuthService.registerUser: updateDisplayName error: $e');
    }

    // Fire-and-forget: отправим письмо подтверждения и запишем профиль в фоне,
    // не блокируя возвращение управления вызывающему коду.
    user.sendEmailVerification().then((_) {
      debugPrint('AuthService.registerUser: email verification sent');
    }).catchError((e) {
      debugPrint('AuthService.registerUser: sendEmailVerification error: $e');
    });

    _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((_) {
      debugPrint(
          'AuthService.registerUser: profile saved to firestore uid=${user.uid}');
    }).catchError((e) {
      debugPrint('AuthService.registerUser: firestore set error: $e');
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
