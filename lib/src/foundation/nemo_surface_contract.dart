/// The visual relief offered by [NemoSurface].
enum NemoSurfaceDepth {
  /// A strongly inset surface.
  deeplySunken,

  /// A subtly inset surface.
  sunken,

  /// A neutral surface without relief.
  flat,

  /// A subtly raised surface.
  raised,

  /// A strongly raised surface.
  elevated,
}

/// The semantic base color used by [NemoSurface].
enum NemoSurfaceTone {
  /// Uses the primary semantic surface.
  surface,

  /// Uses the alternate semantic surface.
  surfaceVariant,
}

/// The tokenized corner shape used by [NemoSurface].
enum NemoSurfaceShape {
  /// Uses the small foundation radius.
  roundedSmall,

  /// Uses the medium foundation radius.
  roundedMedium,

  /// Uses the large foundation radius.
  roundedLarge,
}

/// Optional visual finish for a [NemoMaterial.floating] surface.
///
/// This does not add a material: tactile glass is reserved for transient,
/// prominent floating planes and is never the default finish.
enum NemoSurfaceFinish {
  /// The portable, opaque Nemo material recipe.
  standard,

  /// A bounded, high-opacity local glass treatment for floating overlays.
  tactileGlass,
}
