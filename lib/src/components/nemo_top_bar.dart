import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// A persistent, edge-to-edge page top bar for a Nemo experience.
///
/// Its [preferredSize] contains only the invariant 64 logical-pixel toolbar.
/// The internal [SafeArea] consumes status-bar and lateral system insets while
/// the surface remains painted behind them, both in a [Scaffold.appBar] and in
/// normal flow.
class NemoTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a top bar with caller-owned navigation and action slots.
  const NemoTopBar({
    required this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions = const <Widget>[],
    this.systemOverlayStyle,
    super.key,
  });

  /// The stable toolbar height, excluding system insets.
  static const double toolbarHeight = 64;

  /// Header content displayed in the middle slot.
  final Widget title;

  /// Optional navigation content at the directional start edge.
  final Widget? leading;

  /// Whether to use Flutter's dismissible-route convention when [leading] is
  /// absent.
  ///
  /// An explicit [leading] always takes precedence. The implicit control is a
  /// [BackButton] that calls [Navigator.maybePop], and is only inserted when
  /// the enclosing route implies app-bar dismissal.
  final bool automaticallyImplyLeading;

  /// Optional caller-owned widgets at the directional end edge.
  final List<Widget> actions;

  /// Optional local system-overlay override.
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoTopBarTokens tokens = theme.components.topBar;
    final Color surface = theme.semantic.surface;
    final SystemUiOverlayStyle overlayStyle =
        systemOverlayStyle ?? _automaticOverlayStyle(surface);
    final Widget? resolvedLeading = _resolveLeading(context);

    Widget minimumTarget(Widget child) => ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Align(widthFactor: 1, heightFactor: 1, child: child),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            bottom: BorderSide(
              color: theme.semantic.outline.withValues(
                alpha: tokens.boundaryOpacity,
              ),
              width: theme.components.outlineWidth,
            ),
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          left: true,
          right: true,
          child: SizedBox(
            height: toolbarHeight,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: tokens.horizontalPadding,
              ),
              child: NavigationToolbar(
                leading: resolvedLeading == null
                    ? null
                    : minimumTarget(resolvedLeading),
                middle: DefaultTextStyle.merge(
                  style: TextStyle(color: theme.semantic.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Semantics(header: true, child: title),
                ),
                trailing: actions.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Widget action in actions)
                            minimumTarget(action),
                        ],
                      ),
                middleSpacing: tokens.titleSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _resolveLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }
    if (!automaticallyImplyLeading ||
        ModalRoute.of(context)?.impliesAppBarDismissal != true) {
      return null;
    }
    return BackButton(onPressed: () => Navigator.maybePop(context));
  }

  SystemUiOverlayStyle _automaticOverlayStyle(Color surface) {
    final bool lightSurface =
        ThemeData.estimateBrightnessForColor(surface) == Brightness.light;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: lightSurface
          ? Brightness.dark
          : Brightness.light,
      // iOS uses the status-bar background brightness rather than icon mode.
      statusBarBrightness: lightSurface ? Brightness.light : Brightness.dark,
    );
  }
}
