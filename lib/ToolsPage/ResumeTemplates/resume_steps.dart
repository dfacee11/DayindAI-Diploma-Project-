import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resume_l10n.dart';
import 'resume_preview_widgets.dart';

class PickStep extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final ResumeL10n t;
  const PickStep({super.key, required this.selected, required this.onSelect, required this.onNext, required this.t});

  static const _templates = [
    (name: 'Sidebar',    desc: 'Двухколоночный с тёмной панелью', tag: 'ПОПУЛЯРНЫЙ', side: Color(0xFF1B4332)),
    (name: 'Minimal',    desc: 'Чистый, центрированный заголовок', tag: 'ЧИСТЫЙ',    side: Color(0xFF1E293B)),
    (name: 'Editorial',  desc: 'Акцентная линия, авторский стиль', tag: 'ЯРКИЙ',     side: Color(0xFFB45309)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity, color: const Color(0xFF0F172A),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Выбери шаблон', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text('AI улучшит твой текст автоматически', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white38)),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            ..._templates.asMap().entries.map((e) {
              final i = e.key; final tmpl = e.value; final isSel = selected == i;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isSel ? tmpl.side : const Color(0xFFE2E8F0), width: isSel ? 2 : 1),
                    boxShadow: [BoxShadow(blurRadius: isSel ? 20 : 6, offset: const Offset(0, 4), color: (isSel ? tmpl.side : Colors.black).withOpacity(isSel ? 0.15 : 0.04))],
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(17)),
                      child: SizedBox(width: 90, height: 110, child: _MiniPreview(templateIndex: i, accent: tmpl.side)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: tmpl.side.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Text(tmpl.tag, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: tmpl.side)),
                      ),
                      const SizedBox(height: 6),
                      Text(tmpl.name, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 3),
                      Text(tmpl.desc, style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFF94A3B8))),
                    ])),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: isSel
                        ? Icon(Icons.check_circle_rounded, color: tmpl.side, size: 24)
                        : Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade300, size: 24),
                    ),
                  ]),
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
          ]),
        ),
      ),
    ]);
  }
}

class _MiniPreview extends StatelessWidget {
  final int templateIndex;
  final Color accent;
  const _MiniPreview({required this.templateIndex, required this.accent});

  @override
  Widget build(BuildContext context) => switch (templateIndex) {
    0 => _sidebar(accent),
    1 => _minimal(accent),
    2 => _editorial(accent),
    _ => const SizedBox(),
  };

  Widget _sidebar(Color a) => Row(children: [
    Container(width: 30, height: 110, color: a, padding: const EdgeInsets.all(4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        _b(Colors.white54, 20), const SizedBox(height: 3), _b(Colors.white30, 16),
        const SizedBox(height: 8),
        _b(Colors.white24, 22), const SizedBox(height: 3), _b(Colors.white24, 18), const SizedBox(height: 3), _b(Colors.white24, 20),
      ]),
    ),
    Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4), _b(const Color(0xFF1B4332), 35),
        const SizedBox(height: 8),
        _b(Colors.black87, 45), const SizedBox(height: 2), _b(const Color(0xFF1B4332), 28),
        const SizedBox(height: 2), _b(Colors.grey.shade300, 50), const SizedBox(height: 2), _b(Colors.grey.shade300, 40),
        const SizedBox(height: 8), _b(const Color(0xFF1B4332), 35),
        const SizedBox(height: 5), _b(Colors.black87, 45), const SizedBox(height: 2), _b(Colors.grey.shade300, 50),
      ]),
    )),
  ]);

  Widget _minimal(Color a) => Container(color: Colors.white, padding: const EdgeInsets.all(7),
    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 4),
      Center(child: _b(Colors.black87, 50)), const SizedBox(height: 3),
      Center(child: _b(Colors.grey.shade400, 35)),
      const SizedBox(height: 5), Divider(height: 1, color: Colors.grey.shade300),
      const SizedBox(height: 6), _b(Colors.black87, 30), const SizedBox(height: 3),
      _b(Colors.grey.shade300, 55), const SizedBox(height: 2), _b(Colors.grey.shade300, 45),
      const SizedBox(height: 6), Divider(height: 1, color: Colors.grey.shade300),
      const SizedBox(height: 5), _b(Colors.black87, 30), const SizedBox(height: 3),
      _b(Colors.grey.shade300, 50), const SizedBox(height: 2), _b(Colors.grey.shade300, 40),
    ]),
  );

  Widget _editorial(Color a) => Column(children: [
    Container(height: 4, color: a),
    Expanded(child: Container(color: Colors.white, padding: const EdgeInsets.all(6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b(Colors.black87, 40), const SizedBox(height: 3), _b(a, 28)])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [_b(Colors.grey.shade300, 30), const SizedBox(height: 2), _b(Colors.grey.shade300, 25)]),
        ]),
        const SizedBox(height: 5), Container(height: 1.5, color: a), const SizedBox(height: 5),
        _b(a, 25), const SizedBox(height: 4),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 2, height: 22, color: a, margin: const EdgeInsets.only(right: 4)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _b(Colors.black87, 40), const SizedBox(height: 2), _b(a, 25), const SizedBox(height: 2), _b(Colors.grey.shade300, 45),
          ])),
        ]),
      ]),
    )),
  ]);

  Widget _b(Color c, double w) => Container(height: 4, width: w, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)));
}

