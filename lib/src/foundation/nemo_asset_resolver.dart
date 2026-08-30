import 'package:flutter/widgets.dart';

/// Semantic asset slots that components can request without knowing a path.
enum NemoAsset {
  /// A product or brand mark supplied by the host application.
  brandMark,

  /// An empty-state illustration supplied by the host application.
  emptyStateIllustration,
}

/// Resolves host-provided assets for a subtree.
///
/// Nemo never registers assets at runtime. A resolver selects a source the host
/// has already made available, such as an [ImageProvider] or a custom widget.
abstract interface class NemoAssetResolver {
  /// Returns an image for [asset], or null to leave the slot unresolved.
  ImageProvider<Object>? imageFor(NemoAsset asset, BuildContext context);

  /// Returns a widget for [asset], or null to leave the slot unresolved.
  ///
  /// This supports non-raster assets such as an icon widget while preserving
  /// the same semantic key used for image-based branding.
  Widget? widgetFor(NemoAsset asset, BuildContext context);
}

/// Injects a [NemoAssetResolver] for its descendant subtree.
class NemoAssetScope extends InheritedWidget {
  /// Creates an asset resolver scope.
  const NemoAssetScope({
    required this.resolver,
    required super.child,
    super.key,
  });

  /// The resolver available to descendant Nemo components.
  final NemoAssetResolver resolver;

  /// Returns the nearest resolver, or null when the host has not provided one.
  static NemoAssetResolver? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NemoAssetScope>()
        ?.resolver;
  }

  /// Returns the nearest resolver.
  ///
  /// Throws a descriptive error instead of using a global fallback, so nested
  /// branded subtrees remain explicit and independently configurable.
  static NemoAssetResolver of(BuildContext context) {
    return maybeOf(context) ??
        (throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No NemoAssetScope found in the widget tree.'),
          ErrorDescription(
            'Wrap the relevant subtree with NemoAssetScope to provide '
            'host-owned assets.',
          ),
        ]));
  }

  @override
  bool updateShouldNotify(NemoAssetScope oldWidget) {
    return resolver != oldWidget.resolver;
  }
}
