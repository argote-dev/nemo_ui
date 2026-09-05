import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// A settings flow used as a Theme Contract v2 conformance scene.
class SettingsFlowPage extends StatefulWidget {
  /// Creates the settings flow scene.
  const SettingsFlowPage({super.key});

  @override
  State<SettingsFlowPage> createState() => _SettingsFlowPageState();
}

class _SettingsFlowPageState extends State<SettingsFlowPage> {
  late final TextEditingController _displayName;
  bool _dailyBrief = true;
  String _status = 'Unsaved changes';

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController(text: 'Ada Lovelace');
  }

  @override
  void dispose() {
    _displayName.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _status = 'Preferences saved');
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      key: const ValueKey<String>('SettingsFlowScreen'),
      topBar: const NemoTopBar(title: Text('Settings')),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          NemoSection(
            heading: Text(
              'Workspace identity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            description: const Text(
              'Recessed input, binary controls, and one primary action island.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NemoField(
                  label: 'Display name',
                  hintText: 'Shown to other workspace members',
                  supportingText: 'This name appears on shared briefs.',
                  controller: _displayName,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _status = 'Unsaved changes'),
                ),
                SizedBox(height: theme.foundation.space24),
                NemoSwitch(
                  value: _dailyBrief,
                  semanticLabel: 'Daily brief',
                  onChanged: (bool value) => setState(() {
                    _dailyBrief = value;
                    _status = 'Unsaved changes';
                  }),
                  child: const Text('Daily brief'),
                ),
                SizedBox(height: theme.foundation.space16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    key: const ValueKey<String>('settings-status'),
                    _status,
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSurface(
            key: const ValueKey<String>('settings-action-island'),
            material: NemoMaterial.raised,
            child: NemoButton(
              semanticLabel: 'Save preferences',
              onPressed: _save,
              child: const Text('Save preferences'),
            ),
          ),
        ],
      ),
    );
  }
}
