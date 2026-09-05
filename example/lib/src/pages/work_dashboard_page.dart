import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// A realistic work dashboard used as a Theme Contract v2 conformance scene.
class WorkDashboardPage extends StatefulWidget {
  /// Creates the work dashboard scene.
  const WorkDashboardPage({super.key});

  @override
  State<WorkDashboardPage> createState() => _WorkDashboardPageState();
}

class _WorkDashboardPageState extends State<WorkDashboardPage> {
  bool _hasCapturedTask = false;
  Timer? _confirmationTimer;

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    super.dispose();
  }

  void _captureTask() {
    _confirmationTimer?.cancel();
    setState(() => _hasCapturedTask = true);
    _confirmationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _hasCapturedTask = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      key: const ValueKey<String>('WorkDashboardScreen'),
      topBar: const NemoTopBar(title: Text('Work dashboard')),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 650;
          final Widget inbox = NemoSurface(
            key: const ValueKey<String>('dashboard-receiving-area'),
            material: NemoMaterial.recessed,
            child: _Inbox(theme: theme, captured: _hasCapturedTask),
          );
          final Widget actions = NemoSurface(
            key: const ValueKey<String>('dashboard-action-island'),
            material: NemoMaterial.raised,
            child: _Actions(theme: theme, onCapture: _captureTask),
          );
          return Stack(
            children: <Widget>[
              ListView(
                key: const ValueKey<String>('dashboard-base-canvas'),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  NemoSection(
                    heading: Text(
                      'Today’s work',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    description: const Text(
                      'One canvas, a recessed inbox, and restrained raised actions.',
                    ),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: inbox),
                              SizedBox(width: theme.foundation.space24),
                              Expanded(child: actions),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              inbox,
                              SizedBox(height: theme.foundation.space24),
                              actions,
                            ],
                          ),
                  ),
                ],
              ),
              if (_hasCapturedTask)
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: NemoSurface(
                    key: const ValueKey<String>('dashboard-floating-plane'),
                    material: NemoMaterial.floating,
                    cornerRole: NemoCornerRole.floating,
                    child: const Text(
                      'Task captured — transient confirmation.',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Inbox extends StatelessWidget {
  const _Inbox({required this.theme, required this.captured});

  final NemoThemeData theme;
  final bool captured;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: const Text('Incoming queue')),
        SizedBox(height: theme.foundation.space12),
        Text(captured ? 'Task captured' : 'Two items waiting'),
        SizedBox(height: theme.foundation.space8),
        Text(
          captured
              ? 'The inbox will refresh on the next sync.'
              : 'Review the next briefing or capture a new task.',
          style: TextStyle(color: theme.semantic.mutedForeground),
        ),
      ],
    ),
  );
}

class _Actions extends StatelessWidget {
  const _Actions({required this.theme, required this.onCapture});

  final NemoThemeData theme;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(header: true, child: const Text('Actions')),
        SizedBox(height: theme.foundation.space12),
        NemoButton(
          semanticLabel: 'Capture task',
          onPressed: onCapture,
          child: const Text('Capture task'),
        ),
        SizedBox(height: theme.foundation.space12),
        NemoButton(
          semanticLabel: 'Open briefing',
          onPressed: () {},
          child: const Text('Open briefing'),
        ),
      ],
    ),
  );
}
