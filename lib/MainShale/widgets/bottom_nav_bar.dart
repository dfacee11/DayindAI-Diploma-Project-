import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.index, required this.onTap});

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
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(label: "Home",    icon: Icons.home_rounded,       isActive: index == 0, onTap: () => onTap(0)),
            _NavItem(label: "Tools",   icon: Icons.grid_view_rounded,  isActive: index == 1, onTap: () => onTap(1)),
            const SizedBox(width: 70),
            _NavItem(label: "Visa",    icon: Icons.flight_rounded,     isActive: index == 3, onTap: () => onTap(3)),
            _NavItem(label: "Profile", icon: Icons.person_rounded,     isActive: index == 4, onTap: () => onTap(4)),
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

  static const _activeColor   = Color(0xFF7C5CFF);
  static const _inactiveColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _activeColor : _inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}