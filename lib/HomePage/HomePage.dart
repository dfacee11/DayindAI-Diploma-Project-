import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        title: const Text('DayindAI'),
        backgroundColor: const Color(0xFF121423),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Выйти',
          )
        ],
      ),
      backgroundColor: const Color(0xFF121423),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Добро пожаловать,',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              const Text(
                'Здесь будет основной экран приложения — список тренировочных заданий, сессии интервью и т.д.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: заменить на переход в основную часть приложения
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Переход в основную часть приложения пока не реализован')), 
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Начать'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}