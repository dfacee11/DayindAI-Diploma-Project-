import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildResumePreview(Map<String, dynamic> data, int idx) {
  final exp = (data['experience'] as List? ?? [])
      .where((e) => (e['company'] ?? '').toString().isNotEmpty || (e['role'] ?? '').toString().isNotEmpty)
      .toList();
  final edu = (data['education'] as List? ?? [])
      .where((e) => (e['institution'] ?? '').toString().isNotEmpty)
      .toList();
  return switch (idx) {
    0 => _previewSidebar(data, exp, edu),
    1 => _previewMinimal(data, exp, edu),
    2 => _previewEditorial(data, exp, edu),
    _ => _previewMinimal(data, exp, edu),
  };
}

// ── Template 0: Sidebar ──────────────────────────────────────────────────────
Widget _previewSidebar(Map<String, dynamic> data, List exp, List edu) {
  const a = Color(0xFF1B4332);
  return IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        width: 120, color: a, padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 6),
          Container(width: 48, height: 48,
            decoration: const BoxDecoration(color: Color(0xFF2D6A4F), shape: BoxShape.circle),
            child: Center(child: Text(
              (data['fullName'] ?? '?').toString().isNotEmpty ? (data['fullName'] as String)[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
            )),
          ),
          const SizedBox(height: 10),
          Text(data['fullName'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 2),
          Text(data['jobTitle'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white54)),
          const SizedBox(height: 14),
          _sideHead('CONTACT'),
          if ((data['email'] ?? '').toString().isNotEmpty) _sideItem(data['email'].toString()),
          if ((data['phone'] ?? '').toString().isNotEmpty) _sideItem(data['phone'].toString()),
          if ((data['location'] ?? '').toString().isNotEmpty) _sideItem(data['location'].toString()),
          if ((data['skills'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12), _sideHead('SKILLS'),
            ...data['skills'].toString().split(',').take(5).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            )),
          ],
          if ((data['languages'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12), _sideHead('LANGUAGES'),
            Text(data['languages'].toString(), style: GoogleFonts.montserrat(fontSize: 7, color: Colors.white60, height: 1.5)),
          ],
        ]),
      ),
      Expanded(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            _mainHead('PROFILE', a),
            Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 9, color: const Color(0xFF475569), height: 1.6)),
            const SizedBox(height: 12),
          ],
          if (exp.isNotEmpty) ...[
            _mainHead('EXPERIENCE', a),
            ...exp.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['role'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                Text('${e['company']}  ·  ${e['period']}', style: GoogleFonts.montserrat(fontSize: 8, color: a)),
                if (e['bullets'] != null) ...(e['bullets'] as List).take(2).map((b) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('• ', style: TextStyle(fontSize: 8, color: a, fontWeight: FontWeight.w900)),
                    Expanded(child: Text(b.toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.4))),
                  ]),
                )),
              ]),
            )),
          ],
          if (edu.isNotEmpty) ...[
            _mainHead('EDUCATION', a),
            ...edu.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['institution'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                Text('${e['degree']}  ·  ${e['period']}', style: GoogleFonts.montserrat(fontSize: 8, color: a)),
              ]),
            )),
          ],
        ]),
      )),
    ]),
  );
}

Widget _sideHead(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 5),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.2)),
);
Widget _sideItem(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 3),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 7, color: Colors.white60), overflow: TextOverflow.ellipsis),
);
Widget _mainHead(String label, Color c) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: c, letterSpacing: 1.2)),
    Container(height: 1.5, color: c.withOpacity(0.25), margin: const EdgeInsets.only(top: 3)),
  ]),
);

