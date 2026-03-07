import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumeTemplatesPage extends StatefulWidget {
  const ResumeTemplatesPage({super.key});
  @override
  State<ResumeTemplatesPage> createState() => _ResumeTemplatesPageState();
}

class _ResumeTemplatesPageState extends State<ResumeTemplatesPage> {
  int _step = 0;
  int _selectedTemplate = 0;
  Map<String, dynamic>? _improvedData;

  final _nameCtrl     = TextEditingController();
  final _titleCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _summaryCtrl  = TextEditingController();
  final _skillsCtrl   = TextEditingController();
  final _langsCtrl    = TextEditingController();

  final List<Map<String, TextEditingController>> _expControllers = [];
  final List<Map<String, TextEditingController>> _eduControllers = [];

  @override
  void initState() {
    super.initState();
    _addExperience();
    _addEducation();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameCtrl.text  = user.displayName ?? '';
      _emailCtrl.text = user.email ?? '';
    }
  }

  void _addExperience() {
    _expControllers.add({
      'company': TextEditingController(),
      'role':    TextEditingController(),
      'period':  TextEditingController(),
      'desc':    TextEditingController(),
    });
    setState(() {});
  }

  void _addEducation() {
    _eduControllers.add({
      'institution': TextEditingController(),
      'degree':      TextEditingController(),
      'period':      TextEditingController(),
    });
    setState(() {});
  }

  void _removeExperience(int i) {
    _expControllers[i].values.forEach((c) => c.dispose());
    _expControllers.removeAt(i);
    setState(() {});
  }

  void _removeEducation(int i) {
    _eduControllers[i].values.forEach((c) => c.dispose());
    _eduControllers.removeAt(i);
    setState(() {});
  }

  @override
  void dispose() {
    for (final m in _expControllers) for (final c in m.values) c.dispose();
    for (final m in _eduControllers) for (final c in m.values) c.dispose();
    _nameCtrl.dispose(); _titleCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _locationCtrl.dispose(); _summaryCtrl.dispose();
    _skillsCtrl.dispose(); _langsCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _step = 2);
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      final fns = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final result = await fns.httpsCallable('improveResume').call({
        'fullName':  _nameCtrl.text.trim(),
        'jobTitle':  _titleCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'phone':     _phoneCtrl.text.trim(),
        'location':  _locationCtrl.text.trim(),
        'summary':   _summaryCtrl.text.trim(),
        'skills':    _skillsCtrl.text.trim(),
        'languages': _langsCtrl.text.trim(),
        'language':  langCode,
        'experience': _expControllers.map((m) => {
          'company':     m['company']!.text.trim(),
          'role':        m['role']!.text.trim(),
          'period':      m['period']!.text.trim(),
          'description': m['desc']!.text.trim(),
        }).toList(),
        'education': _eduControllers.map((m) => {
          'institution': m['institution']!.text.trim(),
          'degree':      m['degree']!.text.trim(),
          'period':      m['period']!.text.trim(),
        }).toList(),
      });
      setState(() {
        _improvedData = Map<String, dynamic>.from(result.data);
        _step = 3;
      });
    } catch (e) {
      setState(() => _step = 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _downloadPdf() async {
    if (_improvedData == null) return;
    final bytes = await buildResumePdf(_improvedData!, _selectedTemplate);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final t = _L10n.of(langCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(t.title, style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_step == 0) Navigator.pop(context);
            else if (_step == 3) setState(() => _step = 1);
            else setState(() => _step--);
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: switch (_step) {
          0 => _PickStep(key: const ValueKey(0), selected: _selectedTemplate, onSelect: (i) => setState(() => _selectedTemplate = i), onNext: () => setState(() => _step = 1), t: t),
          1 => _FormStep(key: const ValueKey(1), nameCtrl: _nameCtrl, titleCtrl: _titleCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl, locationCtrl: _locationCtrl, summaryCtrl: _summaryCtrl, skillsCtrl: _skillsCtrl, langsCtrl: _langsCtrl, expControllers: _expControllers, eduControllers: _eduControllers, onAddExp: _addExperience, onAddEdu: _addEducation, onRemoveExp: _removeExperience, onRemoveEdu: _removeEducation, onGenerate: _generate, t: t),
          2 => _LoadingStep(key: const ValueKey(2), t: t),
          3 => _PreviewStep(key: const ValueKey(3), data: _improvedData!, templateIndex: _selectedTemplate, onDownload: _downloadPdf, onEdit: () => setState(() => _step = 1), t: t),
          _ => const SizedBox(),
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// STEP 0 — TEMPLATE PICKER
// ════════════════════════════════════════════════════════════════════════════
class _PickStep extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final _L10n t;
  const _PickStep({super.key, required this.selected, required this.onSelect, required this.onNext, required this.t});

  static const _templates = [
    (
      name: 'Sidebar',
      desc: 'Двухколоночный с тёмной панелью',
      tag: 'ПОПУЛЯРНЫЙ',
      side: Color(0xFF1B4332),
    ),
    (
      name: 'Minimal',
      desc: 'Чистый, центрированный заголовок',
      tag: 'ЧИСТЫЙ',
      side: Color(0xFF1E293B),
    ),
    (
      name: 'Editorial',
      desc: 'Акцентная линия, авторский стиль',
      tag: 'ЯРКИЙ',
      side: Color(0xFFB45309),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dark header
        Container(
          width: double.infinity,
          color: const Color(0xFF0F172A),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Выбери шаблон', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Claude AI улучшит твой текст автоматически', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._templates.asMap().entries.map((e) {
                  final i = e.key;
                  final tmpl = e.value;
                  final isSel = selected == i;
                  return GestureDetector(
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isSel ? tmpl.side : const Color(0xFFE2E8F0), width: isSel ? 2 : 1),
                        boxShadow: [BoxShadow(blurRadius: isSel ? 20 : 6, offset: const Offset(0, 4), color: (isSel ? tmpl.side : Colors.black).withOpacity(isSel ? 0.15 : 0.04))],
                      ),
                      child: Row(
                        children: [
                          // Mini preview
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(17)),
                            child: SizedBox(
                              width: 90, height: 110,
                              child: _MiniPreview(templateIndex: i, accent: tmpl.side),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: tmpl.side.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                                child: Text(tmpl.tag, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: tmpl.side)),
                              ),
                              const SizedBox(height: 6),
                              Text(tmpl.name, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                              const SizedBox(height: 3),
                              Text(tmpl.desc, style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFF94A3B8))),
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: isSel
                              ? Icon(Icons.check_circle_rounded, color: tmpl.side, size: 24)
                              : Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade300, size: 24),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Далее', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Mini preview widget per template
class _MiniPreview extends StatelessWidget {
  final int templateIndex;
  final Color accent;
  const _MiniPreview({required this.templateIndex, required this.accent});

  @override
  Widget build(BuildContext context) {
    return switch (templateIndex) {
      0 => _miniSidebar(accent),
      1 => _miniMinimal(accent),
      2 => _miniEditorial(accent),
      _ => const SizedBox(),
    };
  }

  Widget _miniSidebar(Color a) => Row(
    children: [
      Container(
        width: 30, height: 110, color: a,
        padding: const EdgeInsets.all(4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Container(width: 18, height: 18, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
          const SizedBox(height: 4),
          _bar(Colors.white54, 20), const SizedBox(height: 3),
          _bar(Colors.white30, 16), const SizedBox(height: 8),
          _bar(Colors.white24, 22), const SizedBox(height: 3),
          _bar(Colors.white24, 18), const SizedBox(height: 3),
          _bar(Colors.white24, 20),
        ]),
      ),
      Expanded(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            _bar(const Color(0xFF1B4332), 35),
            const SizedBox(height: 8),
            _bar(Colors.black87, 45), const SizedBox(height: 2),
            _bar(const Color(0xFF1B4332), 28), const SizedBox(height: 2),
            _bar(Colors.grey.shade300, 50), const SizedBox(height: 2),
            _bar(Colors.grey.shade300, 40), const SizedBox(height: 8),
            _bar(const Color(0xFF1B4332), 35),
            const SizedBox(height: 5),
            _bar(Colors.black87, 45), const SizedBox(height: 2),
            _bar(Colors.grey.shade300, 50),
          ]),
        ),
      ),
    ],
  );

  Widget _miniMinimal(Color a) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(7),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 4),
      Center(child: _bar(Colors.black87, 50)),
      const SizedBox(height: 3),
      Center(child: _bar(Colors.grey.shade400, 35)),
      const SizedBox(height: 5),
      Divider(height: 1, color: Colors.grey.shade300),
      const SizedBox(height: 6),
      _bar(Colors.black87, 30), const SizedBox(height: 3),
      _bar(Colors.grey.shade300, 55), const SizedBox(height: 2),
      _bar(Colors.grey.shade300, 45),
      const SizedBox(height: 6),
      Divider(height: 1, color: Colors.grey.shade300),
      const SizedBox(height: 5),
      _bar(Colors.black87, 30), const SizedBox(height: 3),
      _bar(Colors.grey.shade300, 50), const SizedBox(height: 2),
      _bar(Colors.grey.shade300, 40),
    ]),
  );

  Widget _miniEditorial(Color a) => Column(
    children: [
      Container(height: 4, color: a),
      Expanded(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _bar(Colors.black87, 40),
                const SizedBox(height: 3),
                _bar(a, 28),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _bar(Colors.grey.shade300, 30), const SizedBox(height: 2),
                _bar(Colors.grey.shade300, 25),
              ]),
            ]),
            const SizedBox(height: 5),
            Container(height: 1.5, color: a),
            const SizedBox(height: 5),
            _bar(a, 25), const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 2, height: 22, color: a, margin: const EdgeInsets.only(right: 4)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _bar(Colors.black87, 40), const SizedBox(height: 2),
                _bar(a, 25), const SizedBox(height: 2),
                _bar(Colors.grey.shade300, 45),
              ])),
            ]),
          ]),
        ),
      ),
    ],
  );

  Widget _bar(Color c, double w) => Container(height: 4, width: w, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)));
}

