import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_material.dart';
import '../foundation/nemo_motion.dart';
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
  bool? _lastValue;
  bool _lastHovered = false;
  bool _lastFocused = false;
  bool _lastPressed = false;
  ({Duration duration, Curve curve})? _activeMotion;

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
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final bool enabled = _enabled;
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
                      _buildVisual(
                        theme: theme,
                        tokens: tokens,
                        motion: motion,
                        style: stateStyle,
                        enabled: enabled,
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

  Widget _buildVisual({
    required NemoThemeData theme,
    required NemoSwitchTokens tokens,
    required NemoMotionTokens motion,
    required NemoSwitchStateStyle style,
    required bool enabled,
  }) {
    final NemoInteractionState trackState = !enabled
        ? NemoInteractionState.disabled
        : _pressed
        ? NemoInteractionState.pressed
        : widget.value
        ? NemoInteractionState.selected
        : _focused
        ? NemoInteractionState.focused
        : _hovered
        ? NemoInteractionState.hovered
        : NemoInteractionState.resting;
    final NemoInteractionRecipe trackRecipe = theme.interactions.recipeFor(
      trackState,
    );
    final NemoInteractionRecipe thumbRecipe = theme.interactions.recipeFor(
      _pressed ? NemoInteractionState.pressed : NemoInteractionState.resting,
    );
    final _NemoSwitchVisual target = _NemoSwitchVisual(
      style: style,
      trackRecipe: trackRecipe,
      thumbRecipe: thumbRecipe,
      trackMaterial: theme.materials.recipeFor(trackRecipe.material),
      thumbMaterial: theme.materials.recipeFor(thumbRecipe.material),
      thumbT: widget.value ? 1 : 0,
      indicatorT: widget.value ? 1 : 0,
      indicatorColor: widget.value
          ? theme.semantic.onPrimary
          : theme.semantic.primary,
    );
    final ({Duration duration, Curve curve}) spec = _lockMotion(motion);
    Widget paint(_NemoSwitchVisual visual) {
      final double interactionBlend = _pressed
          ? .12
          : _hovered || _focused
          ? .06
          : 0;
      final Color liveTrack = Color.lerp(
        Color.lerp(
          theme.semantic.surfaceVariant,
          theme.semantic.primary,
          visual.style.trackPrimaryBlend,
        )!,
        theme.semantic.foreground,
        interactionBlend,
      )!;
      final Color liveThumb = Color.lerp(
        Color.lerp(
          theme.semantic.surface,
          theme.semantic.primary,
          visual.style.thumbPrimaryBlend,
        )!,
        theme.semantic.foreground,
        interactionBlend / 2,
      )!;
      return CustomPaint(
        key: const ValueKey<String>('nemo-switch-track'),
        painter: _NemoSwitchTrackPainter(
          theme: theme,
          style: visual.style,
          recipe: visual.trackRecipe,
          material: visual.trackMaterial,
          color: liveTrack,
          focused: _focused,
          enabled: enabled,
        ),
        child: SizedBox(
          width: tokens.trackWidth,
          height: tokens.trackHeight,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Align(
              alignment: AlignmentDirectional.lerp(
                AlignmentDirectional.centerStart,
                AlignmentDirectional.centerEnd,
                visual.thumbT,
              )!,
              child: CustomPaint(
                painter: _NemoSwitchThumbPainter(
                  theme: theme,
                  style: visual.style,
                  recipe: visual.thumbRecipe,
                  material: visual.thumbMaterial,
                  color: liveThumb,
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
                    painter: _NemoSwitchIndicatorPainter(
                      progress: visual.indicatorT,
                      color: visual.indicatorColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (motion.instant == Duration.zero &&
        motion.quick == Duration.zero &&
        motion.standard == Duration.zero) {
      return paint(target);
    }
    return TweenAnimationBuilder<_NemoSwitchVisual>(
      tween: _NemoSwitchVisualTween(end: target),
      duration: spec.duration,
      curve: spec.curve,
      builder: (
        BuildContext context,
        _NemoSwitchVisual visual,
        Widget? child,
      ) => paint(visual),
    );
  }

  ({Duration duration, Curve curve}) _lockMotion(NemoMotionTokens motion) {
    final bool stateChanged =
        _lastValue != widget.value ||
        _lastHovered != _hovered ||
        _lastFocused != _focused ||
        _lastPressed != _pressed;
    if (stateChanged || _activeMotion == null) {
      _activeMotion = _motionFor(motion);
      _lastValue = widget.value;
      _lastHovered = _hovered;
      _lastFocused = _focused;
      _lastPressed = _pressed;
    }
    return _activeMotion!;
  }

  ({Duration duration, Curve curve}) _motionFor(NemoMotionTokens motion) {
    if (_lastValue != null && _lastValue != widget.value) {
      return (duration: motion.standard, curve: motion.decelerateCurve);
    }
    if (_pressed && !_lastPressed) {
      return (duration: motion.quick, curve: motion.accelerateCurve);
    }
    if (!_pressed && _lastPressed) {
      return (duration: motion.quick, curve: motion.decelerateCurve);
    }
    if (_hovered != _lastHovered) {
      return (duration: motion.quick, curve: motion.decelerateCurve);
    }
    if (_focused != _lastFocused) {
      return (duration: motion.instant, curve: motion.decelerateCurve);
    }
    if (_lastValue == null) {
      return (duration: Duration.zero, curve: motion.standardCurve);
    }
    return (duration: motion.standard, curve: motion.standardCurve);
  }
}

@immutable
final class _NemoSwitchVisual {
  const _NemoSwitchVisual({
    required this.style,
    required this.trackRecipe,
    required this.thumbRecipe,
    required this.trackMaterial,
    required this.thumbMaterial,
    required this.thumbT,
    required this.indicatorT,
    required this.indicatorColor,
  });

  final NemoSwitchStateStyle style;
  final NemoInteractionRecipe trackRecipe;
  final NemoInteractionRecipe thumbRecipe;
  final NemoMaterialRecipe trackMaterial;
  final NemoMaterialRecipe thumbMaterial;
  final double thumbT;
  final double indicatorT;
  final Color indicatorColor;

  static _NemoSwitchVisual lerp(
    _NemoSwitchVisual a,
    _NemoSwitchVisual b,
    double t,
  ) => _NemoSwitchVisual(
    style: NemoSwitchStateStyle.lerp(a.style, b.style, t),
    trackRecipe: NemoInteractionRecipe.lerp(a.trackRecipe, b.trackRecipe, t),
    thumbRecipe: NemoInteractionRecipe.lerp(a.thumbRecipe, b.thumbRecipe, t),
    trackMaterial: NemoMaterialRecipe.lerp(a.trackMaterial, b.trackMaterial, t),
    thumbMaterial: NemoMaterialRecipe.lerp(a.thumbMaterial, b.thumbMaterial, t),
    thumbT: a.thumbT + (b.thumbT - a.thumbT) * t,
    indicatorT: a.indicatorT + (b.indicatorT - a.indicatorT) * t,
    indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is _NemoSwitchVisual &&
      style == other.style &&
      trackRecipe == other.trackRecipe &&
      thumbRecipe == other.thumbRecipe &&
      trackMaterial == other.trackMaterial &&
      thumbMaterial == other.thumbMaterial &&
      thumbT == other.thumbT &&
      indicatorT == other.indicatorT &&
      indicatorColor == other.indicatorColor;

  @override
  int get hashCode => Object.hash(
    style,
    trackRecipe,
    thumbRecipe,
    trackMaterial,
    thumbMaterial,
    thumbT,
    indicatorT,
    indicatorColor,
  );
}

final class _NemoSwitchVisualTween extends Tween<_NemoSwitchVisual> {
  _NemoSwitchVisualTween({required _NemoSwitchVisual end}) : super(end: end);

  @override
  _NemoSwitchVisual lerp(double t) => _NemoSwitchVisual.lerp(begin!, end!, t);
}

class _NemoSwitchTrackPainter extends CustomPainter {
  const _NemoSwitchTrackPainter({
    required this.theme,
    required this.style,
    required this.recipe,
    required this.material,
    required this.color,
    required this.focused,
    required this.enabled,
  });
  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final NemoInteractionRecipe recipe;
  final NemoMaterialRecipe material;
  final Color color;
  final bool focused;
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) => NemoIllumination.paint(
    canvas,
    size,
    theme: theme,
    recipe: material,
    baseColor: color,
    radius: size.height / 2,
    focused: focused,
  );
  @override
  bool shouldRepaint(covariant _NemoSwitchTrackPainter old) =>
      theme != old.theme ||
      style != old.style ||
      recipe != old.recipe ||
      material != old.material ||
      color != old.color ||
      focused != old.focused ||
      enabled != old.enabled;
}

class _NemoSwitchThumbPainter extends CustomPainter {
  const _NemoSwitchThumbPainter({
    required this.theme,
    required this.style,
    required this.recipe,
    required this.material,
    required this.color,
    required this.enabled,
  });
  final NemoThemeData theme;
  final NemoSwitchStateStyle style;
  final NemoInteractionRecipe recipe;
  final NemoMaterialRecipe material;
  final Color color;
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) => NemoIllumination.paint(
    canvas,
    size,
    theme: theme,
    recipe: material,
    baseColor: color,
    radius: size.shortestSide / 2,
  );
  @override
  bool shouldRepaint(covariant _NemoSwitchThumbPainter old) =>
      theme != old.theme ||
      style != old.style ||
      recipe != old.recipe ||
      material != old.material ||
      color != old.color ||
      enabled != old.enabled;
}

class _NemoSwitchIndicatorPainter extends CustomPainter {
  const _NemoSwitchIndicatorPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;
    if (progress <= 0) {
      canvas.drawLine(center.translate(-4, 0), center.translate(4, 0), paint);
      return;
    }
    if (progress >= 1) {
      canvas.drawPath(
        Path()
          ..moveTo(center.dx - 5, center.dy)
          ..lineTo(center.dx - 1, center.dy + 4)
          ..lineTo(center.dx + 5, center.dy - 4),
        paint,
      );
      return;
    }
    paint.color = color.withValues(alpha: color.a * (1 - progress));
    canvas.drawLine(center.translate(-4, 0), center.translate(4, 0), paint);
    paint.color = color.withValues(alpha: color.a * progress);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 5, center.dy)
        ..lineTo(center.dx - 1, center.dy + 4)
        ..lineTo(center.dx + 5, center.dy - 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NemoSwitchIndicatorPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
