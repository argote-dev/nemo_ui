import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// A realistic preference workflow composed from Nemo foundation controls.
class ComposedCatalogPage extends StatefulWidget {
  /// Creates the composed workspace demonstration.
  const ComposedCatalogPage({super.key});

  @override
  State<ComposedCatalogPage> createState() => _ComposedCatalogPageState();
}

class _ComposedCatalogPageState extends State<ComposedCatalogPage> {
  bool _dailyBrief = true;
  bool _isSaved = false;
  Timer? _confirmationTimer;
  final FocusNode _commandPaletteFocus = FocusNode(
    debugLabel: 'Command palette trigger',
  );

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    _commandPaletteFocus.dispose();
    super.dispose();
  }

  Future<void> _openCommandPalette() async {
    _commandPaletteFocus.requestFocus();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => const _CommandPaletteDialog(),
    );
    if (mounted) _commandPaletteFocus.requestFocus();
  }

  void _save() {
    _confirmationTimer?.cancel();
    setState(() => _isSaved = true);
    _confirmationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isSaved = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      key: const ValueKey<String>('ComposedWorkspaceScreen'),
      topBar: const NemoTopBar(title: Text('Composed workspace')),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 650;
          final Widget summary = NemoSurface(
            key: const ValueKey<String>('composed-material-recessed'),
            material: NemoMaterial.recessed,
            child: _Summary(theme: theme, saved: _isSaved),
          );
          final Widget preferences = NemoSurface(
            key: const ValueKey<String>('composed-material-raised'),
            material: NemoMaterial.raised,
            child: _Preferences(
              theme: theme,
              dailyBrief: _dailyBrief,
              onDailyBriefChanged: (bool value) =>
                  setState(() => _dailyBrief = value),
              onSave: _save,
              onOpenCommandPalette: _openCommandPalette,
              commandPaletteFocusNode: _commandPaletteFocus,
            ),
          );
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              NemoSection(
                heading: Text(
                  'Workspace readiness',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                description: const Text(
                  'A preference flow with clear labels, outlines, and status text.',
                ),
                child: NemoSurface(
                  key: const ValueKey<String>('composed-workspace-canvas'),
                  material: NemoMaterial.base,
                  tone: NemoSurfaceTone.surfaceVariant,
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: summary),
                            SizedBox(width: theme.foundation.space24),
                            Expanded(child: preferences),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            summary,
                            SizedBox(height: theme.foundation.space24),
                            preferences,
                          ],
                        ),
                ),
              ),
              if (_isSaved) ...<Widget>[
                SizedBox(height: theme.foundation.space16),
                NemoSurface(
                  key: const ValueKey<String>('composed-material-floating'),
                  material: NemoMaterial.floating,
                  cornerRole: NemoCornerRole.floating,
                  child: const Text(
                    'Preferences saved — transient confirmation.',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.theme, required this.saved});

  final NemoThemeData theme;
  final bool saved;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: const Text('Today’s workspace')),
        SizedBox(height: theme.foundation.space12),
        const Icon(Icons.wb_sunny_outlined, size: 36),
        SizedBox(height: theme.foundation.space12),
        Text(saved ? 'Preferences saved' : 'Ready to personalize'),
        SizedBox(height: theme.foundation.space8),
        Text(
          saved
              ? 'Your daily brief will use these choices.'
              : 'Choose a delivery preference to begin.',
          style: TextStyle(color: theme.semantic.mutedForeground),
        ),
      ],
    ),
  );
}

class _Preferences extends StatelessWidget {
  const _Preferences({
    required this.theme,
    required this.dailyBrief,
    required this.onDailyBriefChanged,
    required this.onSave,
    required this.onOpenCommandPalette,
    required this.commandPaletteFocusNode,
  });

  final NemoThemeData theme;
  final bool dailyBrief;
  final ValueChanged<bool> onDailyBriefChanged;
  final VoidCallback onSave;
  final VoidCallback onOpenCommandPalette;
  final FocusNode commandPaletteFocusNode;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: const Text('Delivery preference')),
        SizedBox(height: theme.foundation.space12),
        NemoSwitch(
          value: dailyBrief,
          semanticLabel: 'Daily brief',
          onChanged: onDailyBriefChanged,
          child: const Text('Daily brief'),
        ),
        SizedBox(height: theme.foundation.space16),
        NemoButton(
          semanticLabel: 'Save preferences',
          onPressed: onSave,
          child: const Text('Save preferences'),
        ),
        SizedBox(height: theme.foundation.space12),
        NemoButton(
          semanticLabel: 'Open command palette',
          focusNode: commandPaletteFocusNode,
          onPressed: onOpenCommandPalette,
          child: const Text('Open command palette'),
        ),
      ],
    ),
  );
}

/// A route-owned transient composition; Nemo does not expose a generic modal.
class _CommandPaletteDialog extends StatelessWidget {
  const _CommandPaletteDialog();

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return FocusTraversalGroup(
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          namesRoute: true,
          label: 'Command palette',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: NemoSurface(
              key: const ValueKey<String>('composed-command-palette'),
              material: NemoMaterial.floating,
              finish: NemoSurfaceFinish.tactileGlass,
              cornerRole: NemoCornerRole.floating,
              padding: EdgeInsets.all(theme.foundation.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(header: true, child: const Text('Command palette')),
                  SizedBox(height: theme.foundation.space8),
                  Text(
                    'Find a workspace action without leaving this page.',
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                  SizedBox(height: theme.foundation.space16),
                  NemoButton(
                    semanticLabel: 'Create workspace',
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Create workspace'),
                  ),
                  SizedBox(height: theme.foundation.space12),
                  NemoButton(
                    semanticLabel: 'Dismiss command palette',
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
