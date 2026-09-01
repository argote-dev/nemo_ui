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
    final bool canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: theme.semantic.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            NemoSurface(
              material: NemoMaterial.base,
              cornerRole: NemoCornerRole.panel,
              padding: EdgeInsets.symmetric(
                horizontal: theme.foundation.space16,
                vertical: theme.foundation.space8,
              ),
              child: Row(
                children: <Widget>[
                  if (canPop) const BackButton(),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
