import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dayindai/Login Page/FirstPage.dart';
import 'package:dayindai/Login Page/ConfirmEmailPage.dart';
import '../HomePage/HomePage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Пока ждём состояние аутентификации — показываем индикатор
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Пользователь не вошёл
        if (user == null) {
          return const Firstpage();
        }

        // Если есть пользователь, сначала попробуем обновить (reload) данные пользователя,
        // потому что локально может храниться устаревший emailVerified.
        return FutureBuilder<User?>(
          future: FirebaseAuth.instance.currentUser
              ?.reload()
              .then((_) => FirebaseAuth.instance.currentUser),
          builder: (context, reloadSnapshot) {
            if (reloadSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final refreshedUser = reloadSnapshot.data ?? user;

            if (!refreshedUser.emailVerified) {
              return const ConfirmEmailPage();
            }

            // Если email подтверждён — показываем главный экран
            return const HomePage();
          },
        );
      },
    );
  }
}