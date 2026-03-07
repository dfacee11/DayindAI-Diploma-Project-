import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Error types ───────────────────────────────────────────────────────────────
enum AppErrorType { noInternet, timeout, server, auth, unknown }

class AppError {
  final AppErrorType type;
  final String message;
  final String? technical; // for debug logs only, never shown to user

  const AppError({required this.type, required this.message, this.technical});

  bool get isNoInternet => type == AppErrorType.noInternet;
  bool get isTimeout    => type == AppErrorType.timeout;
}

// ── Classifier ────────────────────────────────────────────────────────────────
class ErrorHandler {
  static AppError classify(Object error, BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final type = _detectType(error);
    return AppError(
      type: type,
      message: _message(type, lang),
      technical: error.toString(),
    );
  }

  static AppErrorType _detectType(Object e) {
    final msg = e.toString().toLowerCase();

    if (e is SocketException || msg.contains('socketexception') || msg.contains('network is unreachable')) {
      return AppErrorType.noInternet;
    }
    if (e is FirebaseFunctionsException) {
      if (e.code == 'deadline-exceeded' || e.code == 'unavailable') return AppErrorType.timeout;
      if (e.code == 'unauthenticated' || e.code == 'permission-denied') return AppErrorType.auth;
      if (e.code == 'internal' || e.code == 'resource-exhausted') return AppErrorType.server;
      if (e.code == 'not-found') return AppErrorType.server;
    }
    if (msg.contains('timeout') || msg.contains('timeoutexception')) return AppErrorType.timeout;
    if (msg.contains('host lookup') || msg.contains('failed host')) return AppErrorType.noInternet;
    if (msg.contains('unauthenticated') || msg.contains('permission')) return AppErrorType.auth;

    return AppErrorType.unknown;
  }

  static String _message(AppErrorType type, String lang) {
    final isRu = lang == 'ru';
    final isKk = lang == 'kk';
    return switch (type) {
      AppErrorType.noInternet => isKk ? 'Интернет байланысы жоқ. Желіні тексер' : isRu ? 'Нет подключения к интернету. Проверь соединение' : 'No internet connection. Check your network',
      AppErrorType.timeout    => isKk ? 'Сервер жауап бермеді. Қайталап көр'       : isRu ? 'Сервер не ответил. Попробуй ещё раз'            : 'Server did not respond. Please try again',
      AppErrorType.server     => isKk ? 'Сервер қатесі. Кейінірек көр'             : isRu ? 'Ошибка сервера. Попробуй позже'                  : 'Server error. Please try later',
      AppErrorType.auth       => isKk ? 'Авторизация қатесі. Қайта кіріп көр'      : isRu ? 'Ошибка авторизации. Попробуй войти снова'        : 'Auth error. Please sign in again',
      AppErrorType.unknown    => isKk ? 'Қате орын алды. Қайталап көр'             : isRu ? 'Что-то пошло не так. Попробуй ещё раз'            : 'Something went wrong. Please try again',
    };
  }

  // ── Show snackbar (light, non-blocking) ──────────────────────────────────────
  static void showSnackbar(BuildContext context, Object error) {
    final appError = classify(error, context);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(children: [
          Icon(_icon(appError.type), color: _color(appError.type), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(appError.message, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }

  // ── Show full-screen error (for critical flows like AI generation) ────────────
  static Future<_ErrorAction> showDialog(BuildContext context, Object error, {bool canRetry = true, bool canEdit = false}) async {
    final appError = classify(error, context);
    final lang = Localizations.localeOf(context).languageCode;
    final result = await showModalBottomSheet<_ErrorAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ErrorSheet(error: appError, lang: lang, canRetry: canRetry, canEdit: canEdit),
    );
    return result ?? _ErrorAction.dismiss;
  }

  static IconData _icon(AppErrorType t) => switch (t) {
    AppErrorType.noInternet => Icons.wifi_off_rounded,
    AppErrorType.timeout    => Icons.hourglass_empty_rounded,
    AppErrorType.server     => Icons.cloud_off_rounded,
    AppErrorType.auth       => Icons.lock_outline_rounded,
    AppErrorType.unknown    => Icons.error_outline_rounded,
  };

  static Color _color(AppErrorType t) => switch (t) {
    AppErrorType.noInternet => const Color(0xFF60A5FA),
    AppErrorType.timeout    => const Color(0xFFFBBF24),
    AppErrorType.server     => const Color(0xFFF87171),
    AppErrorType.auth       => const Color(0xFFFBBF24),
    AppErrorType.unknown    => const Color(0xFFF87171),
  };
}

enum _ErrorAction { retry, edit, dismiss }

// ── Bottom sheet error UI ─────────────────────────────────────────────────────
class _ErrorSheet extends StatelessWidget {
  final AppError error;
  final String lang;
  final bool canRetry, canEdit;
  const _ErrorSheet({required this.error, required this.lang, required this.canRetry, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final isRu = lang == 'ru';
    final isKk = lang == 'kk';

    final String retryLabel   = isKk ? 'Қайталау'            : isRu ? 'Попробовать снова'   : 'Try again';
    final String editLabel    = isKk ? 'Деректерді өзгерту'  : isRu ? 'Изменить данные'     : 'Edit data';
    final String dismissLabel = isKk ? 'Жабу'                : isRu ? 'Закрыть'              : 'Dismiss';

    final accent = ErrorHandler._color(error.type);
    final icon   = ErrorHandler._icon(error.type);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),

        // Icon
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: accent.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: accent, size: 30),
        ),
        const SizedBox(height: 16),

        // Message
        Text(error.message,
          style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),

        // Buttons
        if (canRetry) ...[
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _ErrorAction.retry),
              style: ElevatedButton.styleFrom(backgroundColor: accent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(retryLabel, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (canEdit) ...[
          SizedBox(
            width: double.infinity, height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, _ErrorAction.edit),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(editLabel, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white60)),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity, height: 44,
          child: TextButton(
            onPressed: () => Navigator.pop(context, _ErrorAction.dismiss),
            child: Text(dismissLabel, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white38)),
          ),
        ),
      ]),
    );
  }
}