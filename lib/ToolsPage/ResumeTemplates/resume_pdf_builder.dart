import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> buildResumePdf(Map<String, dynamic> data, int idx) async {
  final exp = (data['experience'] as List? ?? [])
      .where((e) => (e['company'] ?? '').toString().isNotEmpty || (e['role'] ?? '').toString().isNotEmpty)
      .toList();
  final edu = (data['education'] as List? ?? [])
      .where((e) => (e['institution'] ?? '').toString().isNotEmpty)
      .toList();
  return switch (idx) {
    0 => _pdf0Sidebar(data, exp, edu),
    1 => _pdf1Minimal(data, exp, edu),
    2 => _pdf2Editorial(data, exp, edu),
    _ => _pdf1Minimal(data, exp, edu),
  };
}

// ── PDF 0: Two-column dark sidebar ──────────────────────────────────────────
Future<Uint8List> _pdf0Sidebar(Map<String, dynamic> data, List exp, List edu) async {
  final pdf = pw.Document();
  const sideC = PdfColor(0.106, 0.263, 0.196);
  const sideL = PdfColor(0.176, 0.416, 0.310);

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
      pw.Container(
        width: 185, color: sideC, padding: const pw.EdgeInsets.all(22),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Container(width: 72, height: 72,
            decoration: const pw.BoxDecoration(color: sideL, shape: pw.BoxShape.circle),
            child: pw.Center(child: pw.Text(
              (data['fullName'] ?? '?').toString().isNotEmpty ? (data['fullName'] as String)[0].toUpperCase() : '?',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            )),
          ),
          pw.SizedBox(height: 14),
          pw.Text(data['fullName'] ?? '', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          pw.SizedBox(height: 3),
          pw.Text(data['jobTitle'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
          pw.SizedBox(height: 22),
          _s0Head('CONTACT'),
          if ((data['email'] ?? '').toString().isNotEmpty) _s0Item(data['email'].toString()),
          if ((data['phone'] ?? '').toString().isNotEmpty) _s0Item(data['phone'].toString()),
          if ((data['location'] ?? '').toString().isNotEmpty) _s0Item(data['location'].toString()),
          if ((data['skills'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 22),
            _s0Head('SKILLS'),
            pw.Wrap(spacing: 4, runSpacing: 5,
              children: data['skills'].toString().split(',').map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const pw.BoxDecoration(color: PdfColor(1, 1, 1, 0.15), borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
                child: pw.Text(s.trim(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
              )).toList(),
            ),
          ],
          if ((data['languages'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 22),
            _s0Head('LANGUAGES'),
            pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.white, lineSpacing: 3)),
          ],
        ]),
      ),
      pw.Expanded(child: pw.Padding(
        padding: const pw.EdgeInsets.all(26),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            _s0MainHead('PROFILE', sideC),
            pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
            pw.SizedBox(height: 18),
          ],
          if (exp.isNotEmpty) ...[
            _s0MainHead('EXPERIENCE', sideC),
            ...exp.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(e['role'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('${e['company']}  ·  ${e['period']}', style: pw.TextStyle(fontSize: 9, color: sideC)),
                pw.SizedBox(height: 4),
                if (e['bullets'] != null)
                  ...(e['bullets'] as List).map((b) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('• ', style: pw.TextStyle(color: sideC, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Expanded(child: pw.Text(b.toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 2))),
                    ]),
                  )),
              ]),
            )),
          ],
          if (edu.isNotEmpty) ...[
            _s0MainHead('EDUCATION', sideC),
            ...edu.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(e['institution'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text(e['degree'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text(e['period'] ?? '', style: pw.TextStyle(fontSize: 9, color: sideC)),
              ]),
            )),
          ],
        ]),
      )),
    ]),
  ));
  return pdf.save();
}

pw.Widget _s0Head(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 7),
  child: pw.Text(t, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, letterSpacing: 1.5)),
);
pw.Widget _s0Item(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Text(t, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white, lineSpacing: 2)),
);
pw.Widget _s0MainHead(String t, PdfColor c) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: c, letterSpacing: 1.5)),
    pw.Divider(color: PdfColor(c.red, c.green, c.blue, 0.3), thickness: 1.5),
    pw.SizedBox(height: 4),
  ]),
);

