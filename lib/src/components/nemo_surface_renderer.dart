// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../foundation/nemo_illumination.dart';
import '../foundation/nemo_material.dart';
import '../foundation/nemo_surface_contract.dart';

/// Internal renderer choices. This source file is deliberately not exported.
enum SurfaceRenderer { canvas, fragment, backdrop }

/// The bounded, non-customizable recipe for tactile glass.
@immutable
final class TactileGlassTokens {
  const TactileGlassTokens({
    required this.fillOpacity,
    required this.rimOpacity,
    required this.occlusionOpacity,
    required this.boundaryOpacity,
    required this.backdropBlurSigma,
  }) : assert(fillOpacity >= 0 && fillOpacity <= 1),
       assert(rimOpacity >= 0 && rimOpacity <= 1),
       assert(occlusionOpacity >= 0 && occlusionOpacity <= 1),
       assert(boundaryOpacity >= 0 && boundaryOpacity <= 1),
       assert(backdropBlurSigma >= 0);

  static const TactileGlassTokens standard = TactileGlassTokens(
    fillOpacity: .92,
    rimOpacity: .18,
    occlusionOpacity: .16,
    boundaryOpacity: .62,
    backdropBlurSigma: 12,
  );

  static const TactileGlassTokens highContrast = TactileGlassTokens(
    fillOpacity: 1,
    rimOpacity: 0,
    occlusionOpacity: 0,
    boundaryOpacity: 1,
    backdropBlurSigma: 0,
  );

  final double fillOpacity;
  final double rimOpacity;
  final double occlusionOpacity;
  final double boundaryOpacity;
  final double backdropBlurSigma;
}

/// Bounded facts used to decide whether a decorative fragment fill is safe.
@immutable
final class SurfaceRendererInput {
  const SurfaceRendererInput({
    required this.material,
    required this.size,
    required this.isHighContrast,
    required this.isEnabled,
    this.finish = NemoSurfaceFinish.standard,
  });

  final NemoMaterial material;
  final Size size;
  final bool isHighContrast;
  final bool isEnabled;
  final NemoSurfaceFinish finish;
}

/// Internal deterministic test seam; it is not part of Nemo's public API.
@visibleForTesting
SurfaceRenderer Function(SurfaceRendererInput input, SurfaceRenderer fallback)?
debugSurfaceRendererSelectionOverride;

final class SurfaceRendererSelector {
  const SurfaceRendererSelector._();

  static const Size _minimumSize = Size(240, 160);

  static SurfaceRenderer select(
    SurfaceRendererInput input, {
    required bool hasFragmentProgram,
  }) {
    final bool canUseFragment =
        input.isEnabled &&
        !input.isHighContrast &&
        hasFragmentProgram &&
        (input.material == NemoMaterial.raised ||
            input.material == NemoMaterial.floating) &&
        input.size.width.isFinite &&
        input.size.height.isFinite &&
        input.size.width >= _minimumSize.width &&
        input.size.height >= _minimumSize.height;
    final bool canUseBackdrop =
        input.isEnabled &&
        !input.isHighContrast &&
        input.material == NemoMaterial.floating &&
        input.finish == NemoSurfaceFinish.tactileGlass &&
        input.size.width.isFinite &&
        input.size.height.isFinite &&
        input.size.width >= _minimumSize.width &&
        input.size.height >= _minimumSize.height;
    final SurfaceRenderer fallback = canUseBackdrop
        ? SurfaceRenderer.backdrop
        : canUseFragment
        ? SurfaceRenderer.fragment
        : SurfaceRenderer.canvas;
    return debugSurfaceRendererSelectionOverride?.call(input, fallback) ??
        fallback;
  }
}

/// Process-wide cache that starts fragment loading outside the paint phase.
final class SurfaceFragmentProgramCache {
  SurfaceFragmentProgramCache._();

  static const String assetKey = 'shaders/nemo_surface.frag';
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram?>? _loading;

