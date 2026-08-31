import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_motion.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// A token-driven primary action with tactile feedback and accessible controls.
///
/// [NemoButton] owns its interactive states. In particular, [isLoading]
/// disables activation and replaces descendant semantics with the localized
/// system loading label. The caller retains ownership of visible [child]
/// content.
class NemoButton extends StatefulWidget {
  /// Creates a Nemo primary action.
  const NemoButton({
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// Visible content for the action.
  final Widget child;

  /// Invoked after a tap, Enter, or Space activation when enabled.
  final VoidCallback? onPressed;

  /// Whether the system is processing the action and must block activation.
  final bool isLoading;

  /// Optional accessible name for the action.
  final String? semanticLabel;

  /// Whether this button receives focus when it is first built.
  final bool autofocus;

  /// Optional focus node owned by the caller.
  final FocusNode? focusNode;

  @override
  State<NemoButton> createState() => _NemoButtonState();
}

class _NemoButtonState extends State<NemoButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _activate() {
    if (_enabled) widget.onPressed!();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (!_enabled ||
        (event.logicalKey != LogicalKeyboardKey.enter &&
            event.logicalKey != LogicalKeyboardKey.space)) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      _setPressed(true);
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      _setPressed(false);
      _activate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final bool enabled = _enabled;
    final NemoButtonState state = !enabled
        ? (widget.isLoading
              ? NemoButtonState.loading
              : NemoButtonState.disabled)
        : _pressed
        ? NemoButtonState.pressed
        : _focused
        ? NemoButtonState.focused
        : _hovered
        ? NemoButtonState.hovered
        : NemoButtonState.resting;
    final String? label = widget.isLoading
        ? NemoLocalizations.of(context).loading
        : widget.semanticLabel;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      liveRegion: widget.isLoading,
      onTap: enabled ? _activate : null,
      child: Focus(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: enabled,
        skipTraversal: !enabled,
        onFocusChange: (bool value) {
          if (_focused != value) setState(() => _focused = value);
        },
        onKeyEvent: _handleKey,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
          onExit: enabled ? (_) => setState(() => _hovered = false) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? _activate : null,
            onTapDown: enabled ? (_) => _setPressed(true) : null,
            onTapUp: enabled ? (_) => _setPressed(false) : null,
            onTapCancel: enabled ? () => _setPressed(false) : null,
            child: TweenAnimationBuilder<NemoButtonStateStyle>(
              tween: _NemoButtonStyleTween(
                end: theme.components.button.styleFor(state),
              ),
              duration: motion.quick,
              curve: motion.standardCurve,
              builder:
                  (
                    BuildContext context,
                    NemoButtonStateStyle style,
                    Widget? child,
                  ) {
                    return CustomPaint(
                      painter: _NemoButtonPainter(
                        theme: theme,
                        style: style,
                        focused: _focused,
                        enabled: enabled,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: theme.components.controlMinHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                theme.components.controlHorizontalPadding,
                            vertical: theme.foundation.space8,
                          ),
                          child: Center(
                            child: IconTheme(
                              data: IconThemeData(
                                color: enabled
                                    ? theme.semantic.onPrimary
                                    : theme.semantic.mutedForeground,
                              ),
                              child: DefaultTextStyle.merge(
                                style: TextStyle(
                                  color: enabled
                                      ? theme.semantic.onPrimary
                                      : theme.semantic.mutedForeground,
                                ),
                                child: widget.isLoading
                                    ? ExcludeSemantics(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            SizedBox(
                                              width: theme
                                                  .components
                                                  .button
                                                  .progressIndicatorSize,
                                              height: theme
                                                  .components
                                                  .button
                                                  .progressIndicatorSize,
                                              child:
                                                  MediaQuery.disableAnimationsOf(
                                                    context,
                                                  )
                                                  ? Icon(
                                                      Icons.hourglass_top,
                                                      size: theme
                                                          .components
                                                          .button
                                                          .progressIndicatorSize,
                                                      color: theme
                                                          .semantic
                                                          .onPrimary,
                                                    )
                                                  : CircularProgressIndicator(
                                                      strokeWidth: theme
                                                          .components
                                                          .button
                                                          .progressIndicatorStrokeWidth,
                                                      color: theme
                                                          .semantic
                                                          .onPrimary,
                                                    ),
                                            ),
                                            SizedBox(
                                              width: theme.foundation.space8,
                                            ),
                                            Text(
                                              NemoLocalizations.of(context)
                                                  .loading,
                                            ),
                                          ],
                                        ),
                                      )
                                    : widget.child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }
}

final class _NemoButtonStyleTween extends Tween<NemoButtonStateStyle> {
  _NemoButtonStyleTween({required NemoButtonStateStyle end}) : super(end: end);

  @override
  NemoButtonStateStyle lerp(double t) =>
      NemoButtonStateStyle.lerp(begin!, end!, t);
}

class _NemoButtonPainter extends CustomPainter {
  const _NemoButtonPainter({
    required this.theme,
    required this.style,
    required this.focused,
    required this.enabled,
  });

  final NemoThemeData theme;
  final NemoButtonStateStyle style;
  final bool focused;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = theme.foundation.radiusMedium;
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Color base = enabled
        ? Color.lerp(
            theme.semantic.primary,
            theme.semantic.foreground,
            style.foregroundBlend,
          )!
        : theme.semantic.surfaceVariant;
    final double shadowOffset =
        theme.foundation.shadowOffset * style.shadowOffsetMultiplier;
    final double blur =
        theme.foundation.shadowBlur * style.shadowBlurMultiplier;
    if (enabled && style.shadowOpacity > 0) {
      final Offset diagonal = Offset(shadowOffset, shadowOffset);
      for (final (Offset offset, Color color) in <(Offset, Color)>[
        (-diagonal, theme.semantic.highlightShadow),
        (diagonal, theme.semantic.lowlightShadow),
      ]) {
        canvas.drawRRect(
          shape.shift(offset),
          Paint()
            ..color = color.withValues(alpha: style.shadowOpacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
        );
      }
    }
    canvas.drawRRect(shape, Paint()..color = base);
    canvas.drawRRect(
      shape.deflate(theme.components.outlineWidth / 2),
      Paint()
        ..color = theme.semantic.outline.withValues(alpha: style.outlineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = theme.components.outlineWidth,
    );
    if (focused) {
      canvas.drawRRect(
        shape.deflate(theme.components.focusRingWidth / 2),
        Paint()
          ..color = theme.semantic.focusRing
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.components.focusRingWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NemoButtonPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.style != style ||
      oldDelegate.focused != focused ||
      oldDelegate.enabled != enabled;
}