// ════════════════════════════════════════════════════════════════════════════
// STEP 1 — FORM
// ════════════════════════════════════════════════════════════════════════════
class _FormStep extends StatelessWidget {
  final TextEditingController nameCtrl, titleCtrl, emailCtrl, phoneCtrl, locationCtrl, summaryCtrl, skillsCtrl, langsCtrl;
  final List<Map<String, TextEditingController>> expControllers;
  final List<Map<String, TextEditingController>> eduControllers;
  final VoidCallback onAddExp, onAddEdu, onGenerate;
  final void Function(int) onRemoveExp, onRemoveEdu;
  final _L10n t;

  const _FormStep({super.key, required this.nameCtrl, required this.titleCtrl, required this.emailCtrl, required this.phoneCtrl, required this.locationCtrl, required this.summaryCtrl, required this.skillsCtrl, required this.langsCtrl, required this.expControllers, required this.eduControllers, required this.onAddExp, required this.onAddEdu, required this.onRemoveExp, required this.onRemoveEdu, required this.onGenerate, required this.t});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec(t.sectionPersonal),
        _card([
          _f(nameCtrl, t.fieldName, Icons.person_outline_rounded),
          _f(titleCtrl, t.fieldTitle, Icons.work_outline_rounded),
          _f(emailCtrl, t.fieldEmail, Icons.alternate_email_rounded, type: TextInputType.emailAddress),
          _f(phoneCtrl, t.fieldPhone, Icons.phone_outlined, type: TextInputType.phone),
          _f(locationCtrl, t.fieldLocation, Icons.location_on_outlined),
        ]),

