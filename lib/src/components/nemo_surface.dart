import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_material.dart';
import '../foundation/nemo_motion.dart';
import '../foundation/nemo_surface_contract.dart';
import '../foundation/nemo_theme.dart';
import '../foundation/nemo_theme_data.dart';
import 'nemo_surface_renderer.dart';

export '../foundation/nemo_material.dart';
export '../foundation/nemo_surface_contract.dart'
    show
        NemoSurfaceDepth,
        NemoSurfaceTone,
        NemoSurfaceShape,
        NemoSurfaceFinish,
        NemoSurfaceTransition;

/// A non-interactive, token-driven Nemo material composition primitive.
///
/// Theme Contract v2 uses exactly four [material] values. [depth] is a
/// deprecated v1 migration mapping; new code must use [material].
class NemoSurface extends StatefulWidget {
  /// Creates a Nemo surface.
  const NemoSurface({
    required this.child,
    this.material,
    @Deprecated('Use material: NemoMaterial instead.') this.depth,
    this.tone = NemoSurfaceTone.surface,
    this.cornerRole = NemoCornerRole.panel,
    @Deprecated('Use cornerRole instead.') this.shape,
    this.padding,
    this.clipBehavior = Clip.none,
    this.finish = NemoSurfaceFinish.standard,
    this.enableProgressiveRendering = false,
    this.transition = NemoSurfaceTransition.none,
    super.key,
  }) : assert(
         finish != NemoSurfaceFinish.tactileGlass ||
             material == NemoMaterial.floating ||
             (material == null && depth == NemoSurfaceDepth.elevated),
         'NemoSurfaceFinish.tactileGlass is only valid for a resolved '
         'NemoMaterial.floating surface.',
       );

  /// Content displayed within the material.
  final Widget child;

  /// The semantic v2 material. `floating` is for transient/prominent planes.
  final NemoMaterial? material;

  /// Deprecated v1 depth migration input; null uses [material] or raised.
  final NemoSurfaceDepth? depth;

  /// Semantic base tone for this material.
  final NemoSurfaceTone tone;

  /// Tokenized corner role used unless legacy [shape] is supplied.
  final NemoCornerRole cornerRole;

  /// Deprecated v1 corner migration input.
  final NemoSurfaceShape? shape;

  /// Optional internal padding.
  final EdgeInsetsGeometry? padding;

  /// Clipping behavior for the content.
  final Clip clipBehavior;

  /// Optional bounded finish. [NemoSurfaceFinish.tactileGlass] is valid only
  /// for a resolved [NemoMaterial.floating] surface.
  final NemoSurfaceFinish finish;

  /// Whether this surface may opt into Nemo's experimental progressive finish.
  ///
  /// Defaults to false until profile and conformance evidence establishes a
  /// supported performance envelope. False retains portable Canvas rendering
  /// and does not expose shader assets, uniforms, or callbacks.
  final bool enableProgressiveRendering;

  /// Explicit local visual transition. Defaults to [NemoSurfaceTransition.none]
  /// so static cards and theme-driven mutations do not animate.
  final NemoSurfaceTransition transition;

  NemoMaterial get _material =>
      material ??
      switch (depth ?? NemoSurfaceDepth.raised) {
        NemoSurfaceDepth.deeplySunken ||
        NemoSurfaceDepth.sunken => NemoMaterial.recessed,
        NemoSurfaceDepth.flat => NemoMaterial.base,
        NemoSurfaceDepth.raised => NemoMaterial.raised,
        NemoSurfaceDepth.elevated => NemoMaterial.floating,
      };

  @override
  State<NemoSurface> createState() => _NemoSurfaceState();
}

