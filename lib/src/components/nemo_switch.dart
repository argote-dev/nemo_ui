import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_material.dart';
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
                                  recipe: theme.interactions.recipeFor(
                                    !_enabled
                                        ? NemoInteractionState.disabled
                                        : _pressed
                                        ? NemoInteractionState.pressed
                                        : widget.value
                                        ? NemoInteractionState.selected
                                        : _focused
                                        ? NemoInteractionState.focused
                                        : _hovered
                                        ? NemoInteractionState.hovered
                                        : NemoInteractionState.resting,
                                  ),
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
                                          recipe: theme.interactions.recipeFor(
                                            _pressed
                                                ? NemoInteractionState.pressed
                                                : NemoInteractionState.resting,
                                          ),
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
    required this.recipe,
    required this.color,
    required this.focused,
    required this.enabled,
  });
  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final NemoInteractionRecipe recipe;
  final Color color;
  final bool focused;
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) => NemoIllumination.paint(
    canvas,
    size,
    theme: theme,
    recipe: theme.materials.recipeFor(recipe.material),
    baseColor: color,
    radius: size.height / 2,
    focused: focused,
  );
  @override
  bool shouldRepaint(covariant _NemoSwitchTrackPainter old) =>
      theme != old.theme ||
      style != old.style ||
      recipe != old.recipe ||
      color != old.color ||
      focused != old.focused ||
      enabled != old.enabled;
}

class _NemoSwitchThumbPainter extends CustomPainter {
  const _NemoSwitchThumbPainter({
    required this.theme,
    required this.style,
    required this.recipe,
    required this.color,
    required this.enabled,
  });
  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final NemoInteractionRecipe recipe;
  final Color color;
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) => NemoIllumination.paint(
    canvas,
    size,
    theme: theme,
    recipe: theme.materials.recipeFor(recipe.material),
    baseColor: color,
    radius: size.shortestSide / 2,
  );
  @override
  bool shouldRepaint(covariant _NemoSwitchThumbPainter old) =>
      theme != old.theme ||
      style != old.style ||
      recipe != old.recipe ||
      color != old.color ||
      enabled != old.enabled;
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