        _sec(t.sectionSummary),
        _card([_f(summaryCtrl, t.fieldSummary, Icons.notes_rounded, lines: 3)]),

        _secOpt(t.sectionExperience, t.optional),
        ...expControllers.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Stack(children: [
            _card([
              _f(e.value['company']!, t.fieldCompany, Icons.business_outlined),
              _f(e.value['role']!, t.fieldRole, Icons.badge_outlined),
              _f(e.value['period']!, t.fieldPeriod, Icons.date_range_outlined),
              _f(e.value['desc']!, t.fieldDesc, Icons.edit_note_rounded, lines: 3),
            ]),
            if (e.key > 0) Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: () => onRemoveExp(e.key),
                child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444))),
              )),
          ]),
        )),
        _addBtn(t.addExperience, onAddExp),

        _secOpt(t.sectionEducation, t.optional),
        ...eduControllers.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Stack(children: [
            _card([
              _f(e.value['institution']!, t.fieldInstitution, Icons.school_outlined),
              _f(e.value['degree']!, t.fieldDegree, Icons.military_tech_outlined),
              _f(e.value['period']!, t.fieldPeriod, Icons.date_range_outlined),
            ]),
            if (e.key > 0) Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: () => onRemoveEdu(e.key),
                child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444))),
              )),
          ]),
        )),
        _addBtn(t.addEducation, onAddEdu),

        _sec(t.sectionSkills),
        _card([
          _f(skillsCtrl, t.fieldSkills, Icons.psychology_outlined, lines: 2),
          _f(langsCtrl, t.fieldLangs, Icons.language_rounded),
        ]),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Text('✨', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(t.aiHint, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white60, height: 1.4))),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: onGenerate,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(t.generateButton, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sec(String label) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
  );

  Widget _secOpt(String label, String sub) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Row(children: [
      Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
      const SizedBox(width: 8),
      Text(sub, style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFFCBD5E1))),
    ]),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 3), color: Colors.black.withOpacity(0.04))],
    ),
    child: Column(children: children.asMap().entries.map((e) {
      final last = e.key == children.length - 1;
      return Column(children: [e.value, if (!last) Divider(height: 1, indent: 14, endIndent: 14, color: Colors.black.withOpacity(0.04))]);
    }).toList()),
  );

  Widget _f(TextEditingController ctrl, String hint, IconData icon, {TextInputType? type, int lines = 1}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    child: Row(children: [
      Icon(icon, color: const Color(0xFFCBD5E1), size: 17),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: ctrl, keyboardType: type, maxLines: lines,
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFFCBD5E1)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 13)),
      )),
    ]),
  );

  Widget _addBtn(String label, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_rounded, color: Color(0xFF64748B), size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
        ]),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// STEP 2 — LOADING
