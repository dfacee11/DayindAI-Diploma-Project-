import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dayindai/core/error_handler.dart';

mixin ErrorListenerMixin<T extends StatefulWidget> on State<T> {
  Object? _shownError;

  void listenForErrors<P extends ChangeNotifier>({
    required Object? Function(P) getError,
    required void Function(P) clearError,
  }) {
    final provider = context.read<P>();
    final error = getError(provider);

    if (error != null && error != _shownError) {
      _shownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ErrorHandler.showSnackbar(context, error);
          clearError(context.read<P>());
          _shownError = null;
        }
      });
    }
  }
}










































