import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';

import 'resume_l10n.dart';
import 'resume_pdf_builder.dart';
import 'resume_preview_widgets.dart';
import 'resume_steps.dart';

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
    _addExp();
    _addEdu();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameCtrl.text  = user.displayName ?? '';
      _emailCtrl.text = user.email ?? '';
    }
  }

  void _addExp() {
    _expControllers.add({'company': TextEditingController(), 'role': TextEditingController(), 'period': TextEditingController(), 'desc': TextEditingController()});
    setState(() {});
  }

  void _addEdu() {
    _eduControllers.add({'institution': TextEditingController(), 'degree': TextEditingController(), 'period': TextEditingController()});
    setState(() {});
  }

  void _removeExp(int i) {
    _expControllers[i].values.forEach((c) => c.dispose());
    _expControllers.removeAt(i);
    setState(() {});
  }

  void _removeEdu(int i) {
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
      final result = await FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('improveResume')
          .call({
        'fullName':  _nameCtrl.text.trim(),
        'jobTitle':  _titleCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'phone':     _phoneCtrl.text.trim(),
        'location':  _locationCtrl.text.trim(),
        'summary':   _summaryCtrl.text.trim(),
        'skills':    _skillsCtrl.text.trim(),
        'languages': _langsCtrl.text.trim(),
        'language':  langCode,
        'experience': _expControllers.map((m) => {'company': m['company']!.text.trim(), 'role': m['role']!.text.trim(), 'period': m['period']!.text.trim(), 'description': m['desc']!.text.trim()}).toList(),
        'education':  _eduControllers.map((m) => {'institution': m['institution']!.text.trim(), 'degree': m['degree']!.text.trim(), 'period': m['period']!.text.trim()}).toList(),
      });
      setState(() { _improvedData = Map<String, dynamic>.from(result.data); _step = 3; });
    } catch (e) {
      setState(() => _step = 1);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _downloadPdf() async {
    if (_improvedData == null) return;
    final bytes = await buildResumePdf(_improvedData!, _selectedTemplate);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final t = ResumeL10n.of(Localizations.localeOf(context).languageCode);
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
          0 => PickStep(key: const ValueKey(0), selected: _selectedTemplate, onSelect: (i) => setState(() => _selectedTemplate = i), onNext: () => setState(() => _step = 1), t: t),
          1 => FormStep(key: const ValueKey(1), nameCtrl: _nameCtrl, titleCtrl: _titleCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl, locationCtrl: _locationCtrl, summaryCtrl: _summaryCtrl, skillsCtrl: _skillsCtrl, langsCtrl: _langsCtrl, expControllers: _expControllers, eduControllers: _eduControllers, onAddExp: _addExp, onAddEdu: _addEdu, onRemoveExp: _removeExp, onRemoveEdu: _removeEdu, onGenerate: _generate, t: t),
          2 => LoadingStep(key: const ValueKey(2), t: t),
          3 => PreviewStep(key: const ValueKey(3), data: _improvedData!, templateIndex: _selectedTemplate, onDownload: _downloadPdf, onEdit: () => setState(() => _step = 1), t: t),
          _ => const SizedBox(),
        },
      ),
    );
  }
}