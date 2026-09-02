import 'package:flutter/material.dart';

import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';
import 'nemo_top_bar.dart';

/// A Nemo-owned base canvas for composing an application page.
///
/// The page owns its base color, safe-area-aware content placement, and
/// tokenized default insets. Scrolling, routing, typography, and interactive
/// behavior remain owned by the supplied [child] and [topBar] slots.
class NemoPage extends StatelessWidget {
  /// Creates a page with an optional persistent [NemoTopBar].
  const NemoPage({
    required this.child,
    this.topBar,
    this.padding,
    this.maxContentWidth = 1200,
    super.key,
  }) : assert(maxContentWidth > 0 && maxContentWidth < double.infinity);

  /// The caller-owned page content. It may be scrollable.
  final Widget child;

  /// Optional persistent page chrome.
  final NemoTopBar? topBar;

  /// Insets around [child]. Defaults to the foundation large spacing token.
  final EdgeInsetsGeometry? padding;

  /// The largest width allocated to content on wide displays.
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? EdgeInsetsDirectional.all(theme.foundation.space24);
    return Scaffold(
      backgroundColor: theme.semantic.surface,
      appBar: topBar,
      body: SafeArea(
        top: topBar == null,
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(padding: resolvedPadding, child: child),
          ),
        ),
      ),
    );
  }
}
