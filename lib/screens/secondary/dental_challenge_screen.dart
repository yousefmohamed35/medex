import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/app_colors.dart';
import '../../core/navigation/route_names.dart';
import '../../services/dental_challenge_service.dart';

class DentalChallengeScreen extends StatefulWidget {
  const DentalChallengeScreen({super.key});

  @override
  State<DentalChallengeScreen> createState() => _DentalChallengeScreenState();
}

class _DentalChallengeScreenState extends State<DentalChallengeScreen> {
  final _titleController = TextEditingController();
  bool _loading = true;
  bool _joining = false;
  bool _submitting = false;
  String? _error;

  Map<String, dynamic> _home = {};
  List<Map<String, dynamic>> _brands = [];
  String? _brandId;
  final List<Map<String, dynamic>> _attachments = [];

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';
  Map<String, dynamic> get _challenge =>
      (_home['challenge'] as Map?)?.cast<String, dynamic>() ?? {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _l(Map<String, dynamic> map, String key, {String fallback = ''}) =>
      DentalChallengeService.pickLocalized(map, key, _isAr, fallback: fallback);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        DentalChallengeService.instance.getHome(),
        DentalChallengeService.instance.getBrands(),
      ]);
      if (!mounted) return;
      final brands = results[1] as List<Map<String, dynamic>>;
      setState(() {
        _home = results[0] as Map<String, dynamic>;
        _brands = brands;
        _brandId = brands.isEmpty ? null : brands.first['id']?.toString();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  Future<void> _join() async {
    final id = _challenge['id']?.toString() ?? '';
    if (id.isEmpty) return;
    setState(() => _joining = true);
    try {
      await DentalChallengeService.instance.joinChallenge(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Joined successfully')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _upload() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (picked == null) return;
    for (final f in picked.files) {
      if (f.path == null || _attachments.length >= 20) continue;
      try {
        final url =
            await DentalChallengeService.instance.uploadAsset(File(f.path!));
        if (!mounted) return;
        final ext = (f.extension ?? '').toLowerCase();
        setState(() {
          _attachments.add({
            'type': ext == 'pdf' ? 'pdf' : 'image',
            'url': url,
            'name': f.name,
          });
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _submit() async {
    final id = _challenge['id']?.toString() ?? '';
    final title = _titleController.text.trim();
    if (id.isEmpty || (_brandId ?? '').isEmpty || title.length < 8 || _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await DentalChallengeService.instance.submitCase(
        challengeId: id,
        title: title,
        brandId: _brandId!,
        attachments: _attachments
            .map((e) => {'type': e['type'], 'url': e['url']})
            .toList(),
      );
      if (!mounted) return;
      setState(() {
        _titleController.clear();
        _attachments.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case submitted successfully')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final rules = ((_home['rules'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => _l(Map<String, dynamic>.from(e), 'text'))
        .toList();
    final steps = ((_home['steps'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final prizes = ((_home['prizes'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final winners = ((_home['last_week_winners'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final gallery = ((_home['gallery_preview'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: ListTile(
                  leading: IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                  title: Text(
                    _isAr ? 'تحدي الأسنان' : 'Dental Challenge',
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Container(
              color: const Color(0xFF121214),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_l(_challenge, 'week_label', fallback: 'WEEK'),
                      style: GoogleFonts.cairo(
                          color: Colors.white70, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(_l(_challenge, 'title', fallback: 'Best Implant Case'),
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(_l(_challenge, 'subtitle', fallback: 'Win amazing rewards'),
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _joining ? null : _join,
                          child: Text(_joining ? '...' : 'Join Now'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _stat('${_challenge['submissions_count'] ?? 0}', 'SUBMISSIONS'),
                      const SizedBox(width: 8),
                      _stat('${_challenge['winners_count'] ?? 0}', 'WINNERS'),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!,
                    style: GoogleFonts.cairo(
                        color: const Color(0xFFB42318), fontWeight: FontWeight.w700)),
              ),
            _card(
              title: _isAr ? 'قواعد التحدي' : 'Challenge Rules',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.map((r) => Text('• $r')).toList(),
              ),
            ),
            _card(
              title: _isAr ? 'طريقة المشاركة' : 'How to Participate',
              child: Column(
                children: steps
                    .map(
                      (s) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text('${s['step_no'] ?? ''}',
                              style: GoogleFonts.cairo(color: Colors.white)),
                        ),
                        title: Text(_l(s, 'title')),
                        subtitle: Text(_l(s, 'subtitle')),
                      ),
                    )
                    .toList(),
              ),
            ),
            _card(
              title: _isAr ? 'الجوائز' : 'Prizes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: prizes
                    .map((p) => Text('${p['emoji'] ?? '🎁'} ${_l(p, 'title')}'))
                    .toList(),
              ),
            ),
            _card(
              title: _isAr ? 'أرسل حالتك' : 'Submit Your Case',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton(
                    onPressed: _upload,
                    child: Text(_isAr ? 'رفع الملفات' : 'Upload files'),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _attachments
                        .map((a) => Chip(
                              label: Text(a['name']?.toString() ?? 'file'),
                              onDeleted: () => setState(() => _attachments.remove(a)),
                            ))
                        .toList(),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Case title'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: (_brandId != null &&
                            _brands.any((b) => b['id']?.toString() == _brandId))
                        ? _brandId
                        : null,
                    items: _brands
                        .map((b) => DropdownMenuItem(
                              value: b['id']?.toString() ?? '',
                              child: Text(_l(b, 'name', fallback: 'Brand')),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _brandId = v),
                    decoration: const InputDecoration(labelText: 'Implant brand'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Submitting...' : 'Submit Case'),
                  ),
                ],
              ),
            ),
            _card(
              title: _isAr ? 'الفائزون الأسبوع الماضي' : "Last Week's Winners",
              child: Column(
                children: winners
                    .map((w) => ListTile(
                          dense: true,
                          title: Text(_l(w, 'doctor_name')),
                          subtitle: Text(_l(w, 'subtitle')),
                          trailing: Text('${w['points'] ?? 0} pts'),
                        ))
                    .toList(),
              ),
            ),
            _card(
              title: _isAr ? 'معرض المشاركات' : 'Submissions Gallery',
              child: Column(
                children: gallery
                    .map((g) => ListTile(
                          dense: true,
                          title: Text(_l(g, 'doctor_name')),
                          subtitle: Text(
                              '👍 ${g['likes_count'] ?? 0} · 👁 ${g['views_count'] ?? 0} · 💬 ${g['comments_count'] ?? 0}'),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String top, String bottom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(top, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w800)),
          Text(bottom,
              style: GoogleFonts.cairo(color: const Color(0xFF98A2B3), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

