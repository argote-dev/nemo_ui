import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Demonstrates controlled, disabled, and localized switch states.
class SwitchCatalogPage extends StatefulWidget {
  /// Creates the switch catalog page.
  const SwitchCatalogPage({super.key});

  @override
  State<SwitchCatalogPage> createState() => _SwitchCatalogPageState();
}

class _SwitchCatalogPageState extends State<SwitchCatalogPage> {
  bool _notifications = true;
  bool _updates = false;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return Scaffold(
      key: const ValueKey<String>('NemoSwitchScreen'),
      appBar: AppBar(title: const Text('NemoSwitch')),
      body: ListView(
        padding: EdgeInsets.all(theme.foundation.space24),
        children: <Widget>[
          Text(
            'Binary selection',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: theme.foundation.space8),
          Text(
            'Each switch remains controlled by the screen state.',
            style: TextStyle(color: theme.semantic.mutedForeground),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSurface(
            tone: NemoSurfaceTone.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                NemoSwitch(
                  value: _notifications,
                  onChanged: (bool value) =>
                      setState(() => _notifications = value),
                  child: const Text('Notifications'),
                ),
                SizedBox(height: theme.foundation.space16),
                NemoSwitch(
                  value: _updates,
                  onChanged: (bool value) => setState(() => _updates = value),
                  child: const Text('Product updates'),
                ),
                SizedBox(height: theme.foundation.space16),
                const NemoSwitch(value: false, child: Text('Unavailable')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
