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