// ════════════════════════════════════════════════════════════════════════════
class _LoadingStep extends StatelessWidget {
  final _L10n t;
  const _LoadingStep({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('✨', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 28),
        const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        const SizedBox(height: 28),
        Text(t.generating, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 6),
        Text(t.generatingSub, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// STEP 3 — PREVIEW
// ════════════════════════════════════════════════════════════════════════════
class _PreviewStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final int templateIndex;
  final VoidCallback onDownload, onEdit;
  final _L10n t;
  const _PreviewStep({super.key, required this.data, required this.templateIndex, required this.onDownload, required this.onEdit, required this.t});

  static const _accents = [Color(0xFF1B4332), Color(0xFF1E293B), Color(0xFFB45309)];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[templateIndex];
    final exp = (data['experience'] as List? ?? []).where((e) => (e['company'] ?? '').toString().isNotEmpty || (e['role'] ?? '').toString().isNotEmpty).toList();
    final edu = (data['education'] as List? ?? []).where((e) => (e['institution'] ?? '').toString().isNotEmpty).toList();

    return SingleChildScrollView(
      child: Column(children: [
        // Banner
        Container(
          color: accent,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(children: [
            const Text('🎉', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.readyTitle, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(t.readySub, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54)),
            ])),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Resume card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(blurRadius: 24, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.08))],
              ),
              clipBehavior: Clip.hardEdge,
              child: _buildPreview(data, templateIndex, exp, edu, t),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: onDownload,
                style: ElevatedButton.styleFrom(backgroundColor: accent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(t.downloadPdf, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, height: 44,
              child: OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(side: BorderSide(color: accent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(t.editResume, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ]),
    );
  }
}

Widget _buildPreview(Map<String, dynamic> data, int idx, List exp, List edu, _L10n t) {
  return switch (idx) {
    0 => _previewSidebar(data, exp, edu),
    1 => _previewMinimal(data, exp, edu),
    2 => _previewEditorial(data, exp, edu),
    _ => _previewMinimal(data, exp, edu),
  };
}

// Preview: Template 0 — Sidebar
Widget _previewSidebar(Map<String, dynamic> data, List exp, List edu) {
  const a = Color(0xFF1B4332);
  return IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Sidebar
      Container(
        width: 120, color: a,
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 6),
          Container(width: 48, height: 48, decoration: const BoxDecoration(color: Color(0xFF2D6A4F), shape: BoxShape.circle),
            child: Center(child: Text((data['fullName'] ?? '?').toString().isNotEmpty ? (data['fullName'] as String)[0].toUpperCase() : '?',
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)))),
          const SizedBox(height: 10),
          Text(data['fullName'] ?? '', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 2),
          Text(data['jobTitle'] ?? '', style: GoogleFonts.montserrat(fontSize: 8, color: Colors.white54)),
          const SizedBox(height: 14),
          _pSideHead('CONTACT'),
          if ((data['email'] ?? '').isNotEmpty) _pSideItem(data['email'].toString()),
          if ((data['phone'] ?? '').isNotEmpty) _pSideItem(data['phone'].toString()),
          if ((data['location'] ?? '').isNotEmpty) _pSideItem(data['location'].toString()),
          if ((data['skills'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _pSideHead('SKILLS'),
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
            const SizedBox(height: 12),
            _pSideHead('LANGUAGES'),
            Text(data['languages'].toString(), style: GoogleFonts.montserrat(fontSize: 7, color: Colors.white60, height: 1.5)),
          ],
        ]),
      ),
      // Main
      Expanded(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            _pMainHead('PROFILE', a),
            Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 9, color: const Color(0xFF475569), height: 1.6)),
            const SizedBox(height: 12),
          ],
          if (exp.isNotEmpty) ...[
            _pMainHead('EXPERIENCE', a),
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
            _pMainHead('EDUCATION', a),
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

Widget _pSideHead(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 5),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 1.2)),
);
Widget _pSideItem(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 3),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 7, color: Colors.white60), overflow: TextOverflow.ellipsis),
);
Widget _pMainHead(String label, Color c) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: c, letterSpacing: 1.2)),
    Container(height: 1.5, color: c.withOpacity(0.25), margin: const EdgeInsets.only(top: 3)),
  ]),
);

