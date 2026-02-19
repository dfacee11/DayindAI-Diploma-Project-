import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dayindai/auth/first_page.dart';
import 'package:dayindai/HomePage/homepage.dart';
import 'package:dayindai/auth/register_page.dart';
import 'package:dayindai/auth/confirm_reg_page.dart';
import 'package:dayindai/auth/confirm_email_page.dart';
import 'package:dayindai/auth/email_verified_page.dart';
import 'package:dayindai/authgate.dart';
import 'package:dayindai/auth/reset_password_page.dart';
import 'package:dayindai/AnalyzeResume/resume_analyzer_page.dart';
import 'ToolsPage/toolspage.dart';
import 'Profil/profil_page.dart';
import 'MainShale/main_shell_page.dart';
import 'ResumeMatching/resume_matching_page.dart';
import 'AIInterview/ai_interview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DayInDai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
        '/FirstPage': (context) => const FirstPage(),
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterPage(),
        '/confirm': (context) => const ConfirmReg(),
        '/confirmEmail': (context) => const ConfirmEmailPage(),
        '/verified': (context) => const EmailVerifiedPage(),
        '/resetPassword': (context) => const ResetPassword(),
        '/AnalyzerResume': (context) => const ResumeAnalyzerPage(),
        '/ToolsPage': (context) => const ToolsPage(),
        '/ProfilPage': (context) => const ProfilePage(),
        '/MainShell': (context) => const MainShellPage(),
        "/ResumeMatching": (_) => const ResumeMatchingPage(),
        "/AIInterview": (context) => const AiInterviewPage(),
      },
    );
  }
}
