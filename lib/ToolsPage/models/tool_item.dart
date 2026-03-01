import 'package:flutter/material.dart';

class ToolItem {
  final String category;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ToolItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF7C5CFF),
  });
}