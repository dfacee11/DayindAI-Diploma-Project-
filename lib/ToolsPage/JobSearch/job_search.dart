import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:dayindai/core/error_handler.dart';

class JobSearchPage extends StatefulWidget {
  const JobSearchPage({super.key});

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  final _searchController = TextEditingController();
  String _selectedArea = '160';
  bool _isLoading = false;
  List<dynamic> _vacancies = [];
  bool _hasSearched = false;

  final List<Map<String, String>> _areas = [
    {'id': '160',  'name': '🇰🇿 Казахстан'},
    {'id': '113',  'name': '🇷🇺 Россия'},
    {'id': '2114', 'name': '🇺🇿 Узбекистан'},
    {'id': '16',   'name': '🇦🇿 Азербайджан'},
    {'id': '97',   'name': '🌍 Весь мир'},
  ];

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _vacancies = [];
    });

    try {
      final uri = Uri.parse('https://api.hh.ru/vacancies').replace(
        queryParameters: {
          'text': query,
          'area': _selectedArea,
          'per_page': '20',
          'order_by': 'relevance',
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'DayindAI/1.0 (support@dayindai.app)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() => _vacancies = data['items'] ?? []);
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatSalary(Map<String, dynamic>? salary) {
    if (salary == null) return 'Зарплата не указана';
    final from = salary['from'];
    final to = salary['to'];
    final currency = salary['currency'] ?? '';
    if (from != null && to != null) return '$from — $to $currency';
    if (from != null) return 'от $from $currency';
    if (to != null) return 'до $to $currency';
    return 'Зарплата не указана';
  }

  Color _salaryColor(Map<String, dynamic>? salary) =>
      salary == null ? const Color(0xFF94A3B8) : const Color(0xFF10B981);

  Future<void> _openVacancy(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          langCode == 'ru' ? 'Поиск вакансий' : langCode == 'kk' ? 'Жұмыс іздеу' : 'Job Search',
          style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search area ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Icon(Icons.search_rounded, color: Colors.white54, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: langCode == 'ru' ? 'Например: Flutter, Python...' : 'E.g. Flutter, Python...',
                        hintStyle: GoogleFonts.montserrat(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedArea,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 18),
                        isExpanded: true,
                        items: _areas.map((area) => DropdownMenuItem<String>(
                          value: area['id'],
                          child: Text(area['name']!, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedArea = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _search,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF9F7AFF)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(langCode == 'ru' ? 'Найти' : 'Search',
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Results ──────────────────────────────────────────────────────
          Expanded(
            child: !_hasSearched
                ? _buildEmptyState(langCode)
                : _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C5CFF)))
                    : _vacancies.isEmpty
                        ? _buildNoResults(langCode)
                        : _buildResults(langCode),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String langCode) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔍', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text(
        langCode == 'ru' ? 'Введи должность и страну' : 'Enter a job title and country',
        style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
      ),
      const SizedBox(height: 8),
      Text('Powered by HH.ru', style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFF94A3B8))),
    ]),
  );

  Widget _buildNoResults(String langCode) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🐧', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text(
        langCode == 'ru' ? 'Вакансии не найдены' : 'No vacancies found',
        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
      ),
    ]),
  );

  Widget _buildResults(String langCode) => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(children: [
        Text(
          langCode == 'ru' ? 'Найдено: ${_vacancies.length} вакансий' : 'Found: ${_vacancies.length} vacancies',
          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('HH.ru', style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
        ),
      ]),
    ),
    Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _vacancies.length,
        itemBuilder: (ctx, i) {
          final v = _vacancies[i];
          final employer   = v['employer']?['name'] ?? '';
          final title      = v['name'] ?? '';
          final salary     = v['salary'];
          final area       = v['area']?['name'] ?? '';
          final url        = v['alternate_url'] ?? '';
          final experience = v['experience']?['name'] ?? '';

          return GestureDetector(
            onTap: () => _openVacancy(url),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(title, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)))),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.business_rounded, size: 14, color: Color(0xFF7C5CFF)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(employer, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF7C5CFF)))),
                ]),
                const SizedBox(height: 8),
                Text(_formatSalary(salary), style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w700, color: _salaryColor(salary))),
                const SizedBox(height: 6),
                Row(children: [
                  if (area.isNotEmpty) _tag(Icons.location_on_rounded, area, const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  if (experience.isNotEmpty) _tag(Icons.work_outline_rounded, experience, const Color(0xFF64748B)),
                ]),
              ]),
            ),
          );
        },
      ),
    ),
  ]);

  Widget _tag(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 3),
      Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ],
  );
}