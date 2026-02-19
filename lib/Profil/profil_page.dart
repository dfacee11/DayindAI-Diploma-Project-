import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'widgets/profile_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.userChanges().listen((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    navigator.pushReplacementNamed('/FirstPage');
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'User';
    final email = _user?.email ?? 'No email';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const DarkTopBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    _buildMainContent(constraints, displayName, email),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints, String displayName, String email) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: constraints.maxHeight - 110),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F5FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(displayName, email),
            const SizedBox(height: 22),
            _buildSectionTitle('Account'),
            const SizedBox(height: 12),
            ProfileTile(icon: Icons.edit_rounded,                title: 'Edit Profile',     subtitle: 'Change your name and info', onTap: () {}),
            ProfileTile(icon: Icons.notifications_none_rounded,  title: 'Notifications',    subtitle: 'Reminders and updates',     onTap: () {}),
            ProfileTile(icon: Icons.workspace_premium_rounded,   title: 'Subscription',     subtitle: 'Upgrade to Pro',            onTap: () {}),
            const SizedBox(height: 22),
            _buildSectionTitle('Support'),
            const SizedBox(height: 12),
            ProfileTile(icon: Icons.help_outline_rounded,        title: 'Help Center',      subtitle: 'FAQ and support',           onTap: () {}),
            ProfileTile(icon: Icons.info_outline_rounded,        title: 'About DayindAI',   subtitle: 'Version and details',       onTap: () {}),
            const SizedBox(height: 26),
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String displayName, String email) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
            ),
            boxShadow: [
              BoxShadow(blurRadius: 18, offset: const Offset(0, 10), color: Colors.black.withValues(alpha: 0.12)),
            ],
          ),
          child: Center(
            child: Image.asset('assets/images/penguin.png', width: 42, height: 42, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(email, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text('Sign Out', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }
}