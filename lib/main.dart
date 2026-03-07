import 'package:dayindai/VisaInterview/visa_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'HomePage/l10n.dart';
import 'package:dayindai/locale_notifier.dart';
import 'ToolsPage/JobSearch/job_search.dart';
import 'splash_page.dart';
import 'ToolsPage/ResumeTemplates/resume_templates_page.dart';
import 'CoverLetter/cover_letter_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return LocaleNotifier(
      setLocale: _setLocale,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DayInDai',

        locale: _locale,
        supportedLocales: appSupportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),

  
        home: const SplashPage(),

        routes: {
          '/FirstPage':      (context) => const FirstPage(),
          '/home':           (context) => const HomePage(),
          '/register':       (context) => RegisterPage(),
          '/confirm':        (context) => const ConfirmReg(),
          '/confirmEmail':   (context) => const ConfirmEmailPage(),
          '/verified':       (context) => const EmailVerifiedPage(),
          '/resetPassword':  (context) => const ResetPassword(),
          '/AnalyzerResume': (context) => const ResumeAnalyzerPage(),
          '/ToolsPage':      (context) => const ToolsPage(),
          '/ProfilPage':     (context) => const ProfilePage(),
          '/MainShell':      (context) => const MainShellPage(),
          '/ResumeMatching': (_)       => const ResumeMatchingPage(),
          '/AIInterview':    (context) => const AiInterviewPage(),
          '/JobSearch':      (context) => const JobSearchPage(),
          '/VisaInterview':  (context) => const VisaPage(),
          '/AuthGate':       (context) => const AuthGate(),
          '/ResumeTemplates': (context) => const ResumeTemplatesPage(),
          '/CoverLetter': (context) => const CoverLetterPage(),
        },
      ),
    );
  }
}