// ── PDF 1: Clean minimal centered ────────────────────────────────────────────
Future<Uint8List> _pdf1Minimal(Map<String, dynamic> data, List exp, List edu) async {
  final pdf = pw.Document();
  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 52, vertical: 44),
    build: (ctx) => [
      pw.Center(child: pw.Column(children: [
        pw.Text(data['fullName'] ?? '', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
        pw.SizedBox(height: 4),
        pw.Text(data['jobTitle'] ?? '', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.SizedBox(height: 8),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          if ((data['phone'] ?? '').toString().isNotEmpty) ...[pw.Text(data['phone'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)), pw.SizedBox(width: 16)],
          if ((data['email'] ?? '').toString().isNotEmpty) ...[pw.Text(data['email'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)), pw.SizedBox(width: 16)],
          if ((data['location'] ?? '').toString().isNotEmpty) pw.Text(data['location'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ]),
      ])),
      pw.SizedBox(height: 14),
      pw.Divider(color: PdfColors.grey300, thickness: 0.8),
      if ((data['summary'] ?? '').toString().isNotEmpty) ...[
        pw.SizedBox(height: 12), _s1Head('ABOUT ME'),
        pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
        pw.SizedBox(height: 4), pw.Divider(color: PdfColors.grey200),
      ],
      if (exp.isNotEmpty) ...[
        pw.SizedBox(height: 12), _s1Head('WORK EXPERIENCE'),
        ...exp.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text(e['company'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(e['period'] ?? '', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
            ]),
            pw.Text(e['role'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
            pw.SizedBox(height: 4),
            if (e['bullets'] != null) ...(e['bullets'] as List).map((b) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                 pw.Text('• ', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey400)),
                pw.Expanded(child: pw.Text(b.toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 2, color: PdfColors.grey700))),
              ]),
            )),
          ]),
        )),
        pw.Divider(color: PdfColors.grey200),
      ],
      if (edu.isNotEmpty) ...[
        pw.SizedBox(height: 12), _s1Head('EDUCATION'),
        ...edu.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text(e['institution'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(e['period'] ?? '', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400)),
            ]),
            pw.Text(e['degree'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
          ]),
        )),
        pw.Divider(color: PdfColors.grey200),
      ],
      if ((data['skills'] ?? '').toString().isNotEmpty) ...[
        pw.SizedBox(height: 12), _s1Head('SKILLS'),
        pw.Wrap(spacing: 6, runSpacing: 6,
          children: data['skills'].toString().split(',').map((s) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const pw.BoxDecoration(color: PdfColor(0.945, 0.953, 0.969), borderRadius: pw.BorderRadius.all(pw.Radius.circular(20))),
            child: pw.Text(s.trim(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          )).toList(),
        ),
      ],
      if ((data['languages'] ?? '').toString().isNotEmpty) ...[
        pw.SizedBox(height: 16), _s1Head('LANGUAGES'),
        pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    ],
  ));
  return pdf.save();
}

pw.Widget _s1Head(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 8),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900, letterSpacing: 2)),
);

// ── PDF 2: Editorial amber accent ────────────────────────────────────────────
Future<Uint8List> _pdf2Editorial(Map<String, dynamic> data, List exp, List edu) async {
  final pdf = pw.Document();
  const a = PdfColor(0.706, 0.325, 0.035);

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => [
      pw.Container(height: 7, color: a),
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(42, 26, 42, 0),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(data['fullName'] ?? '', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
              pw.SizedBox(height: 4),
              pw.Text(data['jobTitle'] ?? '', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: a)),
            ])),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              if ((data['email'] ?? '').toString().isNotEmpty) pw.Text(data['email'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              if ((data['phone'] ?? '').toString().isNotEmpty) pw.Text(data['phone'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              if ((data['location'] ?? '').toString().isNotEmpty) pw.Text(data['location'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
            ]),
          ]),
          pw.SizedBox(height: 14),
          pw.Divider(color: a, thickness: 1.5),
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 14), _s2Head('SUMMARY', a),
            pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
            pw.SizedBox(height: 12), pw.Divider(color: PdfColors.grey200),
          ],
          if (exp.isNotEmpty) ...[
            pw.SizedBox(height: 12), _s2Head('EXPERIENCE', a),
            ...exp.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Container(width: 3, height: 50, color: a, margin: const pw.EdgeInsets.only(right: 12, top: 2)),
                pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text(e['role'] ?? '', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                  pw.Text('${e['company']}  ·  ${e['period']}', style: pw.TextStyle(fontSize: 9, color: a)),
                  pw.SizedBox(height: 4),
                  if (e['bullets'] != null) ...(e['bullets'] as List).map((b) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('→ ', style: pw.TextStyle(fontSize: 10, color: a)),
                      pw.Expanded(child: pw.Text(b.toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 2, color: PdfColors.grey700))),
                    ]),
                  )),
                ])),
              ]),
            )),
            pw.Divider(color: PdfColors.grey200),
          ],
          if (edu.isNotEmpty) ...[
            pw.SizedBox(height: 12), _s2Head('EDUCATION', a),
            ...edu.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(e['institution'] ?? '', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                pw.Text(e['degree'] ?? '', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text(e['period'] ?? '', style: pw.TextStyle(fontSize: 9, color: a)),
              ]),
            )),
            pw.Divider(color: PdfColors.grey200),
          ],
          if ((data['skills'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 12), _s2Head('SKILLS', a),
            pw.Wrap(spacing: 6, runSpacing: 6,
              children: data['skills'].toString().split(',').map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const pw.BoxDecoration(color: PdfColor(1.0, 0.953, 0.765), borderRadius: pw.BorderRadius.all(pw.Radius.circular(20))),
                child: pw.Text(s.trim(), style: pw.TextStyle(fontSize: 9, color: a)),
              )).toList(),
            ),
          ],
          if ((data['languages'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 16), _s2Head('LANGUAGES', a),
            pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
          pw.SizedBox(height: 40),
        ]),
      ),
    ],
  ));
  return pdf.save();
}

pw.Widget _s2Head(String t, PdfColor a) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: a, letterSpacing: 2)),
);