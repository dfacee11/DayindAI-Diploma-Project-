import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dayindai/HomePage/widgets/dark_background.dart';
import 'package:dayindai/locale_notifier.dart';
import 'widgets/profile_tile.dart';
import 'EditProfilePage.dart';

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
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _ProfileL10n.of(langCode);
    final displayName = _user?.displayName ?? t.userFallback;
    final email = _user?.email ?? t.noEmail;

    const langs = [
      {'code': 'en', 'flag': '🇬🇧', 'label': 'EN'},
      {'code': 'ru', 'flag': '🇷🇺', 'label': 'RU'},
      {'code': 'kk', 'flag': '🇰🇿', 'label': 'KZ'},
    ];
    final current = langs.firstWhere(
      (l) => l['code'] == langCode,
      orElse: () => langs[0],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          t.pageTitle,
          style: GoogleFonts.montserrat(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: '',
            color: const Color(0xFF1E293B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            offset: const Offset(0, 50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(current['flag']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(current['label']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(width: 2),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
            onSelected: (code) =>
                LocaleNotifier.of(context)?.setLocale(Locale(code)),
            itemBuilder: (_) => langs.map((lang) {
              final isActive = lang['code'] == langCode;
              return PopupMenuItem<String>(
                value: lang['code'],
                child: Row(
                  children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(lang['label']!,
                        style: TextStyle(
                          color:
                              isActive ? const Color(0xFF4C63FF) : Colors.white,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        )),
                    if (isActive) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded,
                          size: 16, color: Color(0xFF4C63FF)),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),
        ],
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
                    _buildMainContent(constraints, displayName, email, t),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BoxConstraints constraints,
    String displayName,
    String email,
    _ProfileL10n t,
  ) {
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
            const SizedBox(height: 28),
            _buildSectionTitle(t.sectionAccount),
            const SizedBox(height: 12),
            _buildCard([
              ProfileTile(
                icon: Icons.edit_rounded,
                title: t.editProfile,
                subtitle: t.editProfileSub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),
              ProfileTile(
                icon: Icons.notifications_none_rounded,
                title: t.notifications,
                subtitle: t.notificationsSub,
                onTap: () {},
              ),
              ProfileTile(
                icon: Icons.workspace_premium_rounded,
                title: t.subscription,
                subtitle: t.subscriptionSub,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 22),
            _buildSectionTitle(t.sectionSupport),
            const SizedBox(height: 12),
            _buildCard([
              ProfileTile(
                icon: Icons.help_outline_rounded,
                title: t.helpCenter,
                subtitle: t.helpCenterSub,
                onTap: () {},
              ),
              ProfileTile(
                icon: Icons.info_outline_rounded,
                title: t.aboutApp,
                subtitle: t.aboutAppSub,
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
            _buildSignOutButton(t),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String displayName, String email) {
  final initials = displayName.isNotEmpty
      ? displayName
          .trim()
          .split(' ')
          .map((w) => w.isNotEmpty ? w[0] : '')
          .take(2)
          .join()
          .toUpperCase()
      : '?';

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          blurRadius: 24,
          offset: const Offset(0, 10),
          color: Colors.black.withValues(alpha: 0.07),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _user?.photoURL == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
                  )
                : null,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 8),
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.35),
              ),
            ],
          ),
          child: ClipOval(
            child: _user?.photoURL != null
                ? Image.network(
                    _user!.photoURL!,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C5CFF), Color(0xFF9F7AFF)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Free',
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: Colors.black.withValues(alpha: 0.05),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSignOutButton(_ProfileL10n t) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _signOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18),
            const SizedBox(width: 8),
            Text(
              t.signOut,
              style: GoogleFonts.montserrat(
                  fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileL10n {
  final String pageTitle;
  final String userFallback;
  final String noEmail;
  final String sectionAccount;
  final String sectionSupport;
  final String editProfile;
  final String editProfileSub;
  final String notifications;
  final String notificationsSub;
  final String subscription;
  final String subscriptionSub;
  final String helpCenter;
  final String helpCenterSub;
  final String aboutApp;
  final String aboutAppSub;
  final String signOut;

  const _ProfileL10n({
    required this.pageTitle,
    required this.userFallback,
    required this.noEmail,
    required this.sectionAccount,
    required this.sectionSupport,
    required this.editProfile,
    required this.editProfileSub,
    required this.notifications,
    required this.notificationsSub,
    required this.subscription,
    required this.subscriptionSub,
    required this.helpCenter,
    required this.helpCenterSub,
    required this.aboutApp,
    required this.aboutAppSub,
    required this.signOut,
  });

  static _ProfileL10n of(String langCode) {
    switch (langCode) {
      case 'ru':
        return const _ProfileL10n(
          pageTitle: 'Профиль',
          userFallback: 'Пользователь',
          noEmail: 'Нет email',
          sectionAccount: 'АККАУНТ',
          sectionSupport: 'ПОДДЕРЖКА',
          editProfile: 'Редактировать профиль',
          editProfileSub: 'Изменить имя и данные',
          notifications: 'Уведомления',
          notificationsSub: 'Напоминания и обновления',
          subscription: 'Подписка',
          subscriptionSub: 'Перейти на Pro',
          helpCenter: 'Центр помощи',
          helpCenterSub: 'FAQ и поддержка',
          aboutApp: 'О DayindAI',
          aboutAppSub: 'Версия и детали',
          signOut: 'Выйти',
        );
      case 'kk':
        return const _ProfileL10n(
          pageTitle: 'Профиль',
          userFallback: 'Пайдаланушы',
          noEmail: 'Email жоқ',
          sectionAccount: 'АККАУНТ',
          sectionSupport: 'ҚОЛДАУ',
          editProfile: 'Профильді өңдеу',
          editProfileSub: 'Атау мен деректерді өзгерту',
          notifications: 'Хабарландырулар',
          notificationsSub: 'Еске салулар мен жаңартулар',
          subscription: 'Жазылым',
          subscriptionSub: 'Pro-ға өту',
          helpCenter: 'Көмек орталығы',
          helpCenterSub: 'FAQ және қолдау',
          aboutApp: 'DayindAI туралы',
          aboutAppSub: 'Нұсқа және мәліметтер',
          signOut: 'Шығу',
        );
      default:
        return const _ProfileL10n(
          pageTitle: 'Profile',
          userFallback: 'User',
          noEmail: 'No email',
          sectionAccount: 'ACCOUNT',
          sectionSupport: 'SUPPORT',
          editProfile: 'Edit Profile',
          editProfileSub: 'Change your name and info',
          notifications: 'Notifications',
          notificationsSub: 'Reminders and updates',
          subscription: 'Subscription',
          subscriptionSub: 'Upgrade to Pro',
          helpCenter: 'Help Center',
          helpCenterSub: 'FAQ and support',
          aboutApp: 'About DayindAI',
          aboutAppSub: 'Version and details',
          signOut: 'Sign Out',
        );
    }
  }
}