// Preview: Template 1 — Minimal
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
        const SizedBox(height: 8),
        _pMinHead('ABOUT ME'),
        Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.6)),
        Divider(color: Colors.black.withOpacity(0.05), height: 18),
      ],
      if (exp.isNotEmpty) ...[
        _pMinHead('WORK EXPERIENCE'),
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
        _pMinHead('EDUCATION'),
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
        _pMinHead('SKILLS'),
        Wrap(spacing: 5, runSpacing: 4, children: data['skills'].toString().split(',').map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
          child: Text(s.trim(), style: GoogleFonts.montserrat(fontSize: 7, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
        )).toList()),
      ],
    ]),
  );
}

Widget _pMinHead(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5)),
);

// Preview: Template 2 — Editorial
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
          const SizedBox(height: 8),
          _pEdHead('SUMMARY', a),
          Text(data['summary'].toString(), style: GoogleFonts.montserrat(fontSize: 8, color: const Color(0xFF475569), height: 1.6)),
          Divider(color: Colors.black.withOpacity(0.05), height: 16),
        ],
        if (exp.isNotEmpty) ...[
          _pEdHead('EXPERIENCE', a),
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
          _pEdHead('EDUCATION', a),
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
          _pEdHead('SKILLS', a),
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

Widget _pEdHead(String t, Color a) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text(t, style: GoogleFonts.montserrat(fontSize: 8, fontWeight: FontWeight.w900, color: a, letterSpacing: 1.5)),
);

