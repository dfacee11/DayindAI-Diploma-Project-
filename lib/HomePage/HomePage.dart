import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // Listen for changes so page updates if user signs out/in elsewhere
    FirebaseAuth.instance.userChanges().listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/FirstPage');
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'Пользователь';
    final email = _user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
              text: "Dayind",
              style: GoogleFonts.montserrat(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: "AI",
                  style: GoogleFonts.montserrat(
                      fontSize: 28,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ]),
        ),
        backgroundColor: const Color(0xFF121423),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: _signOut,
            tooltip: 'Выйти',
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFF121423),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Добро пожаловать,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // 🔥 Главная кнопка
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/interviewPic.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resume analyzer AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        ' Анализ твоего резюме и подготовка к интервью с помощью ИИ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/AnalyzerResume');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Начать анализ'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _featureCard(
                    icon: Icons.description,
                    title: 'Анализ резюме',
                    subtitle: 'ИИ оценит твоё резюме',
                    onTap: () {
                      Navigator.pushNamed(context, '/ResumeAnalyzer');
                    },
                  ),
                  _featureCard(
                    icon: Icons.question_answer,
                    title: 'Вопросы',
                    subtitle: '10 популярных вопросов',
                    onTap: () {
                      Navigator.pushNamed(context, '/Questions');
                    },
                  ),
                  _featureCard(
                    icon: Icons.trending_up,
                    title: 'Прогресс',
                    subtitle: 'История интервью',
                    onTap: () {},
                  ),
                  _featureCard(
                    icon: Icons.settings,
                    title: 'Настройки',
                    subtitle: 'Профиль и язык',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF1E2038),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.redAccent, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
