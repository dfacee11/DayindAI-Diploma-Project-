import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Global connectivity service.
/// Wrap your app with [ConnectivityProvider] and listen anywhere via
/// ConnectivityService.of(context).isOnline
class ConnectivityService extends ChangeNotifier {
  static ConnectivityService? _instance;
  static ConnectivityService get instance {
    _instance ??= ConnectivityService._();
    return _instance!;
  }

  ConnectivityService._() {
    _startPolling();
  }

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _timer;

  void _startPolling() {
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkNow());
  }

  Future<void> _checkNow() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    }
  }

  /// One-shot check before any network call
  Future<bool> checkOnce() async {
    await _checkNow();
    return _isOnline;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Put this at the root of your widget tree (inside MaterialApp builder)
class ConnectivityProvider extends StatefulWidget {
  final Widget child;
  const ConnectivityProvider({super.key, required this.child});

  @override
  State<ConnectivityProvider> createState() => _ConnectivityProviderState();
}

class _ConnectivityProviderState extends State<ConnectivityProvider> {
  final _service = ConnectivityService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ConnectivityInheritedWidget(
      isOnline: _service.isOnline,
      child: Column(children: [
        Expanded(child: widget.child),
        if (!_service.isOnline) const _OfflineBanner(),
      ]),
    );
  }
}

class _ConnectivityInheritedWidget extends InheritedWidget {
  final bool isOnline;
  const _ConnectivityInheritedWidget({required this.isOnline, required super.child});

  static _ConnectivityInheritedWidget? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ConnectivityInheritedWidget>();

  @override
  bool updateShouldNotify(_ConnectivityInheritedWidget old) => old.isOnline != isOnline;
}

/// Access connectivity status anywhere
extension ConnectivityContext on BuildContext {
  bool get isOnline => _ConnectivityInheritedWidget.of(this)?.isOnline ?? true;
}

// ── Offline banner ────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: const Color(0xFF1E293B),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: Color(0xFF334155), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded, color: Color(0xFF94A3B8), size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_title(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            Text(_subtitle(context), style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ])),
        ]),
      ),
    );
  }

  String _title(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'ru' => 'Нет подключения',
      'kk' => 'Байланыс жоқ',
      _    => 'No internet connection',
    };
  }

  String _subtitle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return switch (lang) {
      'ru' => 'Некоторые функции могут не работать',
      'kk' => 'Кейбір мүмкіндіктер жұмыс істемеуі мүмкін',
      _    => 'Some features may not be available',
    };
  }
}