// ════════════════════════════════════════════════════════════════════════════
// PDF BUILDER
// ════════════════════════════════════════════════════════════════════════════
Future<Uint8List> buildResumePdf(Map<String, dynamic> data, int idx) async {
  final exp = (data['experience'] as List? ?? []).where((e) => (e['company'] ?? '').toString().isNotEmpty || (e['role'] ?? '').toString().isNotEmpty).toList();
  final edu = (data['education'] as List? ?? []).where((e) => (e['institution'] ?? '').toString().isNotEmpty).toList();
  return switch (idx) {
    0 => _pdf0Sidebar(data, exp, edu),
    1 => _pdf1Minimal(data, exp, edu),
    2 => _pdf2Editorial(data, exp, edu),
    _ => _pdf1Minimal(data, exp, edu),
  };
}

// PDF 0 — Two-column dark sidebar (like example 1)
Future<Uint8List> _pdf0Sidebar(Map<String, dynamic> data, List exp, List edu) async {
  final pdf = pw.Document();
  const sideC  = PdfColor(0.106, 0.263, 0.196);  // #1B4332
  const sideL  = PdfColor(0.176, 0.416, 0.310);  // #2D6A4F

  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    build: (ctx) => pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
      // Sidebar
      pw.Container(width: 185, color: sideC, padding: const pw.EdgeInsets.all(22),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          // Avatar circle
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

          _p0SHead('CONTACT'),
          if ((data['email'] ?? '').toString().isNotEmpty) _p0SItem(data['email'].toString()),
          if ((data['phone'] ?? '').toString().isNotEmpty) _p0SItem(data['phone'].toString()),
          if ((data['location'] ?? '').toString().isNotEmpty) _p0SItem(data['location'].toString()),

          if ((data['skills'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 22),
            _p0SHead('SKILLS'),
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
            _p0SHead('LANGUAGES'),
            pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.white, lineSpacing: 3)),
          ],
        ]),
      ),
      // Main content
      pw.Expanded(child: pw.Padding(
        padding: const pw.EdgeInsets.all(26),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            _p0MHead('PROFILE', sideC),
            pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
            pw.SizedBox(height: 18),
          ],
          if (exp.isNotEmpty) ...[
            _p0MHead('EXPERIENCE', sideC),
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
            _p0MHead('EDUCATION', sideC),
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

pw.Widget _p0SHead(String t) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 7), child: pw.Text(t, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, letterSpacing: 1.5)));
pw.Widget _p0SItem(String t) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 4), child: pw.Text(t, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white, lineSpacing: 2)));
pw.Widget _p0MHead(String t, PdfColor c) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: c, letterSpacing: 1.5)),
    pw.Divider(color: PdfColor(c.red, c.green, c.blue, 0.3), thickness: 1.5),
    pw.SizedBox(height: 4),
  ]),
);

// PDF 1 — Clean minimal centered (like example 2)
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
        pw.SizedBox(height: 12),
        _p1Head('ABOUT ME'),
        pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
        pw.SizedBox(height: 4), pw.Divider(color: PdfColors.grey200),
      ],
      if (exp.isNotEmpty) ...[
        pw.SizedBox(height: 12), _p1Head('WORK EXPERIENCE'),
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
        pw.SizedBox(height: 12), _p1Head('EDUCATION'),
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
        pw.SizedBox(height: 12), _p1Head('SKILLS'),
        pw.Wrap(spacing: 6, runSpacing: 6,
          children: data['skills'].toString().split(',').map((s) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const pw.BoxDecoration(color: PdfColor(0.945, 0.953, 0.969), borderRadius: pw.BorderRadius.all(pw.Radius.circular(20))),
            child: pw.Text(s.trim(), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          )).toList(),
        ),
      ],
      if ((data['languages'] ?? '').toString().isNotEmpty) ...[
        pw.SizedBox(height: 16), _p1Head('LANGUAGES'),
        pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    ],
  ));
  return pdf.save();
}

