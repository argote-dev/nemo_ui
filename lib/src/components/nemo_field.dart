import 'dart:math' as math;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/material.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_material.dart';
import '../foundation/nemo_motion.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';

/// An accessible, recessed text-entry control for the Nemo design system.
///
/// [label] remains visible while editing. The widget deliberately preserves the
/// standard Flutter [TextField] editing contract, while Nemo owns its surface,
/// state treatment, and supporting content presentation.
class NemoField extends StatefulWidget {
  /// Creates a Nemo text field.
  const NemoField({
    required this.label,
    this.hintText,
    this.supportingText,
    this.errorText,
    this.semanticLabel,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  /// Persistent visible description of the field.
  final String label;

  /// Optional guidance displayed when the field is empty.
  final String? hintText;

  /// Optional supporting content displayed below the editing area.
  final String? supportingText;

  /// Optional validation message displayed below the editing area.
  final String? errorText;

  /// Optional accessible name that replaces the visible [label].
  final String? semanticLabel;

  /// Caller-owned editing controller, when supplied.
  final TextEditingController? controller;

  /// Caller-owned focus node, when supplied.
  final FocusNode? focusNode;

  /// Whether this field requests focus when first built.
  final bool autofocus;

  /// Whether editing and focus are available.
  final bool enabled;

  /// Whether the value is selectable but cannot be edited.
  final bool readOnly;

  /// Keyboard configuration forwarded to the native [TextField].
  final TextInputType? keyboardType;

  /// IME action forwarded to the native [TextField].
  final TextInputAction? textInputAction;

  /// Whether entered text is obscured.
  final bool obscureText;

  /// Called whenever the native field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the native field submits its value.
  final ValueChanged<String>? onSubmitted;

  @override
  State<NemoField> createState() => _NemoFieldState();
}

class _NemoFieldState extends State<NemoField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _installController(widget.controller);
    _installFocusNode(widget.focusNode);
  }

  void _installController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
  }

  void _installFocusNode(FocusNode? focusNode) {
    _ownsFocusNode = focusNode == null;
    _focusNode = focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _focused = _focusNode.hasFocus;
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void didUpdateWidget(covariant NemoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _installController(widget.controller);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _installFocusNode(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;
    final Color baseColor = !widget.enabled
        ? theme.semantic.surfaceVariant
        : theme.semantic.surface;
    final _NemoFieldVisual target = _NemoFieldVisual(
      baseColor: baseColor,
      stateColor: hasError
          ? theme.semantic.error
          : _focused && widget.enabled
          ? theme.semantic.focusRing
          : Colors.transparent,
      stateOutlineWidth: hasError || (_focused && widget.enabled)
          ? theme.components.focusRingWidth
          : 0,
    );
    final String semanticHint = <String?>[
      widget.hintText,
      if (hasError) widget.errorText,
    ].whereType<String>().where((String text) => text.isNotEmpty).join('\n');
    final Widget editingArea = ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.components.controlMinHeight),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: theme.components.controlHorizontalPadding,
          vertical: theme.foundation.space8,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                style: TextStyle(color: theme.semantic.foreground),
                cursorColor: theme.semantic.primary,
                decoration: InputDecoration.collapsed(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: theme.semantic.mutedForeground),
                ),
              ),
            ),
            if (hasError || !widget.enabled || widget.readOnly) ...<Widget>[
              SizedBox(width: theme.foundation.space8),
              ExcludeSemantics(
                child: _NemoFieldStateIndicator(
                  state: hasError
                      ? _NemoFieldIndicatorState.error
                      : !widget.enabled
                      ? _NemoFieldIndicatorState.disabled
                      : _NemoFieldIndicatorState.readOnly,
                  color: hasError
                      ? theme.semantic.error
                      : theme.semantic.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    Widget buildPaintedEditingArea(_NemoFieldVisual visual, Widget child) =>
        CustomPaint(
          key: const ValueKey<String>('nemo-field-surface'),
          painter: _NemoFieldPainter(theme: theme, visual: visual),
          child: child,
        );
    final Widget animatedEditingArea = motion.quick == Duration.zero
        ? buildPaintedEditingArea(target, editingArea)
        : TweenAnimationBuilder<_NemoFieldVisual>(
            tween: _NemoFieldVisualTween(end: target),
            duration: motion.quick,
            curve: motion.standardCurve,
            child: editingArea,
            builder: (
              BuildContext context,
              _NemoFieldVisual visual,
              Widget? child,
            ) => buildPaintedEditingArea(visual, child!),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.enabled
                  ? theme.semantic.foreground
                  : theme.semantic.mutedForeground,
            ),
          ),
        ),
        SizedBox(height: theme.foundation.space8),
        Semantics(
          label: widget.semanticLabel ?? widget.label,
          hint: semanticHint.isEmpty ? null : semanticHint,
          validationResult: hasError
              ? SemanticsValidationResult.invalid
              : SemanticsValidationResult.none,
          child: animatedEditingArea,
        ),
        if (widget.supportingText != null &&
            widget.supportingText!.isNotEmpty) ...<Widget>[
          SizedBox(height: theme.foundation.space8),
          Text(
            widget.supportingText!,
            style: TextStyle(color: theme.semantic.mutedForeground),
          ),
        ],
        if (hasError) ...<Widget>[
          SizedBox(height: theme.foundation.space8),
          Semantics(
            liveRegion: true,
            child: Text(
              widget.errorText!,
              style: TextStyle(color: theme.semantic.error),
            ),
          ),
        ],
      ],
    );
  }
}