final class _NemoSurfaceState extends State<NemoSurface> {
  bool _requestedProgram = false;
  bool _explicitChange = false;
  bool _dependenciesChanged = false;
  bool _isTransitioning = false;
  int _transitionGeneration = 0;
  _SurfaceMaterialVisual? _from;
  late _SurfaceMaterialVisual _to;
  _SurfaceMaterialVisual? _displayed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dependenciesChanged = true;
    _loadFragmentProgramIfEligible();
  }

  @override
  void didUpdateWidget(covariant NemoSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _explicitChange =
        oldWidget.material != widget.material ||
        oldWidget.depth != widget.depth ||
        oldWidget.tone != widget.tone ||
        oldWidget.finish != widget.finish ||
        oldWidget.cornerRole != widget.cornerRole ||
        oldWidget.shape != widget.shape;
    if (_explicitChange ||
        oldWidget.enableProgressiveRendering !=
            widget.enableProgressiveRendering) {
      _loadFragmentProgramIfEligible();
    }
  }

  void _loadFragmentProgramIfEligible() {
    final NemoThemeData theme = NemoTheme.of(context);
    final bool isHighContrast =
        theme.materials.recipeFor(widget._material).shadowOpacity == 0;
    final bool eligibleMaterial =
        widget._material == NemoMaterial.raised ||
        widget._material == NemoMaterial.floating;
    if (_requestedProgram ||
        !widget.enableProgressiveRendering ||
        isHighContrast ||
        !eligibleMaterial) {
      return;
    }
    _requestedProgram = true;
    // Loading is intentionally initiated from the widget lifecycle, never paint.
    SurfaceFragmentProgramCache.load().whenComplete(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final NemoThemeData theme = NemoTheme.of(context);
    final double radius = switch (widget.shape) {
      NemoSurfaceShape.roundedSmall => theme.foundation.radiusSmall,
      NemoSurfaceShape.roundedMedium => theme.foundation.radiusMedium,
      NemoSurfaceShape.roundedLarge => theme.foundation.radiusLarge,
      null => switch (widget.cornerRole) {
        NemoCornerRole.control => theme.foundation.radiusSmall,
        NemoCornerRole.panel => theme.foundation.radiusMedium,
        NemoCornerRole.floating => theme.foundation.radiusLarge,
      },
    };
    final Color base = widget.tone == NemoSurfaceTone.surface
        ? theme.semantic.surface
        : theme.semantic.surfaceVariant;
    final NemoMaterialRecipe materialRecipe = theme.materials.recipeFor(
      widget._material,
    );
    final bool highContrast =
        MediaQuery.highContrastOf(context) || materialRecipe.shadowOpacity == 0;
    final bool usesTactileGlass =
        widget.finish == NemoSurfaceFinish.tactileGlass &&
        widget._material == NemoMaterial.floating;
    final NemoMotionTokens motion = theme.motion.resolveFor(context);
    final _SurfaceMaterialVisual target = _SurfaceMaterialVisual(
      highContrast && usesTactileGlass
          ? const NemoMaterialTokens.highContrast().floating
          : materialRecipe,
      base,
      radius,
    );
    _prepareTransition(target, motion);
    final Widget paddedChild = Padding(
      padding: widget.padding ?? EdgeInsets.all(theme.foundation.space16),
      child: widget.child,
    );
    Widget render(_SurfaceMaterialVisual visual, Widget content) =>
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size size = constraints.biggest;
            final bool isHighContrast =
                highContrast || visual.recipe.shadowOpacity == 0;
            final SurfaceRenderer renderer = SurfaceRendererSelector.select(
              SurfaceRendererInput(
                material: widget._material,
                size: size,
                isHighContrast: isHighContrast,
                isEnabled:
                    (widget.enableProgressiveRendering || usesTactileGlass) &&
                    !_isTransitioning,
                finish: widget.finish,
              ),
              hasFragmentProgram: SurfaceFragmentProgramCache.program != null,
            );
            final bool useBackdrop = renderer == SurfaceRenderer.backdrop;
            final TactileGlassTokens glassTokens = isHighContrast
                ? TactileGlassTokens.highContrast
                : TactileGlassTokens.standard;
            final Widget painted = CustomPaint(
              painter: _NemoMaterialPainter(
                theme: theme,
                visual: visual,
                fragmentProgram: renderer == SurfaceRenderer.fragment
                    ? SurfaceFragmentProgramCache.program
                    : null,
                tactileGlass: usesTactileGlass,
                glassTokens: glassTokens,
                translucentFill: useBackdrop,
              ),
              child: widget.clipBehavior == Clip.none
                  ? content
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(visual.radius),
                      clipBehavior: widget.clipBehavior,
                      child: content,
                    ),
            );
            if (!useBackdrop) return painted;
            // Keep the Canvas-painted outer shadows outside the clipped filter.
            // Only the sampled backdrop is localized to the floating plane.
            return Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(visual.radius),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: glassTokens.backdropBlurSigma,
                        sigmaY: glassTokens.backdropBlurSigma,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                painted,
              ],
            );
          },
        );
    if (!_isTransitioning) {
      return render(target, paddedChild);
    }
    return TweenAnimationBuilder<_SurfaceMaterialVisual>(
      key: ValueKey<int>(_transitionGeneration),
      tween: _SurfaceMaterialVisualTween(begin: _from!, end: _to),
      duration: _durationFor(motion),
      curve: motion.decelerateCurve,
      child: paddedChild,
      onEnd: () {
        if (mounted) {
          setState(() => _isTransitioning = false);
        }
      },
      builder:
          (BuildContext context, _SurfaceMaterialVisual visual, Widget? child) {
            _displayed = visual;
            return render(visual, child!);
          },
    );
  }

  void _prepareTransition(
    _SurfaceMaterialVisual target,
    NemoMotionTokens motion,
  ) {
    final Duration duration = _durationFor(motion);
    if (_explicitChange) {
      if (duration > Duration.zero &&
          _displayed != null &&
          _displayed!.differsFrom(target)) {
        _from = _displayed;
        _to = target;
        _isTransitioning = true;
        _transitionGeneration += 1;
      } else {
        _isTransitioning = false;
        _displayed = target;
        _to = target;
      }
    } else if (_dependenciesChanged && _isTransitioning) {
      _isTransitioning = false;
      _displayed = target;
      _to = target;
    } else if (!_isTransitioning) {
      _displayed = target;
      _to = target;
    }
    _explicitChange = false;
    _dependenciesChanged = false;
  }

  Duration _durationFor(NemoMotionTokens motion) => switch (widget.transition) {
    NemoSurfaceTransition.none => Duration.zero,
    NemoSurfaceTransition.local => motion.standard,
    NemoSurfaceTransition.overlay => motion.emphasized,
  };
}