class FormStep extends StatefulWidget {
  final TextEditingController nameCtrl, titleCtrl, emailCtrl, phoneCtrl, locationCtrl, summaryCtrl, skillsCtrl, langsCtrl;
  final List<Map<String, TextEditingController>> expControllers, eduControllers;
  final VoidCallback onAddExp, onAddEdu, onGenerate;
  final void Function(int) onRemoveExp, onRemoveEdu;
  final ResumeL10n t;

  const FormStep({super.key, required this.nameCtrl, required this.titleCtrl, required this.emailCtrl, required this.phoneCtrl, required this.locationCtrl, required this.summaryCtrl, required this.skillsCtrl, required this.langsCtrl, required this.expControllers, required this.eduControllers, required this.onAddExp, required this.onAddEdu, required this.onRemoveExp, required this.onRemoveEdu, required this.onGenerate, required this.t});

  @override
  State<FormStep> createState() => _FormStepState();
}

class _FormStepState extends State<FormStep> {
  bool _noExp = false;
  bool _noEdu = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec(t.sectionPersonal),
        _card([
          _f(widget.nameCtrl, t.fieldName, Icons.person_outline_rounded),
          _f(widget.titleCtrl, t.fieldTitle, Icons.work_outline_rounded),
          _f(widget.emailCtrl, t.fieldEmail, Icons.alternate_email_rounded, type: TextInputType.emailAddress),
          _f(widget.phoneCtrl, t.fieldPhone, Icons.phone_outlined, type: TextInputType.phone),
          _f(widget.locationCtrl, t.fieldLocation, Icons.location_on_outlined),
        ]),

        _sec(t.sectionSummary),
        _card([_f(widget.summaryCtrl, t.fieldSummary, Icons.notes_rounded, lines: 3)]),

        
        _secOpt(t.sectionExperience, t.optional),
        
