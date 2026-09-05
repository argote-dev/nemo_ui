import 'package:flutter/material.dart';
import 'package:nemo_ui/nemo_ui.dart';

/// A catalog inspector used as a Theme Contract v2 conformance scene.
class CatalogInspectorPage extends StatefulWidget {
  /// Creates the catalog inspector scene.
  const CatalogInspectorPage({super.key});

  @override
  State<CatalogInspectorPage> createState() => _CatalogInspectorPageState();
}

class _CatalogInspectorPageState extends State<CatalogInspectorPage> {
  final FocusNode _inspectFocus = FocusNode(debugLabel: 'Inspect specimen');

  @override
  void dispose() {
    _inspectFocus.dispose();
    super.dispose();
  }

  Future<void> _openInspector() async {
    _inspectFocus.requestFocus();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => const _InspectorOverlay(),
    );
    if (mounted) {
      _inspectFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return NemoPage(
      key: const ValueKey<String>('CatalogInspectorScreen'),
      topBar: const NemoTopBar(title: Text('Catalog inspector')),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          NemoSection(
            heading: Text(
              'Inspect a specimen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            description: const Text(
              'Open one bounded floating inspector. Canvas remains the fallback.',
            ),
            child: NemoButton(
              semanticLabel: 'Inspect specimen',
              focusNode: _inspectFocus,
              onPressed: _openInspector,
              child: const Text('Inspect specimen'),
            ),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSection(
            heading: Text(
              'Component states',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            description: const Text(
              'Focused state matrices for the primitives used by this program.',
            ),
            child: Wrap(
              spacing: theme.foundation.space16,
              runSpacing: theme.foundation.space16,
              children: <Widget>[
                NemoButton(
                  onPressed: () {},
                  child: const Text('Resting action'),
                ),
                const NemoButton(onPressed: null, child: Text('Unavailable')),
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: const NemoButton(
                    isLoading: true,
                    child: Text('Submit'),
                  ),
                ),
                NemoSwitch(
                  value: true,
                  onChanged: (_) {},
                  child: const Text('Selected'),
                ),
                NemoSwitch(
                  value: false,
                  onChanged: (_) {},
                  child: const Text('Unselected'),
                ),
                const SizedBox(
                  width: 280,
                  child: NemoField(
                    label: 'Specimen label',
                    supportingText: 'Resting recessed field.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: theme.foundation.space24),
          NemoSection(
            heading: Text(
              'Renderer comparison',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            description: const Text(
              'Canvas is the default. Fragment and tactile glass remain experimental.',
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth >= 720
                    ? (constraints.maxWidth - theme.foundation.space16 * 2) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: theme.foundation.space16,
                  runSpacing: theme.foundation.space16,
                  children: <Widget>[
                    _RendererCard(
                      width: width,
                      title: 'Canvas baseline',
                      status: 'Default',
                    ),
                    _RendererCard(
                      width: width,
                      title: 'Fragment finish',
                      status: 'Experimental, default-off',
                      enableProgressiveRendering: true,
                    ),
                    _RendererCard(
                      width: width,
                      title: 'Tactile glass',
                      status: 'Opt-in overlay only',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RendererCard extends StatelessWidget {
  const _RendererCard({
    required this.width,
    required this.title,
    required this.status,
    this.enableProgressiveRendering = false,
  });

  final double width;
  final String title;
  final String status;
  final bool enableProgressiveRendering;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    return SizedBox(
      width: width,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 160, minWidth: 240),
        child: NemoSurface(
          key: ValueKey<String>('renderer-${title.toLowerCase()}'),
          material: NemoMaterial.raised,
          enableProgressiveRendering: enableProgressiveRendering,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: theme.foundation.space8),
              Text(
                status,
                style: TextStyle(color: theme.semantic.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A route-owned inspector; Nemo does not expose a generic modal.
class _InspectorOverlay extends StatelessWidget {
  const _InspectorOverlay();

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
          label: 'Specimen inspector',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: NemoSurface(
              key: const ValueKey<String>('catalog-inspector-overlay'),
              material: NemoMaterial.floating,
              finish: NemoSurfaceFinish.tactileGlass,
              cornerRole: NemoCornerRole.floating,
              padding: EdgeInsets.all(theme.foundation.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: const Text('Specimen inspector'),
                  ),
                  SizedBox(height: theme.foundation.space8),
                  Text(
                    'A bounded floating overlay. Canvas remains the accessible fallback.',
                    style: TextStyle(color: theme.semantic.mutedForeground),
                  ),
                  SizedBox(height: theme.foundation.space16),
                  NemoButton(
                    semanticLabel: 'Mark as default candidate',
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Mark as default candidate'),
                  ),
                  SizedBox(height: theme.foundation.space12),
                  NemoButton(
                    semanticLabel: 'Dismiss inspector',
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
