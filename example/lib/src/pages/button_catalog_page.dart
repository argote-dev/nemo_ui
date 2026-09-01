import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

import '../nemo_page_shell.dart';

/// Demonstrates button resting, disabled, and loading states.
class ButtonCatalogPage extends StatefulWidget {
  /// Creates the button catalog page.
  const ButtonCatalogPage({super.key});

  @override
  State<ButtonCatalogPage> createState() => _ButtonCatalogPageState();
}

class _ButtonCatalogPageState extends State<ButtonCatalogPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPageShell(
      key: const ValueKey<String>('NemoButtonScreen'),
      title: 'NemoButton',
      child: ListView(
        padding: EdgeInsets.all(theme.foundation.space24),
        children: <Widget>[
          Text(
            'Action states',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: theme.foundation.space8),
          Text(
            'The loading state blocks duplicate activation and announces progress.',
            style: TextStyle(color: theme.semantic.mutedForeground),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSurface(
            tone: NemoSurfaceTone.surfaceVariant,
            child: Wrap(
              spacing: theme.foundation.space12,
              runSpacing: theme.foundation.space12,
              children: <Widget>[
                NemoButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _loading = true),
                  isLoading: _loading,
                  child: const Text('Submit'),
                ),
                const NemoButton(onPressed: null, child: Text('Disabled')),
                NemoButton(
                  onPressed: _loading
                      ? () => setState(() => _loading = false)
                      : null,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
