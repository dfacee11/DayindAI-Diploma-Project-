import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  static const double _percent = 0.62;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 14),
              color: Colors.black.withValues(alpha: 0.06)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildProgressBar(),
          const SizedBox(height: 16),
          _buildChips(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C5CFF), Color(0xFF2DD4FF)],
            ),
          ),
          child:
              const Icon(Icons.insights_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interview Readiness',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 2),
              Text(
                'You are almost ready to apply 🚀',
                style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Text(
          '${(_percent * 100).round()}%',
          style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: _percent,
        minHeight: 10,
        backgroundColor: const Color(0xFFF1F5F9),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF7C5CFF)),
      ),
    );
  }

  Widget _buildChips() {
    return const Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ProgressChip(text: 'Resume uploaded', done: true),
        ProgressChip(text: 'Resume analyzed', done: false),
        ProgressChip(text: 'Mock interview', done: true),
        ProgressChip(text: 'Cover letter', done: false),
      ],
    );
  }
}

class ProgressChip extends StatelessWidget {
  final String text;
  final bool done;

  const ProgressChip({super.key, required this.text, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: done
              ? const Color(0xFF86EFAC)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFF22C55E) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: done ? const Color(0xFF14532D) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