  static ui.FragmentProgram? get program => _program;

  static Future<ui.FragmentProgram?> load() => _loading ??= _load();

  static Future<ui.FragmentProgram?> _load() async {
    try {
      return _program = await ui.FragmentProgram.fromAsset(assetKey);
    } catch (_) {
      return null;
    }
  }
}

/// The fixed, bounded visual recipe for the experimental local finish.
@immutable
final class _SurfaceFinishRecipe {
  const _SurfaceFinishRecipe({
    required this.lightDirection,
    required this.rimStrength,
    required this.ambientOcclusion,
    required this.grainOpacity,
  }) : assert(rimStrength >= 0 && rimStrength <= .1),
       assert(ambientOcclusion >= 0 && ambientOcclusion <= .1),
       assert(grainOpacity >= 0 && grainOpacity <= .03);

  static const _SurfaceFinishRecipe standard = _SurfaceFinishRecipe(
    lightDirection: NemoIllumination.topLeftLightDirection,
    rimStrength: .045,
    ambientOcclusion: .065,
    grainOpacity: .012,
  );

  final Offset lightDirection;
  final double rimStrength;
  final double ambientOcclusion;
  final double grainOpacity;
}

/// Typed bounded inputs passed to the private fragment program.
@immutable
final class _SurfaceFinishInput {
  const _SurfaceFinishInput({
    required this.size,
    required this.radius,
    required this.baseColor,
    required this.recipe,
  }) : assert(radius >= 0);

  final Size size;
  final double radius;
  final Color baseColor;
  final _SurfaceFinishRecipe recipe;
}

final class _SurfaceFragmentUniform {
  const _SurfaceFragmentUniform._();
  static const int width = 0;
  static const int height = 1;
  static const int radius = 2;
  static const int red = 3;
  static const int green = 4;
  static const int blue = 5;
  static const int alpha = 6;
  static const int lightX = 7;
  static const int lightY = 8;
  static const int rimStrength = 9;
  static const int ambientOcclusion = 10;
  static const int grainOpacity = 11;
}

/// Decorative local-fill painter. Canvas remains responsible for shadows and edges.
final class SurfaceFragmentFillPainter {
  const SurfaceFragmentFillPainter._();

  static void paint(
    Canvas canvas,
    RRect shape, {
    required ui.FragmentProgram program,
    required Color baseColor,
    required double radius,
  }) {
    final _SurfaceFinishInput input = _SurfaceFinishInput(
      size: shape.outerRect.size,
      radius: radius,
      baseColor: baseColor,
      recipe: _SurfaceFinishRecipe.standard,
    );
    final ui.FragmentShader shader = program.fragmentShader()
      ..setFloat(_SurfaceFragmentUniform.width, input.size.width)
      ..setFloat(_SurfaceFragmentUniform.height, input.size.height)
      ..setFloat(_SurfaceFragmentUniform.radius, input.radius)
      ..setFloat(_SurfaceFragmentUniform.red, input.baseColor.r)
      ..setFloat(_SurfaceFragmentUniform.green, input.baseColor.g)
      ..setFloat(_SurfaceFragmentUniform.blue, input.baseColor.b)
      ..setFloat(_SurfaceFragmentUniform.alpha, input.baseColor.a)
      ..setFloat(_SurfaceFragmentUniform.lightX, input.recipe.lightDirection.dx)
      ..setFloat(_SurfaceFragmentUniform.lightY, input.recipe.lightDirection.dy)
      ..setFloat(_SurfaceFragmentUniform.rimStrength, input.recipe.rimStrength)
      ..setFloat(
        _SurfaceFragmentUniform.ambientOcclusion,
        input.recipe.ambientOcclusion,
      )
      ..setFloat(
        _SurfaceFragmentUniform.grainOpacity,
        input.recipe.grainOpacity,
      );
    canvas
      ..save()
      ..clipRRect(shape)
      ..drawRect(shape.outerRect, Paint()..shader = shader)
      ..restore();
  }
}