// ── Template 1: Minimal ──────────────────────────────────────────────────────
Widget _previewMinimal(Map<String, dynamic> data, List exp, List edu) {
  return Padding(
    padding: const EdgeInsets.all(18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Column(children: [
        Text(data['fullName'] ?? '', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(data['jobTitle'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, color: const Color(0xFF64748B))),
        const SizedBox(height: 6),
        Wrap(alignment: WrapAlignment.center, spacing: 10, children: [
          if ((data['phone'] ?? '').toString().isNotEmpty) Text(data['phone'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF94A3B8))),
          if ((data['email'] ?? '').toString().isNotEmpty) Text(data['email'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF94A3B8))),
          if ((data['location'] ?? '').toString().isNotEmpty) Text(data['location'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF94A3B8))),
        ]),
      ])),
      const SizedBox(height: 10),
      Divider(color: Colors.black.withOpacity(0.08)),
      if ((data['summary'] ?? '').toString().isNotEmpty) ...[
        const SizedBox(height: 8), _minHead('ABOUT ME'),
        Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.6)),
        Divider(color: Colors.black.withOpacity(0.05), height: 18),
      ],
      if (exp.isNotEmpty) ...[
        _minHead('WORK EXPERIENCE'),
        ...exp.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e['company'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF64748B))),
              Text(e['period'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF94A3B8))),
            ]),
            Text(e['role'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            if (e['bullets'] != null) ...(e['bullets'] as List).take(2).map((b) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• ', style: TextStyle(fontSize: 8, color: Color(0xFF94A3B8))),
                Expanded(child: Text(b.toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.4))),
              ]),
            )),
          ]),
        )),
        Divider(color: Colors.black.withOpacity(0.05), height: 14),
      ],
      if (edu.isNotEmpty) ...[
        _minHead('EDUCATION'),
        ...edu.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e['institution'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF64748B))),
              Text(e['period'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF94A3B8))),
            ]),
            Text(e['degree'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          ]),
        )),
        Divider(color: Colors.black.withOpacity(0.05), height: 14),
      ],
      if ((data['skills'] ?? '').toString().isNotEmpty) ...[
        _minHead('SKILLS'),
        Wrap(spacing: 5, runSpacing: 4, children: data['skills'].toString().split(',').map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
          child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 7, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
        )).toList()),
      ],
    ]),
  );
}

Widget _minHead(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5)),
);

// ── Template 2: Editorial ────────────────────────────────────────────────────
Widget _previewEditorial(Map<String, dynamic> data, List exp, List edu) {
  const a = Color(0xFFB45309);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(height: 5, color: a),
    Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['fullName'] ?? '', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            const SizedBox(height: 3),
            Text(data['jobTitle'] ?? '', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w700, color: a)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if ((data['email'] ?? '').toString().isNotEmpty) Text(data['email'].toString(), style: GoogleFonts.montserrat(fontSize: 7, color: const Color(0xFF94A3B8))),
            if ((data['phone'] ?? '').toString().isNotEmpty) Text(data['phone'].toString(), style: GoogleFonts.montserrat(fontSize: 7, color: const Color(0xFF94A3B8))),
            if ((data['location'] ?? '').toString().isNotEmpty) Text(data['location'].toString(), style: GoogleFonts.montserrat(fontSize: 7, color: const Color(0xFF94A3B8))),
          ]),
        ]),
        const SizedBox(height: 8),
        Container(height: 1.5, color: a),
        if ((data['summary'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 8), _edHead('SUMMARY', a),
          Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.6)),
          Divider(color: Colors.black.withOpacity(0.05), height: 16),
        ],
        if (exp.isNotEmpty) ...[
          _edHead('EXPERIENCE', a),
          ...exp.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 2.5, height: 36, color: a, margin: const EdgeInsets.only(right: 8, top: 2)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['role'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                Text('${e['company']}  ·  ${e['period']}', style: GoogleFonts.montserrat(fontSize: 7, color: a)),
                if (e['bullets'] != null) ...(e['bullets'] as List).take(2).map((b) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('→ ', style: TextStyle(fontSize: 7, color: a)),
                    Expanded(child: Text(b.toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.4))),
                  ]),
                )),
              ])),
            ]),
          )),
          Divider(color: Colors.black.withOpacity(0.05), height: 14),
        ],
        if (edu.isNotEmpty) ...[
          _edHead('EDUCATION', a),
          ...edu.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['institution'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              Text('${e['degree']}  ·  ${e['period']}', style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF64748B))),
            ]),
          )),
          Divider(color: Colors.black.withOpacity(0.05), height: 14),
        ],
        if ((data['skills'] ?? '').toString().isNotEmpty) ...[
          _edHead('SKILLS', a),
          Wrap(spacing: 5, runSpacing: 4, children: data['skills'].toString().split(',').map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(20)),
            child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 7, fontWeight: FontWeight.w700, color: a)),
          )).toList()),
        ],
      ]),
    ),
  ]);
}

Widget _edHead(String t, Color a) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: a, letterSpacing: 1.5)),
);