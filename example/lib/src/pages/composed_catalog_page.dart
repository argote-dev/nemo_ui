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

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Scaffold(
      key: const ValueKey<String>('ComposedWorkspaceScreen'),
      appBar: AppBar(title: const Text('Composed workspace')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 650;
          final Widget summary = _Summary(theme: theme, saved: _isSaved);
          final Widget preferences = _Preferences(
            theme: theme,
            dailyBrief: _dailyBrief,
            onDailyBriefChanged: (bool value) =>
                setState(() => _dailyBrief = value),
            onSave: () => setState(() => _isSaved = true),
          );
          return ListView(
            padding: EdgeInsets.all(theme.foundation.space24),
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  'Workspace readiness',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SizedBox(height: theme.foundation.space8),
              Text(
                'A preference flow with clear labels, outlines, and status text.',
                style: TextStyle(color: theme.semantic.mutedForeground),
              ),
              SizedBox(height: theme.foundation.space24),
              NemoSurface(
                key: const ValueKey<String>('composed-workspace-canvas'),
                depth: NemoSurfaceDepth.flat,
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
  });

  final NemoThemeData theme;
  final bool dailyBrief;
  final ValueChanged<bool> onDailyBriefChanged;
  final VoidCallback onSave;

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
      ],
    ),
  );
}