pw.Widget _p1Head(String t) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 8),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900, letterSpacing: 2)),
);

// PDF 2 — Editorial amber accent
Future<Uint8List> _pdf2Editorial(Map<String, dynamic> data, List exp, List edu) async {
  final pdf = pw.Document();
  const a = PdfColor(0.706, 0.325, 0.035);  // #B45309

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
            pw.SizedBox(height: 14),
            _p2Head('SUMMARY', a),
            pw.Text(data['summary'].toString(), style: const pw.TextStyle(fontSize: 10, lineSpacing: 4, color: PdfColors.grey700)),
            pw.SizedBox(height: 12), pw.Divider(color: PdfColors.grey200),
          ],
          if (exp.isNotEmpty) ...[
            pw.SizedBox(height: 12), _p2Head('EXPERIENCE', a),
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
            pw.SizedBox(height: 12), _p2Head('EDUCATION', a),
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
            pw.SizedBox(height: 12), _p2Head('SKILLS', a),
            pw.Wrap(spacing: 6, runSpacing: 6,
              children: data['skills'].toString().split(',').map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const pw.BoxDecoration(color: PdfColor(1.0, 0.953, 0.765), borderRadius: pw.BorderRadius.all(pw.Radius.circular(20))),
                child: pw.Text(s.trim(), style: pw.TextStyle(fontSize: 9, color: a)),
              )).toList(),
            ),
          ],
          if ((data['languages'] ?? '').toString().isNotEmpty) ...[
            pw.SizedBox(height: 16), _p2Head('LANGUAGES', a),
            pw.Text(data['languages'].toString(), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
          pw.SizedBox(height: 40),
        ]),
      ),
    ],
  ));
  return pdf.save();
}

pw.Widget _p2Head(String t, PdfColor a) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 10),
  child: pw.Text(t, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: a, letterSpacing: 2)),
);

// ════════════════════════════════════════════════════════════════════════════
// LOCALIZATION
// ════════════════════════════════════════════════════════════════════════════
class _L10n {
  final String title;
  final String sectionPersonal, sectionSummary, sectionExperience, sectionEducation, sectionSkills;
  final String fieldName, fieldTitle, fieldEmail, fieldPhone, fieldLocation, fieldSummary;
  final String fieldCompany, fieldRole, fieldPeriod, fieldDesc;
  final String fieldInstitution, fieldDegree, fieldSkills, fieldLangs;
  final String addExperience, addEducation, optional;
  final String aiHint, generateButton;
  final String generating, generatingSub;
  final String readyTitle, readySub, downloadPdf, editResume;

  const _L10n({
    required this.title,
    required this.sectionPersonal, required this.sectionSummary, required this.sectionExperience,
    required this.sectionEducation, required this.sectionSkills,
    required this.fieldName, required this.fieldTitle, required this.fieldEmail,
    required this.fieldPhone, required this.fieldLocation, required this.fieldSummary,
    required this.fieldCompany, required this.fieldRole, required this.fieldPeriod,
    required this.fieldDesc, required this.fieldInstitution, required this.fieldDegree,
    required this.fieldSkills, required this.fieldLangs,
    required this.addExperience, required this.addEducation, required this.optional,
    required this.aiHint, required this.generateButton,
    required this.generating, required this.generatingSub,
    required this.readyTitle, required this.readySub, required this.downloadPdf, required this.editResume,
  });

