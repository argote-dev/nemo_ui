import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_localizations.dart';
import '../foundation/nemo_material.dart';
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
  NemoButtonState? _lastVisualState;
  ({Duration duration, Curve curve})? _activeMotion;

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
    final Color contentColor = widget.isLoading || enabled
        ? theme.semantic.primary
        : theme.semantic.mutedForeground;

    return MergeSemantics(
      child: Semantics(
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
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
            onExit: enabled ? (_) => setState(() => _hovered = false) : null,
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _activate : null,
              onTapDown: enabled ? (_) => _setPressed(true) : null,
              onTapUp: enabled ? (_) => _setPressed(false) : null,
              onTapCancel: enabled ? () => _setPressed(false) : null,
              child: _buildVisual(
                theme: theme,
                motion: motion,
                state: state,
                enabled: enabled,
                contentColor: contentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisual({
    required NemoThemeData theme,
    required NemoMotionTokens motion,
    required NemoButtonState state,
    required bool enabled,
    required Color contentColor,
  }) {
    final NemoInteractionRecipe recipe = theme.interactions.recipeFor(
      switch (state) {
        NemoButtonState.resting => NemoInteractionState.resting,
        NemoButtonState.hovered => NemoInteractionState.hovered,
        NemoButtonState.pressed => NemoInteractionState.pressed,
        NemoButtonState.focused => NemoInteractionState.focused,
        NemoButtonState.disabled => NemoInteractionState.disabled,
        NemoButtonState.loading => NemoInteractionState.loading,
      },
    );
    final NemoButtonStateStyle style = theme.components.button.styleFor(state);
    Color fill = enabled
        ? Color.lerp(
            theme.semantic.surface,
            theme.semantic.surfaceVariant,
            style.surfaceVariantBlend,
          )!
        : theme.semantic.surfaceVariant;
    if (enabled) {
      fill = Color.lerp(
        fill,
        theme.semantic.primary,
        style.accentOpacity + recipe.toneBlend,
      )!;
    }
    final _NemoButtonVisual target = _NemoButtonVisual(
      style: style,
      recipe: recipe,
      material: theme.materials.recipeFor(recipe.material),
      fill: fill,
      contentColor: contentColor,
    );
    final ({Duration duration, Curve curve}) spec = _lockMotion(state, motion);
    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.components.controlMinHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.components.controlHorizontalPadding,
          vertical: theme.foundation.space8,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(color: contentColor),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: contentColor),
              child: widget.isLoading
                  ? ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width:
                                theme.components.button.progressIndicatorSize,
                            height:
                                theme.components.button.progressIndicatorSize,
                            child: MediaQuery.disableAnimationsOf(context)
                                ? Icon(
                                    Icons.hourglass_top,
                                    size: theme
                                        .components
                                        .button
                                        .progressIndicatorSize,
                                    color: contentColor,
                                  )
                                : CircularProgressIndicator(
                                    strokeWidth: theme
                                        .components
                                        .button
                                        .progressIndicatorStrokeWidth,
                                    color: contentColor,
                                  ),
                          ),
                          SizedBox(width: theme.foundation.space8),
                          Text(NemoLocalizations.of(context).loading),
                        ],
                      ),
                    )
                  : widget.semanticLabel == null
                  ? widget.child
                  : ExcludeSemantics(child: widget.child),
            ),
          ),
        ),
      ),
    );
    Widget paint(_NemoButtonVisual visual) => CustomPaint(
      painter: _NemoButtonPainter(
        theme: theme,
        visual: visual,
        focused: _focused,
      ),
      child: Transform.translate(
        offset: Offset(0, visual.recipe.contentOffset),
        child: content,
      ),
    );
    if (motion.instant == Duration.zero &&
        motion.quick == Duration.zero &&
        motion.standard == Duration.zero) {
      return paint(target);
    }
    return TweenAnimationBuilder<_NemoButtonVisual>(
      tween: _NemoButtonVisualTween(end: target),
      duration: spec.duration,
      curve: spec.curve,
      builder: (
        BuildContext context,
        _NemoButtonVisual visual,
        Widget? child,
      ) => paint(visual),
    );
  }

  ({Duration duration, Curve curve}) _lockMotion(
    NemoButtonState state,
    NemoMotionTokens motion,
  ) {
    if (_lastVisualState != state || _activeMotion == null) {
      _activeMotion = _motionFor(
        previous: _lastVisualState,
        next: state,
        motion: motion,
      );
      _lastVisualState = state;
    }
    return _activeMotion!;
  }

  ({Duration duration, Curve curve}) _motionFor({
    required NemoButtonState? previous,
    required NemoButtonState next,
    required NemoMotionTokens motion,
  }) {
    if (previous == null) {
      return (duration: Duration.zero, curve: motion.standardCurve);
    }
    if (next == NemoButtonState.pressed) {
      return (duration: motion.quick, curve: motion.accelerateCurve);
    }
    if (previous == NemoButtonState.pressed) {
      return (duration: motion.quick, curve: motion.decelerateCurve);
    }
    if (next == NemoButtonState.hovered ||
        previous == NemoButtonState.hovered) {
      return (duration: motion.quick, curve: motion.decelerateCurve);
    }
    if (next == NemoButtonState.focused ||
        previous == NemoButtonState.focused) {
      return (duration: motion.instant, curve: motion.decelerateCurve);
    }
    return (duration: motion.standard, curve: motion.standardCurve);
  }
}

@immutable
final class _NemoButtonVisual {
  const _NemoButtonVisual({
    required this.style,
    required this.recipe,
    required this.material,
    required this.fill,
    required this.contentColor,
  });

  final NemoButtonStateStyle style;
  final NemoInteractionRecipe recipe;
  final NemoMaterialRecipe material;
  final Color fill;
  final Color contentColor;

  static _NemoButtonVisual lerp(
    _NemoButtonVisual a,
    _NemoButtonVisual b,
    double t,
  ) => _NemoButtonVisual(
    style: NemoButtonStateStyle.lerp(a.style, b.style, t),
    recipe: NemoInteractionRecipe.lerp(a.recipe, b.recipe, t),
    material: NemoMaterialRecipe.lerp(a.material, b.material, t),
    fill: Color.lerp(a.fill, b.fill, t)!,
    contentColor: Color.lerp(a.contentColor, b.contentColor, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is _NemoButtonVisual &&
      style == other.style &&
      recipe == other.recipe &&
      material == other.material &&
      fill == other.fill &&
      contentColor == other.contentColor;

  @override
  int get hashCode => Object.hash(style, recipe, material, fill, contentColor);
}

final class _NemoButtonVisualTween extends Tween<_NemoButtonVisual> {
  _NemoButtonVisualTween({required _NemoButtonVisual end}) : super(end: end);

  @override
  _NemoButtonVisual lerp(double t) => _NemoButtonVisual.lerp(begin!, end!, t);
}

class _NemoButtonPainter extends CustomPainter {
  const _NemoButtonPainter({
    required this.theme,
    required this.visual,
    required this.focused,
  });
  final NemoThemeData theme;
  final _NemoButtonVisual visual;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    NemoIllumination.paint(
      canvas,
      size,
      theme: theme,
      recipe: visual.material,
      baseColor: visual.fill,
      radius: theme.foundation.radiusMedium,
      focused: focused,
      outlineOpacity: visual.recipe.outlineOpacity,
    );
  }

  @override
  bool shouldRepaint(covariant _NemoButtonPainter old) =>
      old.theme != theme || old.visual != visual || old.focused != focused;
}
