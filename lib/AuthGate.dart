import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dayindai/Login Page/FirstPage.dart';
import 'package:dayindai/Login Page/ConfirmEmailPage.dart';
import '../HomePage/HomePage.dart';
import 'MainShale/main_shell_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 🔥 Используем authStateChanges() вместо userChanges()
      // authStateChanges() быстрее реагирует на смену состояния
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const Firstpage();
        }

        // 🔥 Дополнительная проверка при каждом построении
        if (!user.emailVerified) {
          return const ConfirmEmailPage();
        }

        return const MainShellPage();
      },
    );
  }
}