enum _NemoFieldIndicatorState { error, disabled, readOnly }

class _NemoFieldStateIndicator extends StatelessWidget {
  const _NemoFieldStateIndicator({required this.state, required this.color});

  final _NemoFieldIndicatorState state;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 24,
    child: CustomPaint(painter: _NemoFieldStateIndicatorPainter(state, color)),
  );
}

final class _NemoFieldStateIndicatorPainter extends CustomPainter {
  const _NemoFieldStateIndicatorPainter(this.state, this.color);

  final _NemoFieldIndicatorState state;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    switch (state) {
      case _NemoFieldIndicatorState.error:
        canvas.drawCircle(center, 9, paint);
        canvas.drawLine(center.translate(0, -5), center.translate(0, 2), paint);
        canvas.drawCircle(
          center.translate(0, 5.5),
          1,
          paint..style = PaintingStyle.fill,
        );
      case _NemoFieldIndicatorState.disabled:
        canvas.drawCircle(center, 9, paint);
        final double diagonalOffset = 9 / math.sqrt2;
        canvas.drawLine(
          center.translate(-diagonalOffset, -diagonalOffset),
          center.translate(diagonalOffset, diagonalOffset),
          paint,
        );
      case _NemoFieldIndicatorState.readOnly:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(center.dx - 8, center.dy - 1, 16, 11),
            const Radius.circular(2),
          ),
          paint,
        );
        final Rect shackle = Rect.fromCenter(
          center: center.translate(0, -2),
          width: 10,
          height: 12,
        );
        canvas.drawArc(shackle, math.pi, math.pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NemoFieldStateIndicatorPainter oldDelegate) =>
      state != oldDelegate.state || color != oldDelegate.color;
}

@immutable
final class _NemoFieldVisual {
  const _NemoFieldVisual({
    required this.baseColor,
    required this.stateColor,
    required this.stateOutlineWidth,
  });

  final Color baseColor;
  final Color stateColor;
  final double stateOutlineWidth;
}

final class _NemoFieldVisualTween extends Tween<_NemoFieldVisual> {
  _NemoFieldVisualTween({required _NemoFieldVisual end}) : super(end: end);

  @override
  _NemoFieldVisual lerp(double t) => _NemoFieldVisual(
    baseColor: Color.lerp(begin!.baseColor, end!.baseColor, t)!,
    stateColor: Color.lerp(begin!.stateColor, end!.stateColor, t)!,
    stateOutlineWidth:
        begin!.stateOutlineWidth +
        (end!.stateOutlineWidth - begin!.stateOutlineWidth) * t,
  );
}

final class _NemoFieldPainter extends CustomPainter {
  const _NemoFieldPainter({required this.theme, required this.visual});

  final NemoThemeData theme;
  final _NemoFieldVisual visual;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = theme.foundation.radiusSmall;
    NemoIllumination.paint(
      canvas,
      size,
      theme: theme,
      recipe: theme.materials.recipeFor(NemoMaterial.recessed),
      baseColor: visual.baseColor,
      radius: radius,
    );
    if (visual.stateOutlineWidth > 0 && visual.stateColor.a > 0) {
      final shape = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ).deflate(visual.stateOutlineWidth / 2);
      canvas.drawRRect(
        shape,
        Paint()
          ..color = visual.stateColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = visual.stateOutlineWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NemoFieldPainter oldDelegate) =>
      theme != oldDelegate.theme ||
      visual.baseColor != oldDelegate.visual.baseColor ||
      visual.stateColor != oldDelegate.visual.stateColor ||
      visual.stateOutlineWidth != oldDelegate.visual.stateOutlineWidth;
}
