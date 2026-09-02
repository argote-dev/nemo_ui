import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Demonstrates editing integration and the complete NemoField state set.
class FieldCatalogPage extends StatefulWidget {
  /// Creates the field catalog page.
  const FieldCatalogPage({super.key});

  @override
  State<FieldCatalogPage> createState() => _FieldCatalogPageState();
}

class _FieldCatalogPageState extends State<FieldCatalogPage> {
  late final TextEditingController _filledController;
  String _submittedValue = '';

  @override
  void initState() {
    super.initState();
    _filledController = TextEditingController(text: 'Ada Lovelace');
  }

  @override
  void dispose() {
    _filledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      key: const ValueKey<String>('NemoFieldScreen'),
      topBar: const NemoTopBar(title: Text('NemoField')),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          NemoSection(
            heading: Text(
              'Text entry',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            description: const Text(
              'Persistent labels and explicit editing states share one recessed contract.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NemoField(
                  label: 'Display name',
                  hintText: 'Enter your name',
                  supportingText: 'Shown to other workspace members.',
                  textInputAction: TextInputAction.done,
                  onSubmitted: (String value) =>
                      setState(() => _submittedValue = value),
                ),
                if (_submittedValue.isNotEmpty) ...<Widget>[
                  SizedBox(height: theme.foundation.space8),
                  Text('Submitted: $_submittedValue'),
                ],
                SizedBox(height: theme.foundation.space24),
                NemoField(label: 'Filled', controller: _filledController),
                SizedBox(height: theme.foundation.space24),
                const NemoField(
                  label: 'Email address',
                  hintText: 'name@example.com',
                  errorText: 'Enter a valid email address.',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: theme.foundation.space24),
                const NemoField(
                  label: 'Unavailable value',
                  supportingText: 'Disabled fields cannot receive focus.',
                  enabled: false,
                ),
                SizedBox(height: theme.foundation.space24),
                const NemoField(
                  label: 'Account identifier',
                  supportingText: 'Read-only values remain selectable.',
                  readOnly: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
