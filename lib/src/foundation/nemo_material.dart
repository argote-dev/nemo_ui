import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The four semantic materials in Nemo Theme Contract v2.
///
/// A [floating] material is reserved for a transient or prominent local plane.
enum NemoMaterial {
  /// A receiving well or inset material.
  recessed,

  /// The uninterrupted dominant canvas.
  base,

  /// An actionable or grouped local plane.
  raised,

  /// A transient or prominent local plane.
  floating,
}

/// Tokenized corner roles. Components choose a role rather than a raw radius.
enum NemoCornerRole {
  /// Compact corners for controls.
  control,

  /// Standard corners for local panels.
  panel,

  /// Largest corners for transient planes.
  floating,
}

/// Physical edge polarity used by Nemo's one top-left illumination source.
enum NemoIlluminationPolarity {
  /// Reversed clipped edges for an inset material.
  inset,

  /// No tactile shadow edges.
  none,

  /// Paired outer edges lit from physical top-left.
  raised,
}

/// A bounded material recipe; it is not a public painter API.
@immutable
final class NemoMaterialRecipe {
  /// Creates a bounded material recipe.
  const NemoMaterialRecipe({
    required this.polarity,
    required this.tonalOverlayOpacity,
    required this.outlineOpacity,
    required this.shadowOpacity,
    required this.blurMultiplier,
    required this.offsetMultiplier,
  }) : assert(tonalOverlayOpacity >= 0 && tonalOverlayOpacity <= 1),
       assert(outlineOpacity >= 0 && outlineOpacity <= 1),
       assert(shadowOpacity >= 0 && shadowOpacity <= 1),
       assert(blurMultiplier >= 0 && blurMultiplier <= 2),
       assert(offsetMultiplier >= 0 && offsetMultiplier <= 2);

  /// Physical raised/inset polarity.
  final NemoIlluminationPolarity polarity;

  /// Opacity of the material tonal overlay.
  final double tonalOverlayOpacity;

  /// Opacity of its boundary outline.
  final double outlineOpacity;

  /// Opacity of its decorative paired shadows.
  final double shadowOpacity;

  /// Multiplier for foundation blur.
  final double blurMultiplier;

  /// Multiplier for foundation offset.
  final double offsetMultiplier;

  /// Standard inset recipe.
  static const NemoMaterialRecipe recessed = NemoMaterialRecipe(
    polarity: NemoIlluminationPolarity.inset,
    tonalOverlayOpacity: .14,
    outlineOpacity: .34,
    shadowOpacity: .38,
    blurMultiplier: .62,
    offsetMultiplier: .5,
  );

  /// Standard uninterrupted canvas recipe.
  static const NemoMaterialRecipe base = NemoMaterialRecipe(
    polarity: NemoIlluminationPolarity.none,
    tonalOverlayOpacity: 0,
    outlineOpacity: .16,
    shadowOpacity: 0,
    blurMultiplier: 0,
    offsetMultiplier: 0,
  );

  /// Standard raised recipe.
  static const NemoMaterialRecipe raised = NemoMaterialRecipe(
    polarity: NemoIlluminationPolarity.raised,
    tonalOverlayOpacity: .045,
    outlineOpacity: .12,
    shadowOpacity: .28,
    blurMultiplier: .78,
    offsetMultiplier: .68,
  );

  /// Standard transient floating recipe.
  static const NemoMaterialRecipe floating = NemoMaterialRecipe(
    polarity: NemoIlluminationPolarity.raised,
    tonalOverlayOpacity: .075,
    outlineOpacity: .2,
    shadowOpacity: .42,
    blurMultiplier: 1,
    offsetMultiplier: 1,
  );

  /// Interpolates two recipes for a material transition.
  static NemoMaterialRecipe lerp(
    NemoMaterialRecipe a,
    NemoMaterialRecipe b,
    double t,
  ) => NemoMaterialRecipe(
    polarity: t < .5 ? a.polarity : b.polarity,
    tonalOverlayOpacity: lerpDouble(
      a.tonalOverlayOpacity,
      b.tonalOverlayOpacity,
      t,
    )!,
    outlineOpacity: lerpDouble(a.outlineOpacity, b.outlineOpacity, t)!,
    shadowOpacity: lerpDouble(a.shadowOpacity, b.shadowOpacity, t)!,
    blurMultiplier: lerpDouble(a.blurMultiplier, b.blurMultiplier, t)!,
    offsetMultiplier: lerpDouble(a.offsetMultiplier, b.offsetMultiplier, t)!,
  );
}