        GestureDetector(
          onTap: () => setState(() => _noExp = !_noExp),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _noExp ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _noExp ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _noExp ? const Color(0xFF22C55E) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _noExp ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: _noExp ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Text(t.noExperience, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _noExp ? const Color(0xFF16A34A) : const Color(0xFF64748B))),
            ]),
          ),
        ),

        if (!_noExp) ...[
          const SizedBox(height: 10),
          ...widget.expControllers.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(children: [
              _card([
                _f(e.value['company']!, t.fieldCompany, Icons.business_outlined),
                _f(e.value['role']!, t.fieldRole, Icons.badge_outlined),
                _f(e.value['period']!, t.fieldPeriod, Icons.date_range_outlined),
                _f(e.value['desc']!, t.fieldDesc, Icons.edit_note_rounded, lines: 3),
              ]),
              if (e.key > 0) Positioned(top: 8, right: 8, child: GestureDetector(
                onTap: () => widget.onRemoveExp(e.key),
                child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444))),
              )),
            ]),
          )),
          _addBtn(t.addExperience, widget.onAddExp),
        ],

       
        _secOpt(t.sectionEducation, t.optional),
        GestureDetector(
          onTap: () => setState(() => _noEdu = !_noEdu),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _noEdu ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _noEdu ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _noEdu ? const Color(0xFF22C55E) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _noEdu ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: _noEdu ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
              Text(t.noEducation, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: _noEdu ? const Color(0xFF16A34A) : const Color(0xFF64748B))),
            ]),
          ),
        ),

        if (!_noEdu) ...[
          const SizedBox(height: 10),
          ...widget.eduControllers.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(children: [
              _card([
                _f(e.value['institution']!, t.fieldInstitution, Icons.school_outlined),
                _f(e.value['degree']!, t.fieldDegree, Icons.military_tech_outlined),
                _f(e.value['period']!, t.fieldPeriod, Icons.date_range_outlined),
              ]),
              if (e.key > 0) Positioned(top: 8, right: 8, child: GestureDetector(
                onTap: () => widget.onRemoveEdu(e.key),
                child: Container(width: 26, height: 26, decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444))),
              )),
            ]),
          )),
          _addBtn(t.addEducation, widget.onAddEdu),
        ],

        _sec(t.sectionSkills),
        _card([
          _f(widget.skillsCtrl, t.fieldSkills, Icons.psychology_outlined, lines: 2),
          _f(widget.langsCtrl, t.fieldLangs, Icons.language_rounded),
        ]),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            onPressed: widget.onGenerate,
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

  Widget _sec(String label) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 10), child: Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)));
  Widget _secOpt(String label, String sub) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 10), child: Row(children: [Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)), const SizedBox(width: 8), Text(sub, style: GoogleFonts.montserrat(fontSize: 11, color: const Color(0xFFCBD5E1)))]));

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 3), color: Colors.black.withOpacity(0.04))]),
    child: Column(children: children.asMap().entries.map((e) {
      final last = e.key == children.length - 1;
      return Column(children: [e.value, if (!last) Divider(height: 1, indent: 14, endIndent: 14, color: Colors.black.withOpacity(0.04))]);
    }).toList()),
  );

  Widget _f(TextEditingController ctrl, String hint, IconData icon, {TextInputType? type, int lines = 1}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF94A3B8), size: 17), const SizedBox(width: 10),
      Expanded(child: TextField(controller: ctrl, keyboardType: type, maxLines: lines,
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.montserrat(fontSize: 13, color: const Color(0xFFCBD5E1)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 13)),
      )),
    ]),
  );

  Widget _addBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.add_rounded, color: Color(0xFF64748B), size: 16), const SizedBox(width: 6),
        Text(label, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
      ]),
    ),
  );
}

class LoadingStep extends StatelessWidget {
  final ResumeL10n t;
  const LoadingStep({super.key, required this.t});

  @override
  Widget build(BuildContext context) => Container(
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


class PreviewStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final int templateIndex;
  final VoidCallback onDownload, onEdit;
  final ResumeL10n t;
  const PreviewStep({super.key, required this.data, required this.templateIndex, required this.onDownload, required this.onEdit, required this.t});

  static const _accents = [Color(0xFF1B4332), Color(0xFF1E293B), Color(0xFFB45309)];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[templateIndex];
    return SingleChildScrollView(child: Column(children: [
      Container(
        color: accent, padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Row(children: [
          const Text('🎉', style: TextStyle(fontSize: 28)), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.readyTitle, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(t.readySub, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54)),
          ])),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(blurRadius: 24, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.08))]),
            clipBehavior: Clip.hardEdge,
            child: buildResumePreview(data, templateIndex),
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
            onPressed: onDownload,
            style: ElevatedButton.styleFrom(backgroundColor: accent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.download_rounded, color: Colors.white, size: 20), const SizedBox(width: 8),
              Text(t.downloadPdf, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
            ]),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(side: BorderSide(color: accent, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text(t.editResume, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    ]));
  }
}