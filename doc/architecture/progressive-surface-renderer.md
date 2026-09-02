# Progressive surface renderer profile procedure

NemoSurface keeps Canvas as its portable baseline. The fragment finish is experimental and default-off; no performance envelope or device evidence is claimed yet. The private fragment program
may decorate only the local fill of large, static raised or floating surfaces;
Canvas continues to draw shadows, outlines, focus evidence, and all
high-contrast output.

Do not claim a performance envelope from a synthetic benchmark. Before enabling
or widening fragment adoption, profile a representative screen on each target
(Android, iOS, and web) in profile mode with a release-like build:

1. Capture an initial open of a large raised/floating surface and at least one
   representative scroll/list interaction.
2. Record p95 UI and GPU frame time, first-use jank, process memory change, and
   one comparable energy observation using the platform's profiler.
3. Repeat with `enableProgressiveRendering: false` under the same device,
   build, route, and interaction conditions.
4. Record device, OS/browser, Flutter version, renderer, screen dimensions,
   capture duration, and any thermal/power condition that could affect results.
5. Keep the Canvas fallback if evidence is incomplete, regresses, or does not
   cover the target surface density.

Attach the raw profiler captures or an auditable summary to the adoption change. Do not enable a catalog or other default adoption until this gate and conformance review are complete.
No device metrics are asserted by this repository until such evidence exists.