/// Theme-owned bounded recipes for the four Nemo materials.
@immutable
final class NemoMaterialTokens {
  /// Creates the complete four-material token group.
  const NemoMaterialTokens({
    required this.recessed,
    required this.base,
    required this.raised,
    required this.floating,
  });

  /// Recipe for [NemoMaterial.recessed].
  final NemoMaterialRecipe recessed;

  /// Recipe for [NemoMaterial.base].
  final NemoMaterialRecipe base;

  /// Recipe for [NemoMaterial.raised].
  final NemoMaterialRecipe raised;

  /// Recipe for [NemoMaterial.floating].
  final NemoMaterialRecipe floating;

  /// Creates the standard shadow-bearing token group.
  const NemoMaterialTokens.standard()
    : this(
        recessed: NemoMaterialRecipe.recessed,
        base: NemoMaterialRecipe.base,
        raised: NemoMaterialRecipe.raised,
        floating: NemoMaterialRecipe.floating,
      );

  /// Creates the shadow-free high-contrast token group.
  const NemoMaterialTokens.highContrast()
    : this(
        recessed: const NemoMaterialRecipe(
          polarity: NemoIlluminationPolarity.inset,
          tonalOverlayOpacity: .12,
          outlineOpacity: 1,
          shadowOpacity: 0,
          blurMultiplier: 0,
          offsetMultiplier: 0,
        ),
        base: const NemoMaterialRecipe(
          polarity: NemoIlluminationPolarity.none,
          tonalOverlayOpacity: 0,
          outlineOpacity: 1,
          shadowOpacity: 0,
          blurMultiplier: 0,
          offsetMultiplier: 0,
        ),
        raised: const NemoMaterialRecipe(
          polarity: NemoIlluminationPolarity.raised,
          tonalOverlayOpacity: .08,
          outlineOpacity: 1,
          shadowOpacity: 0,
          blurMultiplier: 0,
          offsetMultiplier: 0,
        ),
        floating: const NemoMaterialRecipe(
          polarity: NemoIlluminationPolarity.raised,
          tonalOverlayOpacity: .16,
          outlineOpacity: 1,
          shadowOpacity: 0,
          blurMultiplier: 0,
          offsetMultiplier: 0,
        ),
      );

  /// Returns the recipe for [material].
  NemoMaterialRecipe recipeFor(NemoMaterial material) => switch (material) {
    NemoMaterial.recessed => recessed,
    NemoMaterial.base => base,
    NemoMaterial.raised => raised,
    NemoMaterial.floating => floating,
  };

  /// Copies this group with selected recipes replaced.
  NemoMaterialTokens copyWith({
    NemoMaterialRecipe? recessed,
    NemoMaterialRecipe? base,
    NemoMaterialRecipe? raised,
    NemoMaterialRecipe? floating,
  }) => NemoMaterialTokens(
    recessed: recessed ?? this.recessed,
    base: base ?? this.base,
    raised: raised ?? this.raised,
    floating: floating ?? this.floating,
  );

  /// Interpolates complete material groups.
  static NemoMaterialTokens lerp(
    NemoMaterialTokens a,
    NemoMaterialTokens b,
    double t,
  ) => NemoMaterialTokens(
    recessed: NemoMaterialRecipe.lerp(a.recessed, b.recessed, t),
    base: NemoMaterialRecipe.lerp(a.base, b.base, t),
    raised: NemoMaterialRecipe.lerp(a.raised, b.raised, t),
    floating: NemoMaterialRecipe.lerp(a.floating, b.floating, t),
  );
}

/// Orthogonal interaction evidence used by Nemo controls.
enum NemoInteractionState {
  /// Default available control state.
  resting,

  /// Pointer hover evidence.
  hovered,

  /// Active physical-pressure evidence.
  pressed,

  /// Keyboard focus evidence.
  focused,

