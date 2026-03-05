import 'package:flutter/material.dart';

class LocaleNotifier extends InheritedWidget {
  final void Function(Locale) setLocale;

  const LocaleNotifier({
    super.key,
    required this.setLocale,
    required super.child,
  });

  static LocaleNotifier? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleNotifier>();

  @override
  bool updateShouldNotify(LocaleNotifier old) => false;
}