import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// Native Flutter Widget Previewer definitions for Nemo's foundation.
@Preview(name: 'Light foundation', group: 'Foundation')
Widget lightFoundationPreview() {
  return _FoundationPreview(theme: NemoThemeData.light());
}

/// Native Flutter Widget Previewer definition for Nemo high contrast.
@Preview(name: 'High contrast foundation', group: 'Foundation')
Widget highContrastFoundationPreview() {
  return _FoundationPreview(theme: NemoThemeData.highContrast());
}

class _FoundationPreview extends StatelessWidget {
  const _FoundationPreview({required this.theme, this.child});

  final NemoThemeData theme;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          backgroundColor: NemoTheme.of(context).semantic.surface,
          body: Center(
            child:
                child ??
                Text(
                  'Nemo foundation',
                  style: TextStyle(
                    color: NemoTheme.of(context).semantic.foreground,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

/// Native Flutter Widget Previewer definition for the Surface component.
@Preview(name: 'Surface depths', group: 'Components')
Widget surfacePreview() {
  return _FoundationPreview(
    theme: NemoThemeData.light(),
    child: Wrap(
      spacing: 24,
      runSpacing: 24,
      children: <Widget>[
        for (final NemoMaterial material in NemoMaterial.values)
          NemoSurface(
            material: material,
            tone: NemoSurfaceTone.surfaceVariant,
            child: Text(material.name),
          ),
      ],
    ),
  );
}

/// Native Flutter Widget Previewer definitions for NemoButton states.
@Preview(name: 'Button states', group: 'Components')
Widget buttonPreview() => _FoundationPreview(
  theme: NemoThemeData.light(),
  child: Wrap(
    spacing: 16,
    runSpacing: 16,
    children: <Widget>[
      NemoButton(onPressed: () {}, child: const Text('Continue')),
      const NemoButton(onPressed: null, child: Text('Unavailable')),
      const NemoButton(isLoading: true, child: Text('Submit')),
    ],
  ),
);

/// Native Flutter Widget Previewer definitions for NemoSwitch states.
@Preview(name: 'Switch states', group: 'Components')
Widget switchPreview() => _FoundationPreview(
  theme: NemoThemeData.light(),
  child: Wrap(
    spacing: 16,
    runSpacing: 16,
    children: <Widget>[
      NemoSwitch(value: true, onChanged: (_) {}, child: const Text('Enabled')),
      NemoSwitch(
        value: false,
        onChanged: (_) {},
        child: const Text('Disabled'),
      ),
      const NemoSwitch(value: false, child: Text('Unavailable')),
    ],
  ),
);

/// Native Flutter Widget Previewer definitions for NemoField states.
@Preview(name: 'Field states', group: 'Components')
Widget fieldPreview() => _FoundationPreview(
  theme: NemoThemeData.light(),
  child: const SizedBox(
    width: 360,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NemoField(
          label: 'Display name',
          hintText: 'Enter your name',
          supportingText: 'Shown to other workspace members.',
        ),
        SizedBox(height: 24),
        NemoField(
          label: 'Email address',
          errorText: 'Enter a valid email address.',
        ),
        SizedBox(height: 24),
        NemoField(label: 'Account identifier', readOnly: true),
      ],
    ),
  ),
);

/// Native Flutter Widget Previewer definition for the page composition grammar.
@Preview(name: 'Page and section', group: 'Composition')
Widget pageAndSectionPreview() => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[NemoThemeData.light()],
  ),
  home: NemoPage(
    topBar: const NemoTopBar(title: Text('Account settings')),
    child: ListView(
      children: const <Widget>[
        NemoSection(
          heading: Text('Notifications'),
          description: Text('Choose how Nemo keeps you informed.'),
          child: NemoSwitch(
            value: true,
            onChanged: null,
            child: Text('Daily brief'),
          ),
        ),
      ],
    ),
  ),
);

/// Bounded transient floating treatment; persistent catalog surfaces stay standard.
@Preview(name: 'Tactile glass overlay', group: 'Composition')
Widget tactileGlassOverlayPreview() => _FoundationPreview(
  theme: NemoThemeData.light(),
  child: const SizedBox(
    width: 360,
    child: NemoSurface(
      material: NemoMaterial.floating,
      finish: NemoSurfaceFinish.tactileGlass,
      cornerRole: NemoCornerRole.floating,
      child: Text('Transient command palette'),
    ),
  ),
);