final class _SurfaceMaterialVisualTween extends Tween<_SurfaceMaterialVisual> {
  _SurfaceMaterialVisualTween({
    required _SurfaceMaterialVisual super.begin,
    required _SurfaceMaterialVisual super.end,
  });

  @override
  _SurfaceMaterialVisual lerp(double t) =>
      _SurfaceMaterialVisual.lerp(begin!, end!, t);
}

@immutable
final class _SurfaceMaterialVisual {
  const _SurfaceMaterialVisual(this.recipe, this.color, this.radius);
  final NemoMaterialRecipe recipe;
  final Color color;
  final double radius;

  bool differsFrom(_SurfaceMaterialVisual other) =>
      recipe != other.recipe || color != other.color || radius != other.radius;

  static _SurfaceMaterialVisual lerp(
    _SurfaceMaterialVisual a,
    _SurfaceMaterialVisual b,
    double t,
  ) => _SurfaceMaterialVisual(
    NemoMaterialRecipe.lerp(a.recipe, b.recipe, t),
    Color.lerp(a.color, b.color, t)!,
    a.radius + (b.radius - a.radius) * t,
  );
}

final class _NemoMaterialPainter extends CustomPainter {
  const _NemoMaterialPainter({
    required this.theme,
    required this.visual,
    required this.tactileGlass,
    required this.glassTokens,
    required this.translucentFill,
    this.fragmentProgram,
  });
  final NemoThemeData theme;
  final _SurfaceMaterialVisual visual;
  final ui.FragmentProgram? fragmentProgram;
  final bool tactileGlass;
  final TactileGlassTokens glassTokens;
  final bool translucentFill;

  @override
  void paint(Canvas canvas, Size size) => NemoIllumination.paint(
    canvas,
    size,
    theme: theme,
    recipe: visual.recipe,
    baseColor: visual.color,
    radius: visual.radius,
    outlineOpacity: tactileGlass ? glassTokens.boundaryOpacity : null,
    localFill: tactileGlass
        ? (Canvas canvas, RRect shape) => _paintTactileGlass(canvas, shape)
        : fragmentProgram == null
        ? null
        : (Canvas canvas, RRect shape) => SurfaceFragmentFillPainter.paint(
            canvas,
            shape,
            program: fragmentProgram!,
            baseColor: visual.color,
            radius: visual.radius,
          ),
  );
  void _paintTactileGlass(Canvas canvas, RRect shape) {
    canvas.drawRRect(
      shape,
      Paint()
        ..color = visual.color.withValues(
          alpha: translucentFill ? glassTokens.fillOpacity : 1,
        ),
    );
    final Paint rim = Paint()
      ..color = theme.semantic.highlightShadow.withValues(
        alpha: glassTokens.rimOpacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.components.outlineWidth * 1.5;
    final Paint occlusion = Paint()
      ..color = theme.semantic.lowlightShadow.withValues(
        alpha: glassTokens.occlusionOpacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.components.outlineWidth * 1.5;
    canvas.drawPath(_topLeftRim(shape), rim);
    canvas.drawPath(_bottomRightOcclusion(shape), occlusion);
  }

  Path _topLeftRim(RRect shape) => Path()
    ..moveTo(shape.left, shape.bottom - visual.radius)
    ..lineTo(shape.left, shape.top + visual.radius)
    ..quadraticBezierTo(
      shape.left,
      shape.top,
      shape.left + visual.radius,
      shape.top,
    )
    ..lineTo(shape.right - visual.radius, shape.top);

  Path _bottomRightOcclusion(RRect shape) => Path()
    ..moveTo(shape.left + visual.radius, shape.bottom)
    ..lineTo(shape.right - visual.radius, shape.bottom)
    ..quadraticBezierTo(
      shape.right,
      shape.bottom,
      shape.right,
      shape.bottom - visual.radius,
    )
    ..lineTo(shape.right, shape.top + visual.radius);

  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(covariant _NemoMaterialPainter old) =>
      old.theme != theme ||
      old.visual.recipe != visual.recipe ||
      old.visual.color != visual.color ||
      old.visual.radius != visual.radius ||
      old.fragmentProgram != fragmentProgram ||
      old.tactileGlass != tactileGlass ||
      old.glassTokens != glassTokens ||
      old.translucentFill != translucentFill;
}
