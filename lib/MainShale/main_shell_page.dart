import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ToolsPage/ToolsPage.dart';

import '../HomePage/HomePage.dart';

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
    _AiPage(),
    _ResumePage(),
    _ProfilePage(),
  ];

  void _setIndex(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: _pages[_index],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: _CenterAiButton(
          onTap: () => _setIndex(2),
          isActive: _index == 2,
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        onTap: _setIndex,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              offset: const Offset(0, -10),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              label: "Home",
              icon: Icons.home_rounded,
              isActive: index == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              label: "Tools",
              icon: Icons.grid_view_rounded,
              isActive: index == 1,
              onTap: () => onTap(1),
            ),

            // место под FAB
            const SizedBox(width: 70),

            _NavItem(
              label: "Resume",
              icon: Icons.description_rounded,
              isActive: index == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              label: "Profile",
              icon: Icons.person_rounded,
              isActive: index == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF7C5CFF);
    final inactiveColor = const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 24, color: isActive ? activeColor : inactiveColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterAiButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;

  const _CenterAiButton({
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C5CFF),
              Color(0xFF2DD4FF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 28,
              offset: const Offset(0, 14),
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

/* ====== PAGES (пока заглушки) ====== */


class _AiPage extends StatelessWidget {
  const _AiPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body: Center(child: Text("AI", style: TextStyle(color: Colors.white))),
    );
  }
}

class _ResumePage extends StatelessWidget {
  const _ResumePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body:
          Center(child: Text("Resume", style: TextStyle(color: Colors.white))),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body:
          Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
    );
  }
}
