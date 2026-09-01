// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Private example-only specimen frame; it is not a package primitive.
class NemoPageShell extends StatelessWidget {
  const NemoPageShell({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.semantic.surface,
      appBar: NemoTopBar(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      body: child,
    );
  }
}