  static _L10n of(String l) => switch (l) {
    'ru' => const _L10n(
      title: 'Шаблоны резюме',
      sectionPersonal: 'ЛИЧНЫЕ ДАННЫЕ', sectionSummary: 'О СЕБЕ', sectionExperience: 'ОПЫТ РАБОТЫ',
      sectionEducation: 'ОБРАЗОВАНИЕ', sectionSkills: 'НАВЫКИ',
      fieldName: 'Полное имя', fieldTitle: 'Должность', fieldEmail: 'Email',
      fieldPhone: 'Телефон', fieldLocation: 'Город', fieldSummary: 'Пару слов о себе...',
      fieldCompany: 'Компания', fieldRole: 'Должность', fieldPeriod: 'Период (2022 — 2024)',
      fieldDesc: 'Опишите обязанности...', fieldInstitution: 'Учебное заведение',
      fieldDegree: 'Специальность / степень', fieldSkills: 'Навыки через запятую',
      fieldLangs: 'Казахский, Русский, Английский',
      addExperience: '+ Добавить место работы', addEducation: '+ Добавить образование', optional: '(необязательно)',
      aiHint: 'Claude AI улучшит текст — сделает его профессиональнее для рекрутеров',
      generateButton: 'Создать резюме с AI',
      generating: 'Claude улучшает резюме...', generatingSub: 'Займёт около 3 секунд',
      readyTitle: 'Резюме готово!', readySub: 'AI улучшил текст — скачивай PDF',
      downloadPdf: 'Скачать PDF', editResume: 'Редактировать',
    ),
    'kk' => const _L10n(
      title: 'Түйіндеме үлгілері',
      sectionPersonal: 'ЖЕКЕ ДЕРЕКТЕР', sectionSummary: 'ӨЗІ ТУРАЛЫ', sectionExperience: 'ЖҰМЫС ТӘЖІРИБЕСІ',
      sectionEducation: 'БІЛІМ', sectionSkills: 'ДАҒДЫЛАР',
      fieldName: 'Толық аты-жөні', fieldTitle: 'Лауазым', fieldEmail: 'Email',
      fieldPhone: 'Телефон', fieldLocation: 'Қала', fieldSummary: 'Өзіңіз туралы...',
      fieldCompany: 'Компания', fieldRole: 'Лауазым', fieldPeriod: 'Кезең (2022 — 2024)',
      fieldDesc: 'Міндеттерді сипаттаңыз...', fieldInstitution: 'Оқу орны',
      fieldDegree: 'Мамандық / дәреже', fieldSkills: 'Дағдыларды үтірмен',
      fieldLangs: 'Қазақша, Орысша, Ағылшынша',
      addExperience: '+ Жұмыс орны қосу', addEducation: '+ Білім қосу', optional: '(міндетті емес)',
      aiHint: 'Claude AI мәтініңді жақсартады — рекрутерлерге байқалатындай',
      generateButton: 'AI-мен түйіндеме жасау',
      generating: 'Claude түйіндемені жақсартуда...', generatingSub: 'Шамамен 3 секунд',
      readyTitle: 'Түйіндеме дайын!', readySub: 'AI мәтінді жақсартты — PDF жүктe',
      downloadPdf: 'PDF жүктеу', editResume: 'Өңдеу',
    ),
    _ => const _L10n(
      title: 'Resume Templates',
      sectionPersonal: 'PERSONAL INFO', sectionSummary: 'ABOUT ME', sectionExperience: 'EXPERIENCE',
      sectionEducation: 'EDUCATION', sectionSkills: 'SKILLS',
      fieldName: 'Full Name', fieldTitle: 'Job Title', fieldEmail: 'Email',
      fieldPhone: 'Phone', fieldLocation: 'City', fieldSummary: 'A few words about yourself...',
      fieldCompany: 'Company', fieldRole: 'Position', fieldPeriod: 'Period (2022 — 2024)',
      fieldDesc: 'Describe your responsibilities...', fieldInstitution: 'Institution',
      fieldDegree: 'Degree / Specialty', fieldSkills: 'Skills separated by commas',
      fieldLangs: 'Kazakh, Russian, English',
      addExperience: '+ Add Experience', addEducation: '+ Add Education', optional: '(optional)',
      aiHint: 'Claude AI rewrites your text to sound more professional to recruiters',
      generateButton: 'Generate Resume with AI',
      generating: 'Claude is improving your resume...', generatingSub: 'This takes about 3 seconds',
      readyTitle: 'Resume Ready!', readySub: 'AI improved your text — download PDF',
      downloadPdf: 'Download PDF', editResume: 'Edit',
    ),
  };
}