  /// Selected/value evidence.
  selected,

  /// Unavailable evidence.
  disabled,

  /// Busy evidence.
  loading,
}

/// A bounded shared interaction recipe. State layers compose; no control owns light math.
@immutable
final class NemoInteractionRecipe {
  /// Creates a bounded interaction layer recipe.
  const NemoInteractionRecipe({
    required this.material,
    required this.toneBlend,
    required this.outlineOpacity,
    required this.contentOffset,
  }) : assert(toneBlend >= 0 && toneBlend <= 1),
       assert(outlineOpacity >= 0 && outlineOpacity <= 1),
       assert(contentOffset >= 0 && contentOffset <= 2);

  /// Material selected by this interaction layer.
  final NemoMaterial material;

  /// Additional semantic tone blend.
  final double toneBlend;

  /// Explicit outline evidence opacity.
  final double outlineOpacity;

  /// Downward content displacement in logical pixels.
  final double contentOffset;

  /// Interpolates a bounded interaction recipe for state transitions.
  static NemoInteractionRecipe lerp(
    NemoInteractionRecipe a,
    NemoInteractionRecipe b,
    double t,
  ) => NemoInteractionRecipe(
    material: t < .5 ? a.material : b.material,
    toneBlend: lerpDouble(a.toneBlend, b.toneBlend, t)!,
    outlineOpacity: lerpDouble(a.outlineOpacity, b.outlineOpacity, t)!,
    contentOffset: lerpDouble(a.contentOffset, b.contentOffset, t)!,
  );
}

/// Theme-owned recipes for orthogonal interactive control states.
@immutable
final class NemoInteractionTokens {
  /// Creates the complete shared interaction token group.
  const NemoInteractionTokens({
    required this.resting,
    required this.hovered,
    required this.pressed,
    required this.focused,
    required this.selected,
    required this.disabled,
    required this.loading,
  });

  /// Default available interaction recipe.
  final NemoInteractionRecipe resting;

  /// Pointer hover recipe.
  final NemoInteractionRecipe hovered;

  /// Physical press recipe.
  final NemoInteractionRecipe pressed;

  /// Focus recipe.
  final NemoInteractionRecipe focused;

  /// Selected/value recipe.
  final NemoInteractionRecipe selected;

  /// Disabled recipe.
  final NemoInteractionRecipe disabled;

  /// Loading recipe.
  final NemoInteractionRecipe loading;

  /// Standard shared interaction recipes.
  static const standard = NemoInteractionTokens(
    resting: NemoInteractionRecipe(
      material: NemoMaterial.raised,
      toneBlend: 0,
      outlineOpacity: .12,
      contentOffset: 0,
    ),
    hovered: NemoInteractionRecipe(
      material: NemoMaterial.raised,
      toneBlend: .05,
      outlineOpacity: .32,
      contentOffset: 0,
    ),
    pressed: NemoInteractionRecipe(
      material: NemoMaterial.recessed,
      toneBlend: .1,
      outlineOpacity: .65,
      contentOffset: 1,
    ),
    focused: NemoInteractionRecipe(
      material: NemoMaterial.raised,
      toneBlend: .03,
      outlineOpacity: .7,
      contentOffset: 0,
    ),
    selected: NemoInteractionRecipe(
      material: NemoMaterial.recessed,
      toneBlend: .14,
      outlineOpacity: .7,
      contentOffset: 0,
    ),
    disabled: NemoInteractionRecipe(
      material: NemoMaterial.base,
      toneBlend: 0,
      outlineOpacity: .6,
      contentOffset: 0,
    ),
    loading: NemoInteractionRecipe(
      material: NemoMaterial.base,
      toneBlend: .02,
      outlineOpacity: .6,
      contentOffset: 0,
    ),
  );

  /// Returns the recipe for [state].
  NemoInteractionRecipe recipeFor(NemoInteractionState state) =>
      switch (state) {
        NemoInteractionState.resting => resting,
        NemoInteractionState.hovered => hovered,
        NemoInteractionState.pressed => pressed,
        NemoInteractionState.focused => focused,
        NemoInteractionState.selected => selected,
        NemoInteractionState.disabled => disabled,
        NemoInteractionState.loading => loading,
      };
}
