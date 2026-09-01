import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// A controlled binary selection with tactile feedback and switch semantics.
///
/// The caller owns [value], [onChanged], and visible [child] content. Nemo owns
/// the localized on/off state announcement, interaction feedback, and minimum
/// touch target.
class NemoSwitch extends StatefulWidget {
  /// Creates a controlled binary selection.
  const NemoSwitch({
    required this.value,
    required this.child,
    this.onChanged,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// Whether the selection is on.
  final bool value;

  /// Called with the requested value after an enabled interaction.
  final ValueChanged<bool>? onChanged;

  /// Visible caller-owned content describing the selection.
  final Widget child;

  /// Optional caller-owned accessible name.
  final String? semanticLabel;

  /// Whether this control receives focus when first built.
  final bool autofocus;

  /// Optional focus node owned by the caller.
  final FocusNode? focusNode;

  @override
  State<NemoSwitch> createState() => _NemoSwitchState();
}

class _NemoSwitchState extends State<NemoSwitch> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    if (_enabled) widget.onChanged!(!widget.value);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (!_enabled ||
        (event.logicalKey != LogicalKeyboardKey.enter &&
            event.logicalKey != LogicalKeyboardKey.space)) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      setState(() => _pressed = true);
    }
    if (event is KeyUpEvent) {
      setState(() => _pressed = false);
      _toggle();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoSwitchTokens tokens = theme.components.switchControl;
    final bool enabled = _enabled;
    final Duration duration = theme.motion.resolveFor(context).quick;
    final NemoSwitchStateStyle stateStyle = widget.value
        ? tokens.on
        : tokens.off;
    final String stateLabel = widget.value
        ? NemoLocalizations.of(context).on
        : NemoLocalizations.of(context).off;

    return MergeSemantics(
      child: Semantics(
        toggled: widget.value,
        enabled: enabled,
        label: widget.semanticLabel,
        value: stateLabel,
        onTap: enabled ? _toggle : null,
        child: Focus(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: enabled,
          skipTraversal: !enabled,
          onFocusChange: (value) => setState(() => _focused = value),
          onKeyEvent: _onKey,
          child: MouseRegion(
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
            onExit: enabled ? (_) => setState(() => _hovered = false) : null,
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _toggle : null,
              onTapDown: enabled
                  ? (_) => setState(() => _pressed = true)
                  : null,
              onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
              onTapCancel: enabled
                  ? () => setState(() => _pressed = false)
                  : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: theme.components.controlMinHeight,
                ),
                child: Opacity(
                  opacity: enabled ? 1 : tokens.disabledOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: widget.semanticLabel == null
                            ? widget.child
                            : ExcludeSemantics(child: widget.child),
                      ),
                      SizedBox(width: theme.foundation.space12),
                      TweenAnimationBuilder<NemoSwitchStateStyle>(
                        tween: _NemoSwitchStyleTween(end: stateStyle),
                        duration: duration,
                        curve: theme.motion.standardCurve,
                        builder:
                            (
                              BuildContext context,
                              NemoSwitchStateStyle style,
                              Widget? child,
                            ) {
                              final double interactionBlend = _pressed
                                  ? .12
                                  : _hovered || _focused
                                  ? .06
                                  : 0;
                              final Color track = Color.lerp(
                                Color.lerp(
                                  theme.semantic.surfaceVariant,
                                  theme.semantic.primary,
                                  style.trackPrimaryBlend,
                                )!,
                                theme.semantic.foreground,
                                interactionBlend,
                              )!;
                              final Color thumb = Color.lerp(
                                Color.lerp(
                                  theme.semantic.surface,
                                  theme.semantic.primary,
                                  style.thumbPrimaryBlend,
                                )!,
                                theme.semantic.foreground,
                                interactionBlend / 2,
                              )!;
                              return CustomPaint(
                                key: const ValueKey<String>(
                                  'nemo-switch-track',
                                ),
                                painter: _NemoSwitchTrackPainter(
                                  theme: theme,
                                  style: style,
                                  color: track,
                                  focused: _focused,
                                  enabled: enabled,
                                ),
                                child: SizedBox(
                                  width: tokens.trackWidth,
                                  height: tokens.trackHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AnimatedAlign(
                                      duration: duration,
                                      curve: theme.motion.standardCurve,
                                      alignment: widget.value
                                          ? AlignmentDirectional.centerEnd
                                          : AlignmentDirectional.centerStart,
                                      child: CustomPaint(
                                        painter: _NemoSwitchThumbPainter(
                                          theme: theme,
                                          style: style,
                                          color: thumb,
                                          enabled: enabled,
                                        ),
                                        child: SizedBox(
                                          width: tokens.thumbDiameter,
                                          height: tokens.thumbDiameter,
                                          child: CustomPaint(
                                            key: ValueKey<String>(
                                              widget.value
                                                  ? 'nemo-switch-indicator-on'
                                                  : 'nemo-switch-indicator-off',
                                            ),
                                            painter:
                                                _NemoSwitchIndicatorPainter(
                                                  checked: widget.value,
                                                  color: widget.value
                                                      ? theme.semantic.onPrimary
                                                      : theme.semantic.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NemoSwitchStyleTween extends Tween<NemoSwitchStateStyle> {
  _NemoSwitchStyleTween({required NemoSwitchStateStyle end}) : super(end: end);

  @override
  NemoSwitchStateStyle lerp(double t) =>
      NemoSwitchStateStyle.lerp(begin!, end!, t);
}

class _NemoSwitchTrackPainter extends CustomPainter {
  const _NemoSwitchTrackPainter({
    required this.theme,
    required this.style,
    required this.color,
    required this.focused,
    required this.enabled,
  });

  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final Color color;
  final bool focused;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(shape, Paint()..color = color);
    if (enabled && style.trackShadowOpacity > 0) {
      final Offset diagonal = Offset(
        theme.foundation.shadowOffset * style.trackShadowOffsetMultiplier,
        theme.foundation.shadowOffset * style.trackShadowOffsetMultiplier,
      );
      final double blur =
          theme.foundation.shadowBlur * style.trackShadowBlurMultiplier;
      canvas.save();
      canvas.clipRRect(shape);
      for (final (Offset offset, Color shadow) in <(Offset, Color)>[
        (-diagonal, theme.semantic.lowlightShadow),
        (diagonal, theme.semantic.highlightShadow),
      ]) {
        canvas.drawRRect(
          shape.shift(offset),
          Paint()
            ..color = shadow.withValues(alpha: style.trackShadowOpacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
        );
      }
      canvas.restore();
    }
    final bool hasFocus = focused;
    final double outlineWidth = hasFocus
        ? theme.components.focusRingWidth
        : theme.components.outlineWidth;
    canvas.drawRRect(
      shape.deflate(outlineWidth / 2),
      Paint()
        ..color = hasFocus
            ? theme.semantic.focusRing
            : theme.semantic.outline.withValues(
                alpha: theme.components.switchControl.trackOutlineOpacity,
              )
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _NemoSwitchTrackPainter oldDelegate) =>
      theme != oldDelegate.theme ||
      style != oldDelegate.style ||
      color != oldDelegate.color ||
      focused != oldDelegate.focused ||
      enabled != oldDelegate.enabled;
}

class _NemoSwitchThumbPainter extends CustomPainter {
  const _NemoSwitchThumbPainter({
    required this.theme,
    required this.style,
    required this.color,
    required this.enabled,
  });

  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final Color color;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide / 2),
    );
    if (enabled && style.thumbShadowOpacity > 0) {
      final Offset diagonal = Offset(
        theme.foundation.shadowOffset * style.thumbShadowOffsetMultiplier,
        theme.foundation.shadowOffset * style.thumbShadowOffsetMultiplier,
      );
      final double blur =
          theme.foundation.shadowBlur * style.thumbShadowBlurMultiplier;
      for (final (Offset offset, Color shadow) in <(Offset, Color)>[
        (-diagonal, theme.semantic.highlightShadow),
        (diagonal, theme.semantic.lowlightShadow),
      ]) {
        canvas.drawRRect(
          shape.shift(offset),
          Paint()
            ..color = shadow.withValues(alpha: style.thumbShadowOpacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
        );
      }
    }
    canvas.drawRRect(shape, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NemoSwitchThumbPainter oldDelegate) =>
      theme != oldDelegate.theme ||
      style != oldDelegate.style ||
      color != oldDelegate.color ||
      enabled != oldDelegate.enabled;
}

class _NemoSwitchIndicatorPainter extends CustomPainter {
  const _NemoSwitchIndicatorPainter({
    required this.checked,
    required this.color,
  });

  final bool checked;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;
    final Offset center = size.center(Offset.zero);
    if (!checked) {
      canvas.drawLine(center.translate(-4, 0), center.translate(4, 0), paint);
      return;
    }
    final Path check = Path()
      ..moveTo(center.dx - 5, center.dy)
      ..lineTo(center.dx - 1, center.dy + 4)
      ..lineTo(center.dx + 5, center.dy - 4);
    canvas.drawPath(check, paint);
  }

  @override
  bool shouldRepaint(covariant _NemoSwitchIndicatorPainter oldDelegate) =>
      checked != oldDelegate.checked || color != oldDelegate.color;
}
