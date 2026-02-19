import 'package:flutter/material.dart';


import '../HomePage/HomePage.dart';
import '../ToolsPage/ToolsPage.dart';
import 'package:dayindai/Profil/profil_page.dart';
import 'package:dayindai/AIInterview/ai_interview_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/center_ai_button.dart';
import 'pages/ resume_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    ToolsPage(),
    AiInterviewPage(),
    ResumePage(),
    ProfilePage(),
  ];

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: _pages[_index],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: CenterAiButton(
          onTap: () => _setIndex(2),
          isActive: _index == 2,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        index: _index,
        onTap: _setIndex,
      ),
    );
  